# C05 RESULT

Repository: `octave-mplapack`
Branch: `topic/complex-c00-c12`
Starting commit: `18fa5807fc12a3e9e8b76fce335b9b8b14547044`
Final implementation commit: `6a485b0825d5b550b30f17c0b875e8e85ef59971`
Branch tip at implementation gate: `6a485b0825d5b550b30f17c0b875e8e85ef59971`
PR: not opened; repository workflow uses the pushed topic branch.

## Dependency identity

- gmpfrxx_mkII: `32a7fb797202cdf92312ed9d133f96fdbcda590a` (`main`)
- MPLAPACK: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`
  (`topic/octave-mplapack-complex-mpfr-scope`)
- pkg-config: `mplapack_mpfr 3.0.1`
- runtime SONAME: `libmplapack_mpfr.so.3`

## Scope

- implemented: complex dense matrix multiplication through MPLAPACK `Cgemm`
  for complex/complex, real/complex, and complex/real operands; builtin
  complex matrix conversion; complex scalar scaling; precision promotion;
  empty shapes; dimension diagnostics; and operation-owned inputs/results;
- preserved: real/real multiplication continues to use the existing MPFR
  `Rgemm` path;
- deferred: complex solves, factorizations, mixed concatenation/assignment
  closure, and complex LU.

## Architecture

`complex_mtimes_operation` normalizes every complex-participating operand to
one operation precision. Real MPFR operands become MPC values with exact `+0i`;
builtin real and complex doubles are converted directly from their binary64
components. Matrix products call `Cgemm` with explicit MPC `alpha = 1 + 0i`
and `beta = 0 + 0i`. Matrix scaling and scalar products use direct MPC calls
under the same precision policy.

`mplapack_mpc_matrix_multiply` copies both public inputs into uniform,
operation-owned MPC matrices, allocates an operation-owned result, installs
`MpfrMpcPrecisionScope`, validates the MPFR/MPC boundary contract, and then
calls `Cgemm`. Public values are not mutated and remain valid after their
inputs are cleared.

## Precision

`p_op = max(all participating mp precisions)`. The Cgemm boundary validates
that A, B, C, alpha, beta, MPFR default precision, and both MPC component
precision overrides are all exactly `p_op`. The controlled reference backend
executes on the calling thread, so no unconfigured optimized worker path is
accepted by this gate.

## Public semantics

Any complex participant produces a complex `mp` result and is never demoted to
binary64. Real-only `*` remains on the existing real dispatch. Mixed real and
complex matrices, builtin complex matrices, scalar scaling, empty shapes, and
dimension errors use the documented `mp` interface.

## Native/backend audit

The installed declaration in `mplapack/mpblas_mpfr.h` is the MPC `Cgemm`
signature. Its controlled source is `mpblas/reference/Cgemm.cpp` at the exact
MPLAPACK commit above. The controlled installation has optimized variants
disabled, and the native probe links and exercises `libmplapack_mpfr.so.3`
directly. No builtin binary64 complex fallback is present.

## QA

- native: C05 complex Cgemm probe PASS at 128 and 512 bits;
- public: complete M01-M23 and C01-C05 driver PASS;
- 1024: real and imaginary `2^-700` tails survive Cgemm PASS;
- 2048: real and imaginary `2^-1500` tails survive Cgemm PASS;
- ambient low/high: operation precision follows operands and current-thread
  global precision is preserved PASS;
- lifetime: output survives clearing both input values PASS;
- ASan: complete native wall PASS;
- UBSan: complete native wall PASS;
- LSan: complete native wall with `detect_leaks=1` PASS;
- full real regression: native M02-M22 and public M01-M23 walls PASS;
- real-Rgemm parity: existing native/public M08 `Rgemm` tests PASS.

## Commands run

```text
env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    make -C src -B all \
      check-storage-sanitized check-arithmetic-sanitized check-matrix-sanitized \
      check-blas check-lapack check-inspection check-elementwise check-structure \
      check-concat check-assignment check-rgels check-rank check-cholesky \
      check-qr check-pivoted-qr check-lu check-dependency \
      check-complex-storage check-complex-structure check-complex-arithmetic \
      check-complex-blas

env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    octave-cli --no-gui --quiet --no-init-file --eval \
      'run("test/run_tests.m");'
```

## Upstream fixes

No new upstream defect was exposed by C05. MPLAPACK commit
`a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` remains the required upstream fix
that installs `mplapack_mpfr_precision.h` and includes it from the public MPFR
headers. No gmpfrxx_mkII fix was required.

## Gates

`G-C05-UPSTREAM`, `G-C05-DISPATCH`, `G-C05-CGEMM`, `G-C05-PRECISION`,
`G-C05-MIXED`, `G-C05-SHAPES`, `G-C05-IMMUTABILITY`, and
`G-C05-REAL-RGEMM-PARITY`: PASS.

C05 PASS

## Known limitations

Complex square/rectangular solves, Cholesky, QR, pivoted QR, mixed
concatenation/assignment closure, and complex LU remain deferred to their
required milestones.

## Recommended next action

Proceed to C06: implement complex square solves through MPLAPACK `Cgesv` while
preserving the real `Rgesv` path and the one-operation/one-precision contract.

Branch: `topic/complex-c00-c12`
Starting commit: `18fa5807fc12a3e9e8b76fce335b9b8b14547044`
Final commit: `6a485b0825d5b550b30f17c0b875e8e85ef59971`
Files changed: `inst/@mp/mtimes.m`, `src/Makefile`, `src/octave_bridge.cc`,
`src/mp_complex_blas.cc`, `src/mp_complex_blas.h`, `test/complex_gemm.tst`,
`test/mp_complex_blas_test.cc`, `test/run_tests.m`
Commands run: native full wall and clean public `run_tests.m` wall listed above
Tests: native C05, public C05, complete real/native/public regression walls
Gate: C05 PASS
Known limitations: complex LAPACK and mixed API closure remain deferred
