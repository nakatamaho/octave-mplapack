# One-dimensional interpolation

The package provides MP-aware `interp1`, `pchip`, `spline`, and `ppval`, as
well as scalar-output `mkpp`, `unmkpp`, `ppder`, and `ppint`.  The supported
data shape for this milestone is a one-dimensional grid and one data vector;
general matrix-valued data and N-dimensional interpolation remain outside
this T10 core and are considered by T11 only where the contract is explicit.

The grid is normalized to an increasing MP column vector.  A decreasing grid
is reversed together with its data, repeated points are rejected, and no MP
grid or query point is converted to binary64.  Ordinary numeric inputs are
promoted into MP arithmetic at the selected operation precision.

`interp1` supports `nearest`, `previous`, `next`, `linear`, `pchip`, and
`spline`, default NaN for out-of-range queries, numeric extrapolation values,
the `"extrap"` option, and the compatible `interp1(x,y,method,"pp")` form.

`pchip` uses Fritsch-Carlson weighted slopes for real data and cubic Hermite
coefficients.  Complex data use the corresponding weighted complex Hermite
slopes; scalar ordering-based shape preservation is not defined for complex
values.  `spline` solves the not-a-knot second-derivative system with the MP
linear solve path.  Both produce local descending-power coefficient rows.

`ppval` selects the first/last piece for extrapolation and evaluates each
coefficient row with MP Horner arithmetic.  The derivative and integral
helpers preserve the MP coefficients; `ppint` chooses a continuous integral
with zero initial constant unless an MP/numeric constant is supplied.
