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
