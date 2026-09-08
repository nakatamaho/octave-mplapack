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
