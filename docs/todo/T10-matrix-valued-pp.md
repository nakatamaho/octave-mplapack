# T10 TODO — matrix-valued piecewise polynomials

## Scope

Matrix-valued `y`/coefficient outputs for `interp1`, `pchip`, `spline`, and
the PP helper family.

## Why deferred

T10 deliberately freezes scalar-output PP layout and does not define the
coefficient ordering, output shape, or complex matrix-valued callback contract.

## Current evidence

Scalar-output `interp1`, `pchip`, `spline`, `ppval`, `mkpp`, `unmkpp`, `ppder`,
and `ppint` pass with MPFR/MPC values. Matrix-valued PP forms remain
firewall-rejected.

## Required dependency/algorithm

Extend the native PP schema and Horner engine with explicit multidimensional
shape metadata; no conversion to double is allowed.

## Public API target

Octave-compatible matrix-valued PP construction, evaluation, differentiation,
and integration.

## Precision requirements

Every coefficient and result retains the selected MPFR/MPC precision and
ambient precision is restored after callbacks/operations.

## Test requirements

Vector-, matrix-, and complex-valued data, all methods, extrapolation, PP
round-trip, derivative/integral shape, 1024/2048-bit cases, and sanitizers.

## Re-entry milestone

Future interpolation milestone after T10; not part of T00–T14.
