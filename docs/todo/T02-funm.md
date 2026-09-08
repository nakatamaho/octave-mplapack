# T02 TODO — `funm`

## Scope

General matrix function `funm(A, f)` for arbitrary-precision `mp` matrices.

## Why deferred

The T02 matrix-function core closes `expm`, `logm`, and `sqrtm`; it does not
define callback precision, scalar-to-complex promotion, branch handling, or
failure behavior for a user-supplied function.

## Current evidence

The Schur backend and triangular recurrences used by T02 pass real/complex
precision tests. `funm` is not exposed and is blocked by the firewall.

## Required dependency/algorithm

A reviewed Schur/Parlett or blocked-Schur algorithm with MPFR/MPC callback
evaluation and a documented treatment of repeated eigenvalues.

## Public API target

Octave-compatible `funm` with MP scalar callback inputs and MP/MPC output.

## Precision requirements

All Schur, recurrence, callback, stopping, and residual calculations use the
selected operation precision; no builtin binary64 callback is permitted.

## Test requirements

Diagonal, repeated, defective, real-to-complex, branch-sensitive, high-
precision, ambient-scope, rejection, and sanitizer tests.

## Re-entry milestone

Future matrix-functions milestone after T02; not part of T00–T14.
