# C07 RESULT

Repository: `octave-mplapack`
Branch: `topic/complex-c00-c12`
Starting commit: `80920ce44e408381d08f244c91deb155d189c5cc`
Final implementation commit: `bc5b8b301e3fff23b5427599763b01a57cf9d2fb`
Branch tip at implementation gate: `bc5b8b301e3fff23b5427599763b01a57cf9d2fb`
PR: not opened; repository workflow uses the pushed topic branch.

## Dependency identity

- gmpfrxx_mkII: `32a7fb797202cdf92312ed9d133f96fdbcda590a` (`main`)
- MPLAPACK: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`
  (`topic/octave-mplapack-complex-mpfr-scope`)
- pkg-config: `mplapack_mpfr 3.0.1`
- runtime SONAME: `libmplapack_mpfr.so.3`

## Scope

- implemented: complex rank-revealing rectangular left division through
  selected MPLAPACK `Cgelsy`, full-rank and rank-deficient minimum-norm
  solutions, mixed and builtin operands, multiple RHS, precision-sensitive
  rank, empty shapes, operation-owned inputs, and output lifetime;
- audited: `Cgelsy`, `Cgelss`, and `Cgelsd` declarations, reference sources,
  rank controls, and real/complex workspace contracts;
- preserved: real-only rectangular division continues through the established
  real `Rgels`/`Rgelss` path and real square division continues through
  `Rgesv`;
- deferred: complex Cholesky, QR, pivoted QR, mixed concatenation/assignment
  closure, and complex LU.

## Architecture

`complex_mldivide_operation` normalizes complex rectangular operands to one
MPC operation precision and calls `mplapack_mpc_matrix_rank_solve`. The
wrapper makes operation-owned A/B copies, pads the right-hand side to the
LAPACK contract, queries and allocates `Cgelsy` complex workspace, allocates
real workspace at `p_op`, and uses installed `mplapackint` pivot/index types.
The destructive LAPACK call runs inside the operation-local MPFR/MPC
precision scope. The first `n` rows are returned as the solution.

## Precision and numerical semantics

`p_op` is the maximum stored precision among all participating `mp` values.
`Rlamch_mpfr("E")` is evaluated inside that scope for `rcond`; there is no
`DBL_EPSILON`, decimal threshold, or ambient-precision dependence. The
precision contract checks the MPFR default, active MPC real/imaginary
overrides, every A/B element, and complex/real work arrays. Rank is therefore
classified from the stored operation precision, not from ambient `mpbits`.

## Public/backend audit

The installed declarations in `mplapack/mplapack_mpfr.h` match the direct
calls. `mplapack/reference/Cgelsy.cpp` uses QR with column pivoting and real
workspace for `Cgeqp3`; `Cgelss.cpp` and `Cgelsd.cpp` were directly exercised
as alternatives. The controlled MPLAPACK build uses the reference MPFR
backend with optimized variants disabled. No builtin binary64 complex kernel
is used, and no real-only operation is routed through the complex path.

## QA

- native Cgelsy/Cgelss/Cgelsd candidate audit: PASS;
- native selected Cgelsy wrapper: PASS;
- full-column-rank, full-row-rank, minimum-norm, rank-one, rank-zero,
  inconsistent rank-deficient, and multiple-RHS cases: PASS;
- 1024-bit `2^-700` and 2048-bit `2^-1500` real and imaginary canaries: PASS;
- ambient precision independence and restoration: PASS;
- operation-owned immutability and output lifetime: PASS;
- ASan: full native wall PASS;
- UBSan: full native wall PASS;
- LSan: full native wall with `detect_leaks=1` PASS;
- full real/native M01–M23 regression wall: PASS;
- complete public M01–M23 plus C01–C07 wall: PASS;
- real `Rgels`/`Rgelss` parity: existing real native/public tests PASS.

## Commands run

```text
make -C src check-complex-rank

env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    make -C src -B all \
      check-storage-sanitized check-arithmetic-sanitized check-matrix-sanitized \
      check-blas check-lapack check-inspection check-elementwise check-structure \
      check-concat check-assignment check-rgels check-rank check-cholesky \
      check-qr check-pivoted-qr check-lu check-dependency \
      check-complex-storage check-complex-structure check-complex-arithmetic \
      check-complex-blas check-complex-lapack check-complex-rank

env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    octave-cli --no-gui --quiet --no-init-file --eval \
      'run("test/run_tests.m");'
```

## Upstream fixes

No new upstream defect was exposed by C07. MPLAPACK commit
`a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` remains the required precision
scope-header fix. No gmpfrxx_mkII fix was required.

## Gates

`G-C07-CANDIDATE-AUDIT`, `G-C07-UPSTREAM`, `G-C07-FULL-RANK`,
`G-C07-RANK-DEF`, `G-C07-MIN-NORM`, `G-C07-RANK-PRECISION`,
`G-C07-WORKSPACE`, `G-C07-MIXED`, `G-C07-IMMUTABILITY`, and
`G-C07-REAL-RGELSS-PARITY`: PASS.

C07 PASS

## Known limitations

Complex Cholesky, QR, pivoted QR, mixed concatenation and assignment closure,
and complex LU remain deferred to their required milestones.

## Recommended next action

Proceed to C08: implement and gate complex Cholesky while preserving the
real-only `Rpotrf` path.

Branch: `topic/complex-c00-c12`
Starting commit: `80920ce44e408381d08f244c91deb155d189c5cc`
Final commit: `bc5b8b301e3fff23b5427599763b01a57cf9d2fb`
Files changed: `src/Makefile`, `src/octave_bridge.cc`,
`src/mp_complex_rank.cc`, `src/mp_complex_rank.h`, `test/complex_gesv.tst`,
`test/complex_rank.tst`, `test/mp_complex_rank_test.cc`, `test/run_tests.m`
Commands run: native candidate probe, full native regression wall, and
complete public wall listed above
Tests: C07 candidate, wrapper, public, real, sanitizer, precision, and
lifetime tests
Gate: C07 PASS
Known limitations: complex Cholesky, QR, pivoted QR, API closure, and LU are
deferred
