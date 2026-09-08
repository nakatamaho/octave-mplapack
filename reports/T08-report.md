# T08 report — 3-D graphics boundary

## Result

`T08 PASS — 3-D GRAPHICS CORE CLOSED`

T08 started from T07 evidence commit
`9c2aead6cca454a654a288786fb1b0a3f10fcabb` on
`topic/t00-t14-continuation` and was tested with GNU Octave 11.1.0 and the
headless gnuplot toolkit.

## Implemented API

The package now provides `@mp` wrappers for `plot3`, `scatter3`, `mesh`,
`surf`, `contour3`, `meshc`, `surfc`, and `waterfall`.  All wrappers reuse
`inst/@mp/private/mp_graphics_args.m`.  Only `mp` data arguments are converted
to builtin double at the final graphics call; handles, style strings,
property/value pairs, and ordinary numeric values are not converted.

The implementation does not add N-dimensional storage.  Volume graphics such
as `slice`, `isosurface`, and general 3-D field rendering remain deferred.

## Focused evidence

`test/t08_graphics_3d.tst` passed:

- 1024-bit MP helix through `plot3`;
- axes-handle-first calls and graphics property forwarding;
- `scatter3`;
- matrix `mesh`, `surf`, and `contour3`;
- `meshc`, `surfc`, and `waterfall`;
- mixed MP/builtin data;
- complex-derived real/imaginary 3-D data;
- verification that graphics object data equal the explicit boundary
  conversion and that no numerical operation uses this path.

The S08 compatibility firewall was updated because `mesh(mp)` is now a
supported operation rather than a deferred call.

## Range and precision contract

Arbitrary-precision transformations remain upstream of the graphics
boundary.  Values outside binary64's representable range may become zero or
infinity for visualization, which is documented in `docs/graphics.md`.
No graphics conversion is reused by numerical algorithms, and no builtin
binary64 fallback was introduced.

## Required real regression wall

`test/run_tests.m` passed M00–M23, C00–C12 including C11L, N00–N08,
S00–S08, and T00–T08.
