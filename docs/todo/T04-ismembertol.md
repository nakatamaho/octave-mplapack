# T04 TODO — `ismembertol`

## Scope

Tolerance-based set membership for real and complex arbitrary-precision
values.

## Why deferred

The exact T04 set contract does not define Octave's `ByRows`,
`OutputAllIndices`, absolute/relative tolerance, NaN, signed-zero, or
complex-distance policy.

## Current evidence

`unique`, `union`, `intersect`, `setdiff`, `setxor`, and `ismember` pass exact
real/complex edge cases. `ismembertol` is explicitly rejected.

## Required dependency/algorithm

Native MPFR/MPC distance and bucket/search logic with an overflow-safe,
precision-aware tolerance comparison; no double hash key.

## Public API target

Octave-compatible `ismembertol` forms, including row and index outputs.

## Precision requirements

Tolerance and all distance comparisons use the selected operation precision,
with stored precision preserved and ambient precision restored.

## Test requirements

Absolute/relative tolerance boundaries, rows, duplicates, NaN/Inf,
signed-zero, complex distance, high precision, and sanitizer tests.

## Re-entry milestone

Future exact-set extension milestone after T04; not part of T00–T14.
