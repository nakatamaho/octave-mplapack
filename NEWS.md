# News

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
