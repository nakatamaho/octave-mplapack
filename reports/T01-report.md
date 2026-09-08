# T01 report — advanced dense utilities

## Result

`T01 PASS — ADVANCED DENSE UTILITIES CLOSED`

T01 adds arbitrary-precision implementations of `pinv`, `null`, `orth`,
`rref`, and two-dimensional `kron` for real and complex `mp` values.  The
implementation stays on the existing MPFR/MPC SVD and matrix-operation paths;
it does not route real-only operations through a binary64 complex fallback.

## Numerical contract

* `pinv` uses the existing arbitrary-precision SVD and gates the four
  Moore–Penrose identities.  Its default cutoff is supplied by the existing
  p_op-aware `rank` implementation; an explicit MPFR tolerance is accepted.
* `null` and `orth` use the arbitrary-precision SVD and verify null-space,
  orthonormality, and range-projector identities.
* `rref` uses MPFR/MPC scalar arithmetic with scaled pivot selection and
  source-precision-aware tolerance.  The two-output form returns pivot
  columns, and explicit tolerances are validated as nonnegative real scalars.
* `kron` constructs every output element with `mp` arithmetic and preserves
  complex values without a host binary64 conversion.

## Focused evidence

`test/t01_dense_utilities.tst` passed at 256 bits and included:

* all four Moore–Penrose identities and explicit-tolerance `pinv`;
* rank-deficient null-space and range/projector checks;
* one- and two-output `rref`, explicit tolerance, and real/complex `kron`;
* source-precision-sensitive `rref` fixtures at 1024 bits (`2^-700`) and
  2048 bits (`2^-1500`).

## Required real regression wall

`test/run_tests.m` passed the complete existing M00–M23, C00–C12 including
C11L, N00–N08, S00–S08, and T00/T01 tests.

## Commit

The T01 implementation, focused wall, status, and report are committed on the
dedicated continuation branch.  D03 remains immutable and D04 remains the
release-freeze owner.
