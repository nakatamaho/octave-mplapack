# octave-mplapack

**Status: 0.4.0-dev development; 0.3.1 is frozen and 0.3.0/0.2.1 are historical.**
C00 through C12 pass, including mandatory complex `Cgetrf` LU, and the public
complex API is closed. N08 adds dense right division. The package identity is
`mplapack-interop`; the public GNU Octave class/API remains `mp`, `mpbits`, and
`mpdigits`.
The real-only v0.1.0 release candidate remains historical. The historical D00
stack is recorded in [`docs/dependency-release-stack.md`](docs/dependency-release-stack.md);
the forward `mplapack-interop` handoff is in
[`docs/dependency-release-stack-r1.md`](docs/dependency-release-stack-r1.md).
N00–N08 and the 0.3.1 source freeze are tracked in the D02R1 release records;
the S00–S08 script-compatibility work is tracked in the S-series records;
the 0.2.1 package remains historical provenance.
The package provides a public real `mp` scalar and dense matrix with
native MPFR storage, public default-precision control, canonical scalar text,
explicit binary64 conversion, scalar display, and native scalar/dense
element-wise `+`, `-`, `.*`, and `./`. Dense matrices use one private
column-major contiguous native payload;
`mtimes` uses MPLAPACK MPFR `Rgemm` under a uniform operation-precision
calling scope. Dense matrix inspection is read-only and preserves stored MPFR
precision. M12 adds precision-preserving transpose and two-dimensional
reshape. M13 adds native horizontal and vertical concatenation that returns
one dense `mp` value. M14 adds value-semantic, in-bounds indexed assignment
with precision-preserving native copies. M18 adds non-pivoted dense real QR
through MPLAPACK MPFR `Rgeqrf`/`Rorgqr`; one-output `qr(A)` returns `R` and
two-output forms return `Q,R` with full or economy shapes. M19 adds
three-output column-pivoted QR through `Rgeqp3`, with builtin-double
permutation matrix/vector outputs.
M20 audits the installed MPLAPACK MPFR complex backend and C01–C12 implement
complex scalar/matrix values, mixed real/complex operations, Cgemm/Cgesv/
Cgelsy/Cpotrf/Cgeqrf/Cgeqp3/Cgetrf paths, structural operations, and the
compatibility firewall. See [`docs/complex-api.md`](docs/complex-api.md) and
[`docs/complex-compatibility.md`](docs/complex-compatibility.md).
M21 adds dense real LU through MPLAPACK MPFR `Rgetrf`, including packed,
two-output, row-permutation-matrix, and 1-based permutation-vector forms for
square, rectangular, and singular matrices. See [`docs/lu.md`](docs/lu.md).
N00 adds arbitrary-precision `norm`; N01 adds dense real/complex `det` and
`inv` through stored-precision `Rgetrf`/`Rgetri` and `Cgetrf`/`Cgetri` paths;
N02 adds dense real/complex `svd` through `Rgesvd`/`Cgesvd`; N03 adds
`rank`, `cond`, and `rcond` through MPFR/MPC singular values and
`Rgecon`/`Cgecon`; N04 adds structured symmetric/Hermitian `eig` through
`Rsyevd`/`Cheevd`; N05 adds general standard `eig` through `Rgeevx`/`Cgeevx`,
including balance controls and left eigenvectors. N06 adds generalized
standard eig through definite `Rsygvd`/`Chegvd` and QZ `Rggev`/`Cggev`, with
Octave-compatible `matrix`/`vector` layouts and left eigenvectors.

M22 closed the real-only API and M23 froze the v0.1.0 release candidate for
PPA packaging. See the [v0.1 API inventory](docs/v0.1-api.md),
[Octave compatibility notes](docs/octave-compatibility.md), and
[release checklist](docs/release-checklist.md) and the repository-only release
manifest.

## Goal

`mplapack-interop` provides GNU Octave access to MPLAPACK multiple-precision
linear algebra through an Octave-native multiprecision numeric type named
`mp`. MPLAPACK is the numerical backend rather than the user-facing
programming model.

## Quick start

Install a locally built source archive with Octave's package manager
(the public PPA is planned, not yet available):

```text
octave:1> pkg install mplapack-interop-0.3.1.tar.gz
octave:2> pkg load mplapack-interop
```

For a checkout, `tools/dev-octave.sh` verifies the `pkg-config` dependency,
builds the native module, and starts a configured development session. It does
not replace clean package/install QA.

