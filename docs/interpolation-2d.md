# Two-dimensional interpolation

`interp2` supports the 2-D MP grid boundary for vector grids, mesh-style
matrix grids, MP query points, real or complex data, and `nearest`, `linear`,
`pchip`, and `spline` methods.  The three-argument `interp2(z,xi,yi)` form
uses exact MP integer coordinates.  Numeric inputs are promoted to MP at the
selected precision; MP coordinates and queries never pass through binary64.

The data matrix has rows corresponding to the y axis and columns corresponding
to the x axis.  Descending axes are normalized together with the data matrix,
and repeated grid coordinates are rejected.  Linear interpolation uses an
MP bilinear formula.  The pchip and spline modes apply the T10 scalar PP
engine first along x for each row and then along y, preserving complex values
through MPC operations.

Default out-of-range results are MP NaNs.  A numeric extrapolation value or
the `"extrap"` option is accepted; with `"extrap"`, the selected interpolation
formula is evaluated outside the grid.
