# T04 report — exact set operations

## Result

`T04 PASS — EXACT SET OPERATIONS CLOSED`

T04 adds exact arbitrary-precision `unique`, `union`, `intersect`, `setdiff`,
`setxor`, and `ismember` methods.  Values are compared as MPFR/MPC values;
no binary64 hash key or double conversion is used.

## Controller metadata

| Field | Value |
|---|---|
| Repository | `octave-mplapack` |
| Branch | `topic/t00-t14-continuation` |
| Starting commit | `f5bcf792c07f8e1171546937cdf022c89c04c88a` |
| Implementation commit / tip | `9e8bba0c40448ac76b727bfbf0a92090d198d5a7` |
| D03 baseline | `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31`, tag `v0.4.0` |
| Dependencies | gmpfrxx_mkII `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1`; MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` |
| Octave | GNU Octave 11.1.0 |
| API scope | Exact dense `unique`, `union`, `intersect`, `setdiff`, `setxor`, `ismember` |
| Backend / algorithm | Native MPFR/MPC equality, ordering, rows, stable forms, and index construction |
| Precision policy | Exact stored-value comparisons with native NaN/Inf/signed-zero handling |
| Real/complex behavior | Real ordering stays real; complex equality/order uses native policy; no binary64 fallback |
| Octave differential QA | Sorted/stable/rows/index outputs and NaN/Inf/signed-zero fixtures |
| 1024/2048 QA | Precision wall and ambient-scope checks PASS |
| Sanitizers | Native ASan, UBSan, and LSan walls PASS in final controller run |
| Previous regression | T00–T03 and D03 M00–M23/C00–C12/S00–S08 walls passed |
| Status / TODO | PASS; `ismembertol`: `docs/todo/T04-ismembertol.md` |

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
