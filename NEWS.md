# News

## mplapack-interop 0.5.0-dev (2026-09-08)

The T00–T14 development line closes the advanced arbitrary-precision surface
for Schur/QZ, dense utilities, matrix functions, polynomial helpers, exact
sets, serialization, three-dimensional graphics boundaries, random
generation, 1-D/2-D interpolation, nonlinear equations, scalar quadrature,
and bounded/simplex optimization. All numerical paths retain the
one-operation/one-precision MPFR/MPC contract and reject unsupported calls
instead of falling through to builtin binary64 implementations.

The final T-series wall passed M00–M23, C00–C12 including mandatory C11L,
N00–N08, S00–S08, and T00–T14, with 1024/2048-bit canaries, package
lifecycle, and native ASan/UBSan/LSan coverage. The current development
surface and deferred re-entry records are in
`docs/advanced-numerics-compatibility.md` and `docs/todo/`.

## 0.4.0

S00 begins the ordinary Octave script-compatibility series with native
arbitrary-precision `abs`, `arg`, `angle`, and `sign`, special-value
predicates, exact `isequal`/`isequaln`, and the `isnumeric` class predicate.
S01 adds native MPFR/MPC element-wise power, integer square-matrix powers, and
the audited elementary-function family with exact real-domain promotion.
S02 adds native MPFR/MPC `sum`, `prod`, `sumsq`, `cumsum`, and `cumprod`, plus
`min`/`max` with dimensions, NaN controls, cumulative direction, indices, and
supported complex comparison methods. The 0.3.1 source release remains
immutable. S05 adds native MPFR/MPC sequence generation, rounding, spacing,
and utility arithmetic. S06 adds native descriptive statistics. S07 adds the
common line-graphics boundary wrappers with conversion limited to the final
graphics call. S08 closes the ordinary dense script corpus with native
`sort`/`diff`, structural audits, precision canaries, and explicit firewall
coverage for deferred surface graphics. No numerical path uses an implicit
binary64 fallback.
S03 adds native MPFR/MPC comparisons, logical conversion and element-wise
logical operators, `any`/`all`, `find`, general numeric linear indexing, and
logical indexing/assignment. Ordered comparisons remain explicitly rejected
for complex values; no comparison or logical path uses builtin binary64
complex arithmetic. S04 adds native dense `diag`, `triu`/`tril`, `repmat`,
row/column flips, `rot90`, `cat(1/2)`, and `zeros`/`ones`/`eye`/`NaN`/`Inf`
`"like"` constructors. The dense two-dimensional contract and explicit
rejection of packed triangular output remain in force.

## 0.3.1

N08 adds dense real and complex matrix right division with `/`, including
scalar forms, mixed `mp`/double operands, rectangular least-squares solves,
rank-deficient minimum-norm results, and the complex conjugate-transpose
identity. Existing `mldivide` square-singular error behavior is unchanged;
right division uses a private rank-revealing retry for Octave-compatible
singular results. All paths preserve one-operation/one-precision MPFR/MPC
semantics and operation-owned destructive-call buffers.

## 0.3.0

This release completes the numerical API after the frozen 0.2.1 package
identity. N00 adds native arbitrary-precision `norm` support; all operation
paths preserve stored MPFR/MPC precision and avoid binary64 fallbacks.

N05 adds dense general standard `eig` through MPLAPACK `Rgeevx`/`Cgeevx`,
including balance/nobalance controls, right and left eigenvectors, permanent
Grcar coverage, and high-precision real conjugate-pair conversion.

N06 adds dense generalized `eig(A,B)` through the definite
`Rsygvd`/`Chegvd` and QZ `Rggev`/`Cggev` drivers. It supports Octave-compatible
`chol`/`qz` algorithm selection, matrix/vector eigenvalue layouts, left
eigenvectors, singular-B infinite eigenvalues, mixed real/complex promotion,
and 1024/2048-bit precision canaries without binary64 fallback.

