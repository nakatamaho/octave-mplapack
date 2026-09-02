# Complex MPFR architecture freeze

M20 is an audit and design freeze, not a complex implementation.  The public
`mp` class remains real-only through M19.  This document records the boundary
that future C00--C12 work must preserve.

## Evidence from the pinned MPLAPACK installation

The controlled installation was discovered with `pkg-config mplapack_mpfr`
and corresponds to MPLAPACK commit
`1cf03d1a1aa2afecde5f1840fbe9663ecfc31e57` (version 3.0.1).  With
`MPLAPACK_BUILD_WITH_MPFR`, `mplapack.h` defines:

```cpp
using REAL = mpfrxx::mpfr_class;
using COMPLEX = mpfrxx::mpc_class;
```

The exact complex type is `mpfrxx::mpc_class`, declared by the installed
`gmpfrxx_mkII/detail/mpc_impl.hpp` and included by `mpcxx_mkII.h`.  It owns an
MPC `mpc_t value_`; the real and imaginary components are MPFR values.  The
class supplies `with_precision(p)`, `with_precision(real_p, imag_p)`,
`real_precision()`, `imag_precision()`, `precision()`, `real()`, `imag()`,
and `mpc_data()`.  Copy construction preserves both component precisions;
move construction swaps initialized MPC values.  The installed header also
asserts that `sizeof(mpc_class) == sizeof(mpc_t)` and that their alignments
match, making a contiguous `std::vector<mpc_class>` ABI-compatible with an
MPLAPACK `mpc_class *` argument.

The test-only `test/m20_complex_probe.cc` compiled against the installed
headers and controlled library.  It passed 1024-bit and 2048-bit complex GEMM
identity cases with `2^-700` and `2^-1500` component tails, one-by-one Cgesv,
Cpotrf, Cgeqrf, and Cungqr calls, component-precision checks, and a worker
thread isolation check.  `ldd -r` resolved the controlled
`libmplapack_mpfr.so.3`, `libmpc.so.3`, `libmpfr.so.6`, and `libgmp.so.10`;
`libmplapack_mpfr_opt` was not linked.

## Frozen storage and precision model

One future complex scalar has exactly one project precision `p`:

```text
real precision = p
imag precision = p
```

Although `mpc_class::with_precision(real_p, imag_p)` can construct a mixed
backend value, mixed component precision is forbidden in a public `mp`
object.  A future `MpfrComplexMatrixStorage` will be one contiguous,
column-major `std::vector<mpc_class>` with one immutable precision field.
Allocation will use explicit equal component precision (or a scoped default
only where the backend requires it), and its data pointer will be passed
directly as MPLAPACK `COMPLEX *`.  Real matrices remain the existing
`MpfrMatrixStorage` of `REAL` values; they are never widened to complex storage
just because complex support exists.

Every complex numerical invocation has one `p_op`.  All COMPLEX arrays,
REAL work arrays, tolerances, norms, singular values, and temporary values at
the MPLAPACK boundary use `p_op`, and the executing worker establishes that
precision.  The project policy is round-to-nearest for both components.  A
future complex precision scope must compose the existing MPFR scope with the
MPC default context, or use explicit `with_precision(p)` allocation
throughout.  The installed wrapper has thread-local MPC precision and rounding
override state; when no override is active, defaults inherit the MPFR default.
An explicit MPC override must therefore be controlled or rejected by future
complex code so it cannot violate the one-precision contract.

## Public payload architecture

There remains one public class, `mp`, with four checked native payload kinds:

| Payload kind | Storage | Public result |
|---|---|---|
| real scalar | `MpfrScalarStorage` | real `mp` scalar |
| real dense matrix | `MpfrMatrixStorage` | real `mp` matrix |
| complex scalar | future MPC storage | complex `mp` scalar |
| complex dense matrix | future `MpfrComplexMatrixStorage` | complex `mp` matrix |

Native dispatch will use a small checked payload-kind/category enum and native
type identity, never class-name strings or raw pointer handles.  Public values
remain immutable; destructive GEMM, solves, factorizations, and transformations
always receive operation-owned deep copies.  Clearing an input or an alias
must never invalidate a result.

For binary operations, any complex participant makes the result complex and
`p_op` is the maximum stored precision of all `mp` participants.  Real values
promote by exact copy into the real component and an exact `+0` imaginary
component at `p_op`.  A complex builtin double promotes each incoming binary64
real and imaginary component directly with MPFR/MPC round-to-nearest; decimal
text conversion is forbidden.  There is no implicit complex-to-real demotion,
even when all imaginary components happen to be zero.  Explicit `real(z)`,
`imag(z)`, and `abs(z)` are real-returning APIs and preserve the source
precision; `conj(z)` is complex and preserves precision.

