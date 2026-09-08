# T11 report — two-dimensional interpolation

## Result

`T11 PASS — 2-D INTERPOLATION CORE CLOSED`

T11 was implemented on the T10 head
`ecb497b93b586427d135f38c51244c6ccdea5fab` on
`topic/t00-t14-continuation` and tested with GNU Octave 11.1.0 and the frozen
MPLAPACK MPFR/MPC backend.

## Implemented surface

`interp2` now supports:

- `interp2(z,xi,yi)` and `interp2(x,y,z,xi,yi)` forms;
- vector and mesh-style matrix grids, including descending axes;
- `nearest`, `linear`, tensor-product `pchip`, and tensor-product `spline`;
- real and complex MP data, MP query grids, numeric extrapolation values,
  `"extrap"`, and default MP NaN out-of-range results.

The data/grid orientation and the explicit N-D boundary are recorded in
`docs/interpolation-2d.md` and `docs/todo/T11-ND-interpolation.md`.

## Focused QA

`test/t11_interp2.tst` passed all three tests:

- vector and matrix grid forms, nearest/linear evaluation, descending axes,
  extrapolation, and default NaN behavior;
- real tensor-product spline/pchip and complex bilinear interpolation;
- a 1024-bit query containing `2^-700`, with the result remaining above the
  binary64-rounded query result, plus the default-coordinate form.

`interp3`, `interpn`, and general N-D interpolation were not added and remain
explicitly deferred without a binary64 fallback.

## Required real-regression wall

The complete `test/run_tests.m` wall passed after T11, covering M00–M23,
C00–C12 including C11L, N00–N08, S00–S08, and T00–T11.  Expected warnings
from headless gnuplot and the existing singular-machine-precision fixture
remained non-fatal.

## Controller metadata

| Field | Value |
|---|---|
| Repository / branch | `octave-mplapack` / `topic/t00-t14-continuation` |
| Starting commit / implementation tip | `ecb497b93b586427d135f38c51244c6ccdea5fab` / `216f78305a2df0e3c2da0bc0cf55500fd0498d96` |
| D03 baseline | `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31` / `v0.4.0` |
| Dependencies / Octave | gmpfrxx `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1`; MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`; GNU Octave 11.1.0 |
| API / backend | Dense 2-D `interp2`; native MPFR/MPC axis normalization, bilinear and tensor PP evaluation |
| Precision / behavior | grids, queries, coefficients, extrapolation, and outputs retain operation precision; no binary64 fallback |
| Octave QA / 1024-2048 | vector/matrix grids, descending axes, methods, extrapolation, shapes, complex values; high-precision canaries PASS |
| Sanitizers / previous regression | ASan/UBSan/LSan PASS; T00–T10 and D03 walls retained |
| Status / TODO | PASS; `docs/todo/T11-ND-interpolation.md` |
