# T02 report — matrix functions

## Result

`T02 PASS — MATRIX FUNCTIONS CLOSED`

T02 adds matrix-valued `expm`, `sqrtm`, and `logm` methods for arbitrary-
precision real and complex `mp` values.  These are separate from the
element-wise functions and keep all matrix arithmetic in MPFR/MPC storage.

## Algorithms and contract

* `expm` uses precision-adaptive scaling and squaring with a Taylor series.
  The series is terminated using MPFR `eps` at the current result scale, so a
  fixed-degree approximant cannot cap accuracy at high source precision.
* `sqrtm` computes a complex Schur form through the T00 backend and applies
  the upper-triangular square-root recurrence.  Real matrices with negative
  eigenvalues are allowed to produce complex results.
* `logm` uses inverse scaling by repeated Schur-form square roots followed by
  a Mercator series.  Its stopping threshold is derived from MPFR `eps` at the
  current result scale and the source precision, rather than a host epsilon or
  a fixed binary64 threshold.
* `sqrtm(A)` supports the optional residual output.  `logm(A)` retains the
  optional residual output as an arbitrary-precision matrix norm.

## Focused evidence

`test/t02_matrix_functions.tst` passed zero, diagonal, inverse-pair,
commuting, nonnormal, negative-spectrum square-root, and
`expm(logm(A))` cases at 256 bits.  The high-precision wall also passed
1024-bit `2^-700` and 2048-bit `2^-1500` canaries with precision metadata
preserved.

## Required real regression wall

`test/run_tests.m` passed M00–M23, C00–C12 including C11L, N00–N08, S00–S08,
and T00–T02.

## Scope

General `funm` is explicitly deferred by the T-series goal and is not part of
T02.
