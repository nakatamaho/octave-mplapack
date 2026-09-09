# T14 TODO — `fminunc`

## Scope

Unconstrained arbitrary-precision `fminunc` for scalar real MP objectives.

## Why deferred

T14 closes bounded golden-section and Nelder-Mead optimization. It does not
freeze gradient/Jacobian options, finite-difference steps, trust-region or
line-search behavior, termination metadata, or complex-objective semantics.

## Current evidence

`fminbnd` and `fminsearch` pass quadratic, Rosenbrock, badly scaled, and
high-precision objective tests. `fminunc` is rejected by the firewall rather
than delegated to builtin binary64 optimization.

## Required dependency/algorithm

An MPFR/MPC gradient/Jacobian path with p-aware finite differences and a
reviewed trust-region or line-search algorithm; user callbacks must receive
and return native MP values.

## Public API target

Octave-compatible real `fminunc` with documented options, gradients,
Jacobian/output metadata, and explicit complex policy.

## Precision requirements

Coordinates, objective/gradient values, steps, norms, tolerances, and stopping
tests use one selected MPFR/MPC precision without binary64 fallback.

## Test requirements

Convex/nonconvex/scaled problems, analytic and finite-difference gradients,
termination/options, failure cases, 1024/2048-bit canaries, ambient scope,
and sanitizers.

## Re-entry milestone

Future optimization milestone after T14; not part of T00–T14.
