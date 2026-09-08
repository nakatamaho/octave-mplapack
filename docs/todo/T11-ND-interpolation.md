# T11 boundary — N-D interpolation deferred

T11 closes the two-dimensional `interp2` core for vector and matrix grid
forms, MP query points, real/complex data, nearest/linear interpolation, and
tensor-product pchip/spline evaluation.

`interp3`, `interpn`, and general N-D interpolation remain deferred.  They
require general N-D MP storage and a separate shape/serialization/API
contract.  They are not silently routed through binary64 arrays or through
the 2-D implementation.
