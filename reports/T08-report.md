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

## Controller metadata

| Field | Value |
|---|---|
| Repository / branch | `octave-mplapack` / `topic/t00-t14-continuation` |
| Starting commit | `9c2aead6cca454a654a288786fb1b0a3f10fcabb` |
| Implementation / tip | `89a25a7a8362ccc9d49ffa0dc2ad92e8b677f981` |
| D03 baseline | `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31` / `v0.4.0` |
| Dependencies / Octave | gmpfrxx `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1`; MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`; GNU Octave 11.1.0, headless gnuplot |
| API / backend | `plot3`, `scatter3`, `mesh`, `surf`, `contour3`, `meshc`, `surfc`, `waterfall`; final graphics-boundary converter |
| Precision / behavior | MPFR/MPC data remain native until graphics; real/complex display conversion only at final boundary |
| Octave QA / 1024-2048 | handles, styles, properties, matrix/vector and toolkit checks; range/precision canaries PASS |
| Sanitizers / previous regression | ASan/UBSan/LSan PASS; T00–T07 and D03 walls retained |
| Status / TODO | PASS; `docs/todo/T08-meshgrid.md`, `docs/todo/T08-volume-graphics-after-ND.md` |
