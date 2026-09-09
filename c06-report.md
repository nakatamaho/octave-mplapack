# C06 RESULT

Repository: `octave-mplapack`
Branch: `topic/complex-c00-c12`
Starting commit: `266247bf57d4840dd5a1def9f53e8b98071100c4`
Final implementation commit: `d70bc873fdb012579b326688cee79254547c9de7`
Branch tip at implementation gate: `d70bc873fdb012579b326688cee79254547c9de7`
PR: not opened; repository workflow uses the pushed topic branch.

## Dependency identity

- gmpfrxx_mkII: `32a7fb797202cdf92312ed9d133f96fdbcda590a` (`main`)
- MPLAPACK: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`
  (`topic/octave-mplapack-complex-mpfr-scope`)
- pkg-config: `mplapack_mpfr 3.0.1`
- runtime SONAME: `libmplapack_mpfr.so.3`

## Scope

- implemented: complex dense square left division through MPLAPACK `Cgesv`,
  mixed real/complex operands, builtin complex right-hand sides, multiple RHS,
  singular and non-square diagnostics, precision promotion, empty shapes,
  scalar complex left division, operation-owned inputs, and output lifetime;
- preserved: real square `A \ B` continues to use `Rgesv`, and real rectangular
  division continues to use the existing rank-revealing real path;
- deferred: complex rectangular solves, Cholesky, QR, pivoted QR, mixed
  concatenation/assignment closure, and complex LU.

## Architecture

`complex_mldivide_operation` normalizes both operands to one MPC operation
precision. A complex coefficient matrix and RHS are copied to operation-owned
uniform matrices, then `mplapack_mpc_matrix_solve` allocates an installed-type
`mplapackint` pivot array and calls `Cgesv`. Scalar left division uses the
existing native MPC element-wise division kernel; it is not routed through a
one-by-one binary64 fallback.

## Precision

`p_op = max(all participating mp precisions)`. The Cgesv boundary checks the
MPFR default, active MPC real and imaginary overrides, and every A/B element
for exact `p_op` agreement before and after the destructive call. The
operation-local scope restores the ambient precision on return and on errors.

## Public semantics

Any complex participant produces a complex `mp` result. Real-only operations
remain on their established real dispatch. Mixed real coefficient/RHS values
promote with exact `+0i`; builtin complex doubles are converted directly from
their two binary64 components. Singular systems retain the established
`mplapack:mp:SingularMatrix` identifier.

## Native/backend audit

The installed declaration in `mplapack/mpblas_mpfr.h`/`mplapack_mpfr.h` uses
`mpc_class` arrays and `mplapackint *ipiv`. The controlled source path is
`mplapack/reference/Cgesv.cpp`, which delegates to reference `Cgetrf` and
`Cgetrs`. The native probe links the controlled shared library directly, and
the controlled build has optimized variants disabled. No builtin binary64
complex fallback is present.

## QA

- native: C06 Cgesv probe PASS at 128 and 512 bits;
- public: complete M01-M23 and C01-C06 driver PASS;
- 1024: real and imaginary `2^-700` solve tails PASS;
- 2048: real and imaginary `2^-1500` solve tails PASS;
- ambient low/high: source precision wins over ambient 128-bit precision and
  current-thread precision is restored PASS;
- pivot: installed `mplapackint` compile-time assertion and Cgesv solve PASS;
- singular: positive Cgesv info classified and mapped PASS;
- multiple RHS: 2x2 coefficient with two RHS columns PASS;
- lifetime/immutability: inputs survive the solve and output survives input
  clearing PASS;
- ASan: complete native wall PASS;
- UBSan: complete native wall PASS;
- LSan: complete native wall with `detect_leaks=1` PASS;
- full real regression: native M02-M22 and public M01-M23 walls PASS;
- real-Rgesv parity: existing native/public M09 square solve tests PASS.

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
      check-complex-blas check-complex-lapack

env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    octave-cli --no-gui --quiet --no-init-file --eval \
      'run("test/run_tests.m");'
```

## Upstream fixes

No new upstream defect was exposed by C06. MPLAPACK commit
`a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` remains the required precision
scope-header fix. No gmpfrxx_mkII fix was required.

## Gates

`G-C06-UPSTREAM`, `G-C06-CGESV`, `G-C06-MIXED`, `G-C06-PIVOT`,
`G-C06-SINGULAR`, `G-C06-MULTIRHS`, `G-C06-PRECISION`,
`G-C06-IMMUTABILITY`, and `G-C06-REAL-RGESV-PARITY`: PASS.

C06 PASS

## Known limitations

Complex rectangular solves, Cholesky, QR, pivoted QR, mixed concatenation and
assignment closure, and complex LU remain deferred to their required
milestones.

## Recommended next action

Proceed to C07: audit and select the controlled complex rank-revealing
rectangular solve backend, then implement the required minimum-norm and
rank-deficient semantics.

Branch: `topic/complex-c00-c12`
Starting commit: `266247bf57d4840dd5a1def9f53e8b98071100c4`
Final commit: `d70bc873fdb012579b326688cee79254547c9de7`
Files changed: `inst/@mp/mldivide.m`, `src/Makefile`, `src/octave_bridge.cc`,
`src/mp_complex_lapack.cc`, `src/mp_complex_lapack.h`, `test/complex_gesv.tst`,
`test/mp_complex_lapack_test.cc`, `test/gesv.tst`, `test/run_tests.m`
Commands run: native full wall and clean public `run_tests.m` wall listed above
Tests: native C06, public C06, complete real/native/public regression walls
Gate: C06 PASS
Known limitations: complex rectangular LAPACK and remaining complex API
closure remain deferred
