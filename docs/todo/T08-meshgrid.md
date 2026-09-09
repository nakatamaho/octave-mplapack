# T08 TODO — `meshgrid` boundary audit

## Scope

An MP-aware `meshgrid` wrapper for two-dimensional coordinate grids.

## Why deferred

T08 closes the graphics-call boundary for vector and matrix data but does not
add a public MP `meshgrid` method or freeze its N-D output forms.

## Current evidence

The 3-D graphics wrappers pass vector/matrix fixtures and convert only at the
final graphics call. `meshgrid` with MP arguments remains outside that
surface and must not silently construct through binary64.

## Required dependency/algorithm

Native MPFR/MPC repetition and shape construction using the existing dense
column-major storage; no backend LAPACK dependency is needed.

## Public API target

Two-dimensional real/complex `meshgrid` outputs with Octave-compatible input
forms and precision propagation.

## Precision requirements

Coordinates and repeated outputs retain the selected MPFR/MPC precision.

## Test requirements

Vector/scalar forms, descending and complex coordinates, output shapes,
precision, graphics composition, and firewall/sanitizer coverage.

## Re-entry milestone

Future graphics/structure milestone after N-D policy review; not part of
T00–T14.
