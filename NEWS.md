# News

## 0.1.0-dev

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