N07 closes the documented dense real/complex API surface, adds the permanent
high-precision Grcar example, and records the compatibility firewall. The
0.3.0 source archive and tag are created only after the complete freeze
regression and reproducibility gates pass.

## 0.2.1

The GNU Octave package public identity is now `mplapack-interop`, version
`0.2.1`.  The rename avoids presenting the Octave package as the MPLAPACK
upstream project; the repository remains `octave-mplapack` and the public
numeric API remains `mp`, `mpbits`, and `mpdigits`.  Existing `mplapack` 0.2.0
source/tag/archive provenance is retained as a historical release and is not
an alias for the new package.

The release documentation adds an Octave high-precision Hilbert inverse
example.  The inverse is computed as `H \\ I`, because `inv(mp)` is
intentionally outside the public API and the example must not pass through
binary64 `hilb(n)` construction.  The separate MPLAPACK public-header
consumer is covered by MPLAPACK release QA and is not copied into this
package's examples.

## 0.2.0

The first public real-plus-complex release adds dense complex `mp` scalars and
matrices with explicit MPFR/MPC precision semantics. It provides mixed
real/complex construction, arithmetic, structure and indexing operations,
MPLAPACK `Cgemm`, `Cgesv`, `Cgelsy`, `Cpotrf`, `Cgeqrf`/`Cungqr`, `Cgeqp3`, and
`Cgetrf`, including the mandatory complex LU path. Destructive backend calls
use operation-owned copies, real-only operations remain on real MPLAPACK
paths, and no builtin binary64 complex fallback is used.

The release dependency stack is `gmpfrxx_mkII 1.4.1`, MPLAPACK `3.0.1`, and
this package `0.2.0`. Exact source commits, tags, archives, checksums,
licenses, and isolated-build evidence are recorded in
`docs/dependency-release-stack.md` and `reports/D00-report.md`.

## 0.1.0

The frozen first release candidate is a dense real arbitrary-precision Octave
package. It provides MPFR scalar and matrix construction with explicit
bit/digit precision control, precision-preserving arithmetic and structural
operations, dense `Rgemm` multiplication, square and rank-revealing
`Rgesv`/`Rgelss` left division, and `Rpotrf`, `Rgeqrf`/`Rorgqr`, `Rgeqp3`, and
`Rgetrf` factorizations. Indexing and assignment preserve native value
semantics. The source archive, dependency probe, installed-package lifecycle,
and full sanitizer/precision QA are release-ready for PPA handoff.

The v0.1.0 scope is intentionally limited: complex, sparse, N-D, reductions,
general transcendentals, determinant, inverse, rank, condition, norm,
eigenvalue, SVD, and update APIs are not included. `qr(A,B)` and sparse
factorization forms are also deferred. Ubuntu PPA packaging and the final
release tag occur after this upstream freeze.

## Development history before 0.1.0

- Bootstrapped the repository, package metadata, project contracts, and
  milestone plan.
- Planned MPFR real arithmetic as the first MPLAPACK backend.
- Added the private `__mplapack_core__.oct` module and public
  `mplapack_version()` diagnostic.
- Added an MPLAPACK MPFR `Rlamch_mpfr` runtime probe, dependency/linkage QA,
  deterministic source-package generation, and isolated package-install QA.
- Added internal RAII-backed MPLAPACK MPFR scalar storage with explicit
  per-object precision and immutable Octave custom-value ownership.
- Added deep-copy, module-lifetime, sanitizer, clear/shutdown, and installed-
  package lifecycle QA for the internal native value.
- Added the public scalar `mp` class with direct decimal-text and exact
  binary64 constructors.
- Added signed-zero and special-value preservation, matrix-construction
  firewalls, and installed public-wrapper lifecycle QA.
- Added public bit-precision control through `mpbits` with a 512-bit fresh-
  session default.
- Added decimal-digit convenience control through `mpdigits`, using certified
  upward conversion with no hidden guard bits.
- Added canonical, source-precision round-trip decimal conversion for scalar
  `mp` values.
- Added explicit round-to-nearest IEEE binary64 conversion and canonical
  scalar multiprecision display.
