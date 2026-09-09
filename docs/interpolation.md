# Arbitrary-precision interpolation

The interpolation surface is split into the closed scalar-output 1-D core
and the closed 2-D grid core:

- [`interpolation-1d.md`](interpolation-1d.md) documents `interp1`, `pchip`,
  `spline`, `ppval`, `mkpp`, `unmkpp`, `ppder`, and `ppint`.
- [`interpolation-2d.md`](interpolation-2d.md) documents `interp2`.
- Matrix-valued PP output and N-D interpolation are deferred; see
  [`todo/T10-matrix-valued-pp.md`](todo/T10-matrix-valued-pp.md) and
  [`todo/T11-ND-interpolation.md`](todo/T11-ND-interpolation.md).

Both closed cores retain MPFR/MPC values and do not convert grids or query
points through binary64.
