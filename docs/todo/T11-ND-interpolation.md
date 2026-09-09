# T11 TODO — N-D interpolation

## Scope

`interp3`, `interpn`, and general N-D grid/query interpolation.

## Why deferred

The current public `mp` contract is dense and two-dimensional. N-D
interpolation needs an explicit N-D storage, indexing, mesh-grid, singleton
expansion, and query-shape contract before it can be implemented safely.

## Current evidence

T11 `interp2` passes vector and mesh-style grids, descending axes, complex
values, extrapolation, and MP queries. N-D calls are firewall-rejected and do
not fall through to builtin binary64 interpolation.

## Required dependency/algorithm

N-D MPFR/MPC storage and shape operations, plus tensor-product or simplex
interpolation with native p-aware extrapolation and error behavior.

## Public API target

Octave-compatible `interp3`/`interpn` forms, grid orientations, query shapes,
methods, extrapolation, and output precision.

## Precision requirements

All grid coordinates, queries, weights, coefficients, and results use one
operation precision with ambient-precision restoration.

## Test requirements

Vector/matrix/N-D grids, descending/repeated axes, nearest/linear/pchip/spline
where supported, real/complex values, extrapolation, shape errors,
1024/2048-bit canaries, and sanitizers.

## Re-entry milestone

Future N-D storage/interpolation milestone after T11; not part of T00–T14.
