# Complex backend provenance

This file records the development dependencies used by the C00-C12 complex
implementation. These are tested development commits, not final release tags.

## Tested repositories

- `gmpfrxx_mkII`: `main` at
  `32a7fb797202cdf92312ed9d133f96fdbcda590a`;
- `mplapack`: `topic/octave-mplapack-complex-mpfr-scope` at
  `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`.

## Controlled installation

- prefix: `/home/docker/work/complex-prefix`;
- pkg-config identity: `mplapack_mpfr 3.0.1`;
- headers: `mplapack/mpblas_mpfr.h`, `mplapack/mplapack_mpfr.h`,
  `mplapack/mplapack_utils_mpfr.h`, and the installed
  `mplapack/mplapack_mpfr_precision.h`;
- link interface: `-lmplapack_mpfr -lmpc -lmpfr -lgmp`;
- runtime library: `libmplapack_mpfr.so.3` (installed file version
  `libmplapack_mpfr.so.3.0.1`).

The controlled C05 build uses MPFR support with the reference backend and
disables GMP, QD, DD, binary80, binary128, optimized, test, and benchmark
variants. MPLAPACK's public MPFR `Cgemm` declaration accepts `mpc_class`
arguments and is implemented by `mpblas/reference/Cgemm.cpp`.

## Upstream fixes introduced during C00-C12

- MPLAPACK commit `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` adds and installs
  `mplapack_mpfr_precision.h`, and includes it from the public MPFR headers.
  This supplies the real MPFR precision scope required by the complex
  implementation. No `gmpfrxx_mkII` fix was required through C05.

No final MPLAPACK 3.0.1 release commit, archive, or dependency tag is frozen
by this development goal.
