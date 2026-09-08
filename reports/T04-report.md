# T04 report — exact set operations

## Result

`T04 PASS — EXACT SET OPERATIONS CLOSED`

T04 adds exact arbitrary-precision `unique`, `union`, `intersect`, `setdiff`,
`setxor`, and `ismember` methods.  Values are compared as MPFR/MPC values;
no binary64 hash key or double conversion is used.

## Supported forms

The implementation covers the normal sorted order, stable order, rows mode,
and documented index outputs for the set operations.  `ismember` preserves
the shape of the query input and implements exact rows matching.  Complex
ordering uses the existing native magnitude/phase ordering, while equality
remains component-exact.

## Edge-case evidence

The focused wall passed duplicate, empty, real, complex, rows, index-output,
NaN, Inf, and signed-zero cases at 256/512-bit precision.  Set operations use
Octave's `isequal` policy: NaNs remain distinct and `ismember` does not report
a NaN as present, while signed zero values collapse as exact MPFR numeric
equality requires.

## Required real regression wall

`test/run_tests.m` passed M00–M23, C00–C12 including C11L, N00–N08, S00–S08,
and T00–T04.

## Explicit defer

`ismembertol` remains a separate tolerance-semantics API and is not part of
T04.