- Added scalar `mp` addition and subtraction, scalar element-wise
  multiplication and division, and unary signs.
- Added mixed `mp`/binary64 scalar arithmetic with operand-derived precision
  and explicit MPFR round-to-nearest semantics.
- Added one-native-object dense MPFR matrix storage with uniform precision and
  contiguous column-major layout.
- Added construction from real double matrices and decimal-text cell matrices,
  including shape-preserving empty matrices and public shape metadata.
- Added dense real matrix `mtimes` through the MPLAPACK MPFR reference
  `Rgemm` path, with operand-derived uniform operation precision and native
  scalar/matrix scaling.
- Synchronized `mpbits`/`mpdigits` with the current-thread MPFR default for
  the MPLAPACK uniform-precision calling contract.
- Added dense real `mp` linear solve through MPLAPACK MPFR `Rgesv`, including
  multiple right-hand sides and operation-owned factorization buffers.
- Added read-only dense matrix indexing with `end`, precision-preserving
  matrix-to-double conversion, and canonical matrix display.
- Added dense matrix element-wise `+`, `-`, `.*`, and `./`, unary signs, and
  two-dimensional singleton expansion using direct MPFR arithmetic.
- Added precision-preserving dense matrix transpose, conjugate transpose for
  real values, and two-dimensional column-major `reshape`, including one
  inferred dimension.
- Added native dense real `mp` horizontal and vertical concatenation with
  arbitrary operand counts, mixed precision, mixed real-double inputs, and
  Octave-compatible supported empty-shape behavior. Concatenation returns one
  immutable native `mp` value and never an array of scalar wrappers.
- Added in-bounds dense real `mp` indexed assignment with value semantics,
  precision-preserving deep copies, scalar/row/column/submatrix and colon
  assignment, and direct binary64 RHS insertion. Matrix growth, deletion,
  logical assignment, and general vector linear assignment remain deferred.
- Added full-rank rectangular dense real `mp` left division through MPLAPACK
  MPFR `Rgels`, including QR/LQ paths, multiple right-hand sides, padded
  operation-owned RHS storage, and checked workspace queries. Rank-revealing
  rectangular solving remains deferred.
- Added rank-revealing rectangular dense real `mp` left division through the
  validated MPLAPACK MPFR `Rgelss` driver. Rectangular systems now return
  minimum-norm least-squares solutions for rank-deficient and full-rank cases,
  with precision-derived `RCOND`, checked workspace queries, and uniformly
  operation-precision work buffers. Square systems retain the `Rgesv` path.
- Matrix logical indexing, matrix `char`, general `cat`, comparisons, powers,
  and reductions remain unimplemented.
- Added dense real `mp` Cholesky factorization through MPLAPACK MPFR `Rpotrf`,
  with upper/lower selected-triangle semantics, optional status output,
  precision-preserving operation-owned copies, and immutable public values.
- Added non-pivoted dense real `mp` QR factorization through MPLAPACK MPFR
  `Rgeqrf`/`Rorgqr`, including one-output `R`, full/economy two-output forms,
  deprecated numeric-zero economy compatibility, and precision-preserving
  immutable operation-owned buffers.
- Added dense real column-pivoted `mp` QR through MPLAPACK MPFR `Rgeqp3` and
  `Rorgqr`, with Octave-compatible matrix/vector permutation outputs,
  full/economy forms, precision-safe JPVT handling, and immutable
  operation-owned buffers. Non-pivoted one/two-output QR remains unchanged.
- Added the M20 complex architecture audit and design freeze. The installed
  `mpfrxx::mpc_class` backend, uniform-precision contract, future payload
  variants, complex routine inventory, and real-only PPA boundary are
  documented; public complex `mp` values remain unimplemented.
- Added dense real `mp` LU factorization through MPLAPACK MPFR `Rgetrf`, with
  packed one-output factors, permutation-aware two/three-output forms,
  1-based vector pivots, rectangular and singular support, and immutable
  operation-owned precision-safe buffers.
