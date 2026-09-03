# C11 RESULT

Repository: `octave-mplapack`
Branch: `topic/complex-c00-c12`
Starting commit: `2831de7dd4fca9b08922125a21806d13f287997c`
Final implementation commit: `64d8b1d296299afccfd1e77d459969f7a52221e2`
Branch tip at implementation gate: `64d8b1d296299afccfd1e77d459969f7a52221e2`

## Dependency identity

- gmpfrxx_mkII: `32a7fb797202cdf92312ed9d133f96fdbcda590a` (`main`);
- MPLAPACK: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`
  (`topic/octave-mplapack-complex-mpfr-scope`);
- pkg-config: `mplapack_mpfr 3.0.1`;
- runtime SONAME: `libmplapack_mpfr.so.3`.

## Scope

- implemented: mixed real/complex promotion for `+`, `-`, `.*`, `./`, `*`,
  and `\`;
- implemented: mixed real/complex horizontal and vertical concatenation;
- implemented: real-LHS indexed assignment promotion to complex, complex-LHS
  real assignment, mixed-precision assignment, and complex reshape;
- preserved: real-only arithmetic, GEMM, LAPACK, concatenation, and assignment
  paths remain real and are not routed through complex kernels;
- preserved: builtin `P`/`p` structural outputs and public `mp` value semantics.

## Gates

`G-C11-PROMOTION`, `G-C11-PRECISION`, `G-C11-ARITHMETIC`, `G-C11-MTIMES`,
`G-C11-MLDIVIDE`, `G-C11-CONCAT`, `G-C11-ASSIGN`, `G-C11-STRUCTURAL`,
`G-C11-BUILTIN-DOUBLE`, `G-C11-NO-DEMOTION`, and
`G-C11-REAL-REGRESSION`: PASS.

The C11 changes required no new upstream fix. MPLAPACK commit
`a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` remains the required public
MPFR precision-scope-header fix; no gmpfrxx_mkII fix was required.

## QA

- native mixed real/complex concatenation gate under ASan/UBSan/LSan: PASS;
- mixed precision/kind promotion and no-demotion: PASS;
- mixed Cgemm, Cgesv/Cgelsy, and builtin double participation: PASS;
- horizontal/vertical concatenation in both operand orders: PASS;
- real-to-complex and complex-to-real indexed assignment semantics: PASS;
- complex reshape/indexing/transpose/ctranspose/component structure: PASS;
- ambient precision restoration, input immutability, and output lifetime: PASS;
- full native real+complex sanitizer wall: PASS;
- complete public M01–M23 plus C01–C11 wall: PASS.

## Commands run

```text
env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    make -C src check-complex-concat

env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    make -C src -B all \
      check-storage-sanitized check-arithmetic-sanitized check-matrix-sanitized \
      check-blas check-lapack check-inspection check-elementwise check-structure \
      check-concat check-assignment check-rgels check-rank check-cholesky \
      check-qr check-pivoted-qr check-lu check-dependency \
      check-complex-storage check-complex-structure check-complex-arithmetic \
      check-complex-blas check-complex-lapack check-complex-rank \
      check-complex-cholesky check-complex-qr check-complex-pivoted-qr \
      check-complex-concat

env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    octave-cli --no-gui --quiet --no-init-file --eval \
      'run("test/run_tests.m");'
```

## Upstream fixes

MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` remains the only upstream
fix required by the complex implementation. It installs and exposes the
MPFR precision-scope header. No new upstream defect was exposed by C11.

## Result

C11 PASS

Mandatory next milestone: C11L — complex LU via `Cgetrf`.
