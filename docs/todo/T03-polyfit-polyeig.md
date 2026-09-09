# T03 TODO — `polyfit` and `polyeig`

## Scope

Arbitrary-precision polynomial fitting and polynomial eigenvalue problems.

## Why deferred

Neither Octave's weighted/optional-output `polyfit` contract nor the
polyeig coefficient layout and conditioning policy was frozen in T03.

## Current evidence

`polyval`, `polyvalm`, `roots`, `poly`, convolution, calculus helpers, and
`compan` pass the T03 wall. The deferred calls are rejected rather than using
binary64 fitting or eigensolvers.

## Required dependency/algorithm

MPFR/MPC QR/SVD least-squares fitting with scaling and covariance outputs;
for `polyeig`, a reviewed companion-linearization algorithm with explicit
singular/infinite-eigenvalue semantics.

## Public API target

Octave-compatible `polyfit` and `polyeig` for dense MP data.

## Precision requirements

Coefficient scaling, residuals, rank decisions, eigenvalues, and optional
outputs must remain at one selected MPFR/MPC precision.

## Test requirements

Exact/noisy fits, rank-deficient Vandermonde systems, complex coefficients,
multiple polynomial degrees, infinite eigenvalues, 1024/2048-bit canaries,
and sanitizer coverage.

## Re-entry milestone

Future polynomial milestone after T03; not part of T00–T14.
