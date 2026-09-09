# T00 TODO — optional Schur/QZ ordering helpers

## Scope

Optional eigenvalue ordering and selector-callback forms for `schur`/`qz`.

## Why deferred

The closed T00 surface validates decomposition and reconstruction, but did not
freeze Octave's selector syntax, callback invocation, reordering failure
semantics, or generalized-pair ordering contract.

## Current evidence

Real and complex `hess`, `balance`, `schur`, and `qz` reconstruction passed at
the accepted precision canaries. The compatibility firewall rejects the
unimplemented optional forms.

## Required dependency/algorithm

MPLAPACK Schur reordering drivers or a reviewed arbitrary-precision selector
and swap algorithm, with MPFR/MPC-aware separation tests.

## Public API target

Octave-compatible ordered `schur`/`qz` outputs and selector forms without
binary64 conversion.

## Precision requirements

One operation/one MPFR or MPC precision, ambient-scope restoration, and
1024/2048-bit ordering canaries.

## Test requirements

Separated real and complex eigenvalue fixtures, repeated/clustered values,
selector callbacks, reconstruction, failure status, and sanitizer coverage.

## Re-entry milestone

Future T-series milestone after the dense T00 core; not part of T00–T14.
