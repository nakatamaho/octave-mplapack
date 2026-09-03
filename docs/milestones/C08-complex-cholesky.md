# C08 — Hermitian Cholesky via `Cpotrf`

## Mission

Extend dense `mp` `chol`, `chol(A,"upper")`, `chol(A,"lower")`, and the
two-output status form to complex matrices while preserving the real
`Rpotrf` path and M17 status semantics.

## Semantics

- `upper` makes only the upper triangle authoritative and factors
  `H = R' * R`;
- `lower` makes only the lower triangle authoritative and factors
  `H = L * L'`;
- the ignored triangle is not checked for agreement or read as input;
- diagonal imaginary components are ignored by the Hermitian Cholesky
  contract and the returned diagonal is real;
- non-positive-definite input returns the same partial factor and positive
  status for two-output callers; one-output callers retain the established
  `mplapack:mp:NotPositiveDefinite` error;
- real-only `chol` remains on the existing `Rpotrf` implementation.

## Backend and precision

The installed MPFR declaration of `Cpotrf` uses `mpc_class` storage and
`mplapackint` dimensions/status. The controlled reference source is
`mplapack/reference/Cpotrf.cpp`, which calls the reference complex Hermitian
BLAS and recursive factor routines. The operation copies the input before
the destructive call, establishes `MpfrMpcPrecisionScope(p_op)`, checks the
MPFR/MPC precision contract before and after the call, and clears the
non-selected output triangle.

For this single-input operation, `p_op` is the stored input precision. All
matrix elements and the factor use that precision; ambient `mpbits` does not
control the calculation.

## Gates

`G-C08-UPSTREAM`, `G-C08-HERMITIAN`, `G-C08-SELECTED-TRIANGLE`,
`G-C08-UPPER`, `G-C08-LOWER`, `G-C08-NONPD`, `G-C08-STATUS`,
`G-C08-PRECISION`, `G-C08-IMMUTABILITY`, and `G-C08-REAL-CHOL-PARITY`: PASS.

## Required QA

Native ASan/UBSan/LSan coverage checks upper/lower factor values, arbitrary
ignored triangles, diagonal imaginary behavior, partial factors and status,
non-square rejection, operation-owned input safety, empty shapes, ambient
scope restoration, and 1024-bit `2^-700` / 2048-bit `2^-1500` positive-definite
tails. Public tests cover the same behavior plus one-/two-output semantics and
real Cholesky regression parity. The full native real and complete public
M01–M23 plus C01–C08 walls pass.

## Result

C08 PASS. Proceed to C09: non-pivoted complex QR.
