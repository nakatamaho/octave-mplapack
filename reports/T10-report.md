# T10 report — one-dimensional interpolation

## Result

`T10 PASS — 1-D INTERPOLATION CLOSED`

T10 was implemented on the T09 head
`1697666a537d67662653d8fd25aec706dc2a315c` on
`topic/t00-t14-continuation` and tested with GNU Octave 11.1.0 and the frozen
MPLAPACK MPFR/MPC backend.

## Implemented surface

- `interp1`: nearest, previous, next, linear, pchip, spline, default NaN
  extrapolation, numeric extrapolation values, `"extrap"`, and compatible
  `"pp"` construction;
- `pchip`: real shape-preserving Fritsch-Carlson slopes and complex weighted
  Hermite slopes;
- `spline`: MP not-a-knot cubic spline coefficients;
- `ppval`: scalar-output MP piecewise-polynomial Horner evaluation with
  extrapolation;
- `mkpp`, `unmkpp`, `ppder`, and `ppint` for the scalar-output PP structure.

The PP schema is a normal serializable struct containing MP `breaks` and MP
`coefs`; coefficients are in descending powers of each interval's local
coordinate.  The shape and no-binary64 boundary are recorded in
`docs/interpolation-1d.md`.

## Focused QA

`test/t10_interpolation.tst` passed all four tests:

- uniform and nonuniform grids, descending-grid normalization, nearest/
  previous/next/linear selection, default and explicit extrapolation, and
  linear PP construction;
- real pchip and not-a-knot spline values, derivative/integral helpers, and
  PP structure unpacking;
- a 1024-bit query containing `2^-700`, whose binary64 conversion is exactly
  one while MP interpolation remains strictly above one, plus complex data;
- custom scalar PP construction and exact derivative/integral checks.

The implementation performs interpolation arithmetic through MPFR/MPC
operator paths.  No builtin double interpolation is called and no MP grid or
query is converted to binary64.

## Required real-regression wall

The complete `test/run_tests.m` wall passed after T10, covering M00–M23,
C00–C12 including C11L, N00–N08, S00–S08, and T00–T10.  Expected warnings
from headless gnuplot and the existing singular-machine-precision fixture
remained non-fatal.

## Controller metadata

| Field | Value |
|---|---|
| Repository / branch | `octave-mplapack` / `topic/t00-t14-continuation` |
| Starting commit / implementation tip | `1697666a537d67662653d8fd25aec706dc2a315c` / `ecb497b93b586427d135f38c51244c6ccdea5fab` |
| D03 baseline | `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31` / `v0.4.0` |
| Dependencies / Octave | gmpfrxx `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1`; MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`; GNU Octave 11.1.0 |
| API / backend | `interp1`, `pchip`, `spline`, `ppval`, `mkpp`, `unmkpp`, `ppder`, `ppint`; native MPFR/MPC PP engine |
| Precision / behavior | grids, queries, coefficients, tolerances, and outputs use operation precision; real/complex native paths |
| Octave QA / 1024-2048 | methods, extrapolation, descending/repeated grids, PP forms; high-precision canaries PASS |
| Sanitizers / previous regression | ASan/UBSan/LSan PASS; T00–T09 and D03 walls retained |
| Status / TODO | PASS; `docs/todo/T10-matrix-valued-pp.md` |
