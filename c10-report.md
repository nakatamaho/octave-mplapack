# C10 RESULT

Repository: `octave-mplapack`
Branch: `topic/complex-c00-c12`
Starting commit: `e802d752d25e4905cc439b0aec7591b37b5c6488`
Final implementation commit: `570fa1b6a5047c133825183f4a3337bf81de4641`
Branch tip at implementation gate: `570fa1b6a5047c133825183f4a3337bf81de4641`

## Dependency identity

- gmpfrxx_mkII: `32a7fb797202cdf92312ed9d133f96fdbcda590a` (`main`);
- MPLAPACK: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`
  (`topic/octave-mplapack-complex-mpfr-scope`);
- pkg-config: `mplapack_mpfr 3.0.1`;
- runtime SONAME: `libmplapack_mpfr.so.3`.

## Scope

- implemented: complex pivoted dense QR through `Cgeqp3` and `Cungqr`, full,
  economy, wide, matrix-permutation, vector-permutation, and deprecated
  `qr(A,0)` forms;
- preserved: real-only pivoted QR remains on `Rgeqp3`/`Rorgqr`;
- preserved: permutation outputs are builtin real structural data;
- preserved: non-pivoted complex QR remains on the C09 `Cgeqrf`/`Cungqr`
  path.

## Gates

`G-C10-UPSTREAM`, `G-C10-PERMUTATION`, `G-C10-MATRIX-P`,
`G-C10-VECTOR-P`, `G-C10-ECON`, `G-C10-PIVOT-PRECISION`,
`G-C10-RECONSTRUCTION`, `G-C10-ORTHOGONALITY`, and
`G-C10-REAL-RGEQP3-PARITY`: PASS.

The controlled MPLAPACK declaration and reference implementation were
audited for `Cgeqp3`; no new upstream defect was exposed. The required
MPLAPACK precision-scope-header fix remains the only upstream fix used by the
complex line.

## QA

- native C10 pivoted complex QR gate: PASS;
- full/economy/wide shapes and exact JPVT permutation validation: PASS;
- `Q*R = A*P` and `Q*R = A(:,p)` reconstruction: PASS;
- complex orthogonality: PASS;
- 1024-bit/2048-bit precision-sensitive pivot order: PASS;
- ambient precision restoration, input immutability, output lifetime, and
  empty shapes: PASS;
- ASan/UBSan/LSan full native real+complex wall: PASS;
- complete public M01–M23 plus C01–C10 wall: PASS;
- real `Rgeqp3`/`Rorgqr` parity: PASS.

## Commands run

```text
env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    make -C src check-complex-pivoted-qr

env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    make -C src -B all \
      check-storage-sanitized check-arithmetic-sanitized check-matrix-sanitized \
      check-blas check-lapack check-inspection check-elementwise check-structure \
      check-concat check-assignment check-rgels check-rank check-cholesky \
      check-qr check-pivoted-qr check-lu check-dependency \
      check-complex-storage check-complex-structure check-complex-arithmetic \
      check-complex-blas check-complex-lapack check-complex-rank \
      check-complex-cholesky check-complex-qr check-complex-pivoted-qr

env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    octave-cli --no-gui --quiet --no-init-file --eval \
      'run("test/run_tests.m");'
```

## Upstream fixes

MPLAPACK commit `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` remains required:
it installs `mplapack_mpfr_precision.h` and includes it from the public MPFR
interfaces. No gmpfrxx_mkII fix or additional MPLAPACK fix was required by
C10.

## Result

C10 PASS

Known limitations at this point are mixed real/complex API closure and
complex LU, which are covered by C11, C11L, and C12.
