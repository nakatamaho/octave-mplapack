# T13 TODO — array-valued quadrature

## Scope

`integral`/`quadgk` with `ArrayValued` callbacks and shape-preserving outputs.

## Why deferred

T13 closes scalar MP callbacks only. It does not define vector/matrix
accumulation, output shape validation, mixed real/complex arrays, or
componentwise error estimates.

## Current evidence

Finite, infinite, waypoint, endpoint-singular, complex scalar integrals and
MP tolerances pass. `ArrayValued` is explicitly rejected; it is not routed to
Octave's binary64 quadrature.

## Required dependency/algorithm

Shape-aware native MPFR/MPC tanh-sinh accumulation with per-component or
norm-based error control and a documented callback contract.

## Public API target

Octave-compatible array-valued callbacks with stable output shape and
arbitrary-precision results.

## Precision requirements

Nodes, weights, callback values, accumulators, tolerances, and error estimates
remain at one selected MPFR/MPC precision.

## Test requirements

Vector/matrix real and complex callbacks, shape mismatch, waypoints,
infinite/endpoints, cancellation, 1024/2048-bit canaries, and sanitizers.

## Re-entry milestone

Future quadrature milestone after T13; not part of T00–T14.