The current surface includes dense real and complex `mp`, precision-controlled
construction, arithmetic, mixed real/complex `*`, `\`, and `/`, indexing and
in-bounds assignment, `chol`, full/economy and pivoted `qr`, `lu`, `norm`,
`det`, `inv`, `svd`, `rank`, `cond`, `rcond`, structured and general standard
and generalized `eig`, dense concatenation, element-wise power, integer
matrix powers, and native elementary functions. Sparse, N-D, reductions,
and comparison/logical APIs remain explicitly unsupported; see the [complex API](docs/complex-api.md) and [compatibility
limits](docs/complex-compatibility.md).

### Hilbert inverse example

The package includes a 1024-bit Hilbert inverse example in
[`examples/05_hilbert_inverse.m`](examples/05_hilbert_inverse.m). It constructs
each `1/(i+j-1)` from decimal `mp` values and computes all inverse columns as
`H \ I`; this avoids the binary64 matrix produced by builtin `hilb(n)`. N01
also provides the explicit `inv(H)` API.

The external MPLAPACK C++ consumer boundary is validated separately by the
MPLAPACK release QA. Its source is intentionally not copied into this Octave
package's examples.

The required MPLAPACK MPFR dependency is discovered through `pkg-config` and
must provide the uniform-precision scope interface. The package never vendors
or searches a developer-specific MPLAPACK path.

## Initial backend

The backend is MPLAPACK's MPFR/MPC implementation for real and complex values.
MPLAPACK remains a separately installed dependency discovered through
`pkg-config`; it is not vendored here.

## Working diagnostic

With the current source package installed:

```octave
pkg load mplapack-interop
info = mplapack_version()

a = mp("0.1");
b = mp(0.1);

mpbits()
% 512

mpdigits(100);
mpbits()
% 333

c = mp("0.1");

s = char(c)
d = double(c)
disp(c)

sum_value = a + b
difference = a - b
product = a .* b
quotient = a ./ b

A = mp ({"1", "2";
         "3", "4"});
B = mp ([1, 2;
         3, 4]);
size (A)
% 2 2
C = A * A
x = A \ b
R = mp ({"1", "0"; "0", "1"; "1", "1"});
r = mp ({"0"; "1"; "4"});
least_squares = R \ r
element = A(2, 1)
column = A(:, 2)
double_A = double(A)
disp(A)
R = chol (mp ({"4", "2"; "2", "10"}));
[Q, R] = qr (mp ([1, 2; 3, 4; 5, 7]));
% native MPLAPACK MPFR Rgemm/Rgesv/Rgelss/Rpotrf/Rgeqrf/Rorgqr/Rgeqp3 results
```

This loads the private native module, reports the Octave, MPLAPACK, and MPFR
versions, and executes the MPLAPACK MPFR `Rlamch_mpfr` probe. The constructor
creates immutable public `1 x 1` scalar values. A fresh process starts at 512
bits. `mpbits` controls the canonical bit precision and `mpdigits(n)` selects
`ceil(n * log2(10))` bits without hidden guard bits. In the example, `a` and
`b` remain 512-bit values while `c` uses 333 bits. `char(c)` returns canonical
decimal text that reconstructs the same MPFR value when parsed at `c`'s
precision. `double(c)` is an explicit, potentially lossy binary64 conversion;
`disp(c)` prints the canonical multiprecision text.

Scalar arithmetic uses MPFR round-to-nearest.  For two `mp` operands the
result precision is the greater stored operand precision; with one real
scalar `double`, the `mp` operand precision is used.  The current default does
not affect an arithmetic result.  For example, `a + 0.1` converts the
already-rounded binary64 operand directly at `a`'s precision and generally
differs from `a + mp("0.1")`.

M07 matrix constructors preserve the same source distinction element by
element.  A real double matrix transfers each existing binary64 value
directly, while a text-cell matrix parses each decimal directly.  Each matrix
has one immutable precision, contiguous column-major MPFR storage, and normal
two-dimensional shape metadata.  M08 implements dense real `A * B` through
MPLAPACK MPFR `Rgemm`, and M09 implements square `A \ B` through `Rgesv`;
M15 extends full-rank rectangular `A \ B` through `Rgels`,
with result precision equal to the maximum operand precision and a temporary
current-thread precision scope. M16 upgrades rectangular `A \ B` to the
rank-revealing MPLAPACK MPFR `Rgelss` path for minimum-norm least-squares
solutions, while square systems remain on `Rgesv`. M10 adds read-only indexing, `double(A)`, and
canonical matrix display. M11 adds native MPFR matrix `+`, `-`, `.*`, and `./`,
unary signs, and two-dimensional singleton expansion. M12 adds read-only
transpose, conjugate transpose for real values, and column-major reshape;
these structural operations preserve source precision and do not consult the
ambient precision default. M17 adds dense real `chol` through MPLAPACK MPFR
`Rpotrf`, including selected-triangle semantics and optional status output,
while preserving immutable source values and stored precision. M18 adds
non-pivoted dense real `qr` through MPLAPACK MPFR `Rgeqrf` and `Rorgqr`;
one-output `qr(A)` returns `R` and two-output forms return `Q,R`. M19 adds
column-pivoted three-output `qr` through `Rgeqp3`, reusing `Rorgqr` for `Q`.
M21 adds dense real `lu` through `Rgetrf`; packed one-output factors,
permutation-aware two/three-output factors, and vector row pivots preserve the
stored operand precision. N00 adds `norm`; N01 adds `det` and `inv` through
stored-precision `Rgetrf`/`Rgetri` and `Cgetrf`/`Cgetri` paths.

## Current feature status

| Feature | Scalar | Dense matrix | Backend | Status |
|---|---:|---:|---|---|
| `+ - .* ./` | yes | yes | MPFR | supported |
| `*` | yes | yes | `Rgemm` | supported |
| `\` | yes | yes | `Rgesv`/`Rgelss` | supported |
| `/` | yes | yes | transpose solve; `Rgesv`/`Rgelss` | supported |
| `chol` | yes | yes | `Rpotrf` | supported |
| `qr` / pivoted `qr` | yes | yes | `Rgeqrf`/`Rgeqp3`/`Rorgqr` | supported |
| `lu` | yes | yes | `Rgetrf` | supported |
| structured `eig` | yes | yes | `Rsyevd`/`Cheevd` | supported |
| complex | yes | yes | `Cgemm`/`Cgesv`/`Cgelsy`/`Cpotrf`/`Cgeqrf`/`Cgeqp3`/`Cgetrf` | supported |
| sparse | no | no | future | deferred |

## Release provenance

The frozen real-only v0.1.0 source candidate remains identified by the full
commit in the repository-only release manifest
(`docs/v0.1-release-manifest.md`). The 0.2.0 release was validated with Octave
11.1.0 and the installed MPLAPACK MPFR interface provided by
`mplapack_mpfr` through `pkg-config`. Binary distribution and PPA work are
separate later milestones.

## Public API baseline

The following workflow is available in the current release line:

```octave
pkg load mplapack-interop

