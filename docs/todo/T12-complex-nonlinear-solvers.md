# T12 TODO — complex nonlinear callbacks

## Scope

Complex `fzero`/`fsolve` callback and solver semantics for `mp`/MPC values.

## Why deferred

T12 intentionally closes only real scalar/root and real-system contracts.
Octave's complex `fzero` restrictions, complex `fsolve` Jacobian layout, and
convergence policy were not guessed.

## Current evidence

Real MP callbacks, Newton/backtracking, finite-difference Jacobians, and
precision-aware tolerances pass. Complex callback results are rejected by an
explicit boundary.

## Required dependency/algorithm

Native MPC residual/Jacobian arithmetic, complex finite differences or user
Jacobians, and a reviewed complex convergence/line-search policy.

## Public API target

Octave-compatible complex nonlinear solves with native MPC callbacks and
explicit output metadata.

## Precision requirements

Residuals, Jacobians, steps, stopping tests, and callbacks use one operation
precision; no binary64 fallback is permitted.

## Test requirements

Complex roots/systems, user Jacobians, singular Jacobians, branch-sensitive
callbacks, high precision, ambient scope, rejection, and sanitizers.

## Re-entry milestone

Future nonlinear-solvers milestone after T12; not part of T00–T14.