## Constructor, formatting, and structural design

Future constructor work must distinguish real doubles, complex doubles, and
arbitrary-precision text.  The preferred unambiguous text API is an explicit
pair of real and imaginary components (or a documented canonical grammar),
not a loose parser that conflates `1e2i` and ordinary text.  A future complex
scalar `char` format must be locale-independent, round-trip-safe at source
precision, and preserve signed zero, infinities, NaNs, and exponent spelling
unambiguously.  Matrix `char` remains a separate later decision.

`A.'` is transpose only; `A'` is transpose plus conjugation.  Real values
retain the M12 behavior.  Real/complex concatenation and assignment promote
the complete result to complex storage at the maximum precision, while M14
value semantics still require a new result payload.  Complex indexing returns
complex scalars or matrices at source precision.  Structural metadata and
permutation/status outputs remain builtin Octave values, not complex `mp`.

## Backend inventory

The installed MPFR library exports real and complex routines from the same
`libmplapack_mpfr.so.3`.  Exact declarations audited in
`mplapack_mpfr.h` include:

| Future operation | Installed MPFR routine/signature family |
|---|---|
| GEMM | `Cgemm(const char*, const char*, mplapackint, mplapackint, mplapackint, mpc_class, mpc_class*, mplapackint, mpc_class*, mplapackint, mpc_class, mpc_class*, mplapackint)` |
| square solve | `Cgesv(mplapackint, mplapackint, mpc_class*, mplapackint, mplapackint*, mpc_class*, mplapackint, mplapackint&)` |
| Cholesky | `Cpotrf(const char*, mplapackint, mpc_class*, mplapackint, mplapackint&)` |
| QR | `Cgeqrf(...)` and `Cungqr(...)` with `mpc_class` work arrays |
| pivoted QR | `Cgeqp3(...)` with `mplapackint* JPVT` and real `mpfr_class* RWORK` |
| rectangular least squares | `Cgelss(...)`, `Cgelsy(...)`, and `Cgelsd(...)` with real singular-value/RWORK arrays |

The exact full declarations remain the installed-header authority.  The
probe exercised Cgemm, Cgesv, Cpotrf, Cgeqrf, and Cungqr; future milestones
must add numerical canaries for the remaining drivers before using them.

At the pinned source, Cgemm is the reference loop implementation.  Cgesv
calls Cgetrf/Cgetrs; Cpotrf uses Cherk/Cpotrf2/Cgemm/Ctrsm; Cgeqrf and Cungqr
use their blocked/unblocked reflector helpers; Cgeqp3 uses Cgeqrf, Cunmqr,
Claqps/Claqp2, and RCnrm2; Cgelss/Cgelsy/Cgelsd use the corresponding QR/LQ,
bidiagonal, SVD, and orthogonal-transform routines.  A source search found
no OpenMP, pthread, or `std::thread` regions in the pinned reference tree,
and the controlled probe did not link the optimized MPLAPACK library.  If a
future optimized or worker path is enabled, every arithmetic worker must
establish `p_op`; an unscoped path blocks complex release until upstream is
audited.

## Future operation rules

| Operation | Design rule | Future milestone |
|---|---|---|
| element-wise arithmetic | direct MPC operations into explicit `p_op` destinations | C04 |
| GEMM | direct complex MPLAPACK `Cgemm`, never four real GEMMs | C05 |
| square solve | operation-owned complex copies and `Cgesv` | C06 |
| rectangular solve | rank-revealing complex candidate audit, minimum norm | C07 |
| Hermitian Cholesky | selected triangle and conjugate-transpose semantics through `Cpotrf` | C08 |
| QR | complex factor/generator routines identified from installed headers | C09 |
| pivoted QR | complex `Cgeqp3`-equivalent after exact JPVT audit | C10 |

Complex rank thresholds will derive from the real machine epsilon at `p_op`,
never binary64 epsilon or a decimal constant.  Permutation matrices/vectors
remain builtin double structural outputs.  Ordered complex comparisons are
not assumed; equality/inequality and explicit real-valued reductions need a
separate API decision.

## Packaging and licensing inventory

