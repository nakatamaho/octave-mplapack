# Arbitrary-precision graphics boundary

T08 supports `plot3`, `scatter3`, `mesh`, `surf`, `contour3`, `meshc`,
`surfc`, and `waterfall` when their data are vectors or two-dimensional
matrices.  The existing `mp_graphics_args` helper is the single boundary:
only an `mp` data value is converted explicitly to builtin `double` for the
Octave graphics API.  Handles, strings, style arguments, property names,
property values, and ordinary builtin numeric inputs are passed unchanged.

Numerical construction and transformation must happen before this boundary.
Values outside the binary64 range can become zero or infinity when displayed;
users should scale or transform them in `mp` first.  T08 does not add general
N-dimensional storage or volume graphics such as `slice`, `isosurface`, or
volume rendering.