mpdigits(100);

A = mp({"1", "2"; "3", "4"});
b = mp({"1"; "2"});

C = A * A;
x = A \ b;
```

The completed baseline uses normal Octave matrix operations such as indexing,
`\`, and read-only conversion/display. Native backend entry points stay
private.

## Precision warning

These constructors intentionally have different input semantics:

```octave
mp("0.1")
mp(0.1)
```

The string form parses decimal text directly at the target MPFR precision.
The numeric form receives an already-rounded IEEE binary64 value and preserves
that exact value when converting to MPFR. Thus the two `0.1` values above are
intentionally different. See
[`docs/precision-semantics.md`](docs/precision-semantics.md).

## Historical 0.1.0 non-goals

- Wrapping every MPLAPACK routine
- Supporting every MPLAPACK backend
- Complex multiprecision arithmetic (implemented in the 0.2.x line)
- Replacing Octave BLAS/LAPACK
- Transparent conversion of all Octave code to multiprecision
- Complete MATLAB compatibility

## Development roadmap

```text
M00  Bootstrap
M01  Native build probe
M02  Native mp storage
M03  Public scalar constructor
M04  Precision
M05  Conversion/display
M06  Element-wise arithmetic
M07  Matrix storage
M08  Matrix multiplication
M09  Linear solve
M10  Dense matrix inspection
M11  Dense element-wise arithmetic
M12  Dense transpose and reshape
M13  Dense horizontal and vertical concatenation
M14  Dense indexed assignment with value semantics
M15  Full-rank rectangular dense solve
M16  Rank-deficient rectangular minimum-norm solve
M17  Dense real Cholesky factorization
M18  Dense real non-pivoted QR factorization
M19  Dense real pivoted QR factorization
M20  Complex architecture audit and design freeze (no public complex support)
M21  Dense real LU factorization
M22  Real v0.1 API and release closure
M23  v0.1.0 feature freeze and release candidate

D01R1  Rename package identity to mplapack-interop and freeze binary architecture

PPA1-PPA4  Debian/Ubuntu/PPA packaging and final release
```

M00 through M23 and C00 through C12 are complete (M20 is design-only and the
real-only M23 candidate remains historical). No PPA upload exists. Consult
[`docs/milestones/README.md`](docs/milestones/README.md) for gate definitions
and status.