The audited complex symbols are in the existing `libmplapack_mpfr.so.3`, so
the current `octave-mplapack` package can gain complex support in a normal
update without a package rename.  The runtime closure already includes MPC,
MPFR, and GMP; development packaging must continue to discover these through
the MPLAPACK `pkg-config` metadata rather than copying libraries.  The
controlled installation linked no optimized MPLAPACK DSO.  Project and
MPLAPACK sources carry BSD-2-Clause-compatible terms (MPLAPACK's COPYING also
records the upstream BLAS/LAPACK notices).  The audited system dependencies
are MPC under LGPL-3-or-later, MPFR under LGPL-3-or-later, and GMP under its
GPL-2-or-later/LGPL-3-or-later dual terms.  Their copyright and license
metadata must be carried by Debian packaging rather than bundled by this
repository.  No ABI or SONAME split was found that would require
`octave-mplapack-complex`.

## Decisions and rejected alternatives

| Decision | Selected approach | Rejected alternatives | Reason | Evidence | Future milestone |
|---|---|---|---|---|---|
| complex scalar type | `mpfrxx::mpc_class` | project-local pair wrapper | direct installed backend type and ABI | installed header, static size/alignment assertions, probe | C00 |
| complex matrix storage | contiguous `vector<mpc_class>`, uniform `p` | scalar-wrapper arrays; split per-component public matrices | direct `COMPLEX*`, one matrix precision, immutable payload | type layout and vector probe | C00/C02 |
| public class | one `mp` with four payload kinds | `cmp`/`mpc` public class | preserves Octave syntax and real compatibility | M02--M19 type architecture | C00 |
| precision contract | one equal component precision and one `p_op` | mixed component precision; ambient default | uniform MPLAPACK contract | `with_precision` audit and probe | C01 |
| real/complex promotion | complex result at max precision, exact zero imaginary part | implicit demotion or binary64 round trip | preserves represented values and type stability | M08--M16 policy plus backend API | C03/C11 |
| binary64 complex conversion | direct component MPFR conversion | decimal text conversion | preserves incoming IEEE values | `mpc_class` constructors and real policy | C01 |
| transpose | `.'` transpose, `'` conjugate transpose | treating both as transpose | Octave complex semantics | M12 dispatch and Octave contract | C03 |
| complex GEMM | direct `Cgemm` | four real GEMMs; binary64 fallback | uses validated complex backend and keeps precision | installed symbol and Cgemm probe | C05 |
| complex solve | direct `Cgesv` for square | normal equations or real decomposition | destructive operation-owned complex backend | installed symbol and Cgesv probe | C06 |
| complex Cholesky | Hermitian selected-triangle `Cpotrf` | full symmetry precheck | follows dense `chol` selected-triangle semantics | installed symbol and M17 design | C08 |
| complex QR | installed complex QR factor/generator pair | manual Householder loop | preserves MPLAPACK ownership of algorithms | Cgeqrf/Cungqr probe | C09 |
| packaging | same `octave-mplapack` package update | separate complex package | same SONAME/dependency closure | `pkg-config`, `ldd`, `readelf` audit | PPA series |

## Open issues

| Issue | Severity | Blocks PPA v0.1? | Blocks complex v0.2? | Proposed investigation |
|---|---|---|---|---|
| MPC thread-local override can diverge from MPFR scope | medium | no | yes | C00/C01 scope probe; explicitly set or reject overrides |
| Exact complex text grammar and pretty display | medium | no | yes | C01/C02 Octave constructor/display audit |
| Complex worker behavior in optimized MPLAPACK | high | no | yes | audit each enabled optimized DSO before C05 |
| Complex rank-revealing driver precision/workspace | high | no | yes | C07 candidate comparison (`Cgelsy/Cgelss/Cgelsd`) |
| Debian license metadata for system MPC/MPFR/GMP | low | no | no | P01 packaging review |
| Complex special-value and ordered-comparison policy | medium | no | yes | C03/C04 Octave differential tests |

## Release decision and roadmap

The complex audit found no representation, ABI, or dependency issue that blocks
the real-only package.  The explicit release decision is:

```text
REAL-PPA-GO
```

Real-only PPA work can proceed independently; complex remains future work.

### Real/PPA sequence

```text
M21  real LU factorization
M22  real API/release closure
M23  v0.1 feature freeze
PPA1 MPLAPACK Debian packaging
PPA2 octave-mplapack Debian packaging
PPA3 Launchpad staging build
PPA4 public real-only v0.1 PPA
```

### Complex sequence

```text
C00  complex scaffold / native storage
C01  complex scalar constructor and conversion
C02  complex dense matrix storage/indexing/display
C03  real/imag/conj/transpose/ctranspose
C04  complex element-wise arithmetic
C05  complex GEMM
C06  complex square solve
C07  complex rank-revealing rectangular solve
C08  Hermitian Cholesky
C09  non-pivoted complex QR
C10  pivoted complex QR
C11  mixed real/complex closure
C12  complex package/regression release
```

M20 deliberately does not begin either sequence.
