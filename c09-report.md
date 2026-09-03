# C09 RESULT

Repository: `octave-mplapack`
Branch: `topic/complex-c00-c12`
Starting commit: `62bfc9f3ba41a2e7b1e270299795cbfdad615d02`
Final implementation commit: `ff2a86418ec90b53042bce8cae8d0312715a8950`
Branch tip at implementation gate: `ff2a86418ec90b53042bce8cae8d0312715a8950`
PR: not opened; repository workflow uses the pushed topic branch.

## Dependency identity

- gmpfrxx_mkII: `32a7fb797202cdf92312ed9d133f96fdbcda590a` (`main`)
- MPLAPACK: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`
  (`topic/octave-mplapack-complex-mpfr-scope`)
- pkg-config: `mplapack_mpfr 3.0.1`
- runtime SONAME: `libmplapack_mpfr.so.3`

## Scope

- implemented: complex dense QR through `Cgeqrf` and `Cungqr`, full and
  economy forms, wide-matrix behavior, R-only one-output dispatch, deprecated
  `qr(A,0)`, exact complex R lower zeros, conjugate-transpose orthogonality,
  reconstruction, empty shapes, operation-owned inputs, output lifetime, and
  precision scope;
- preserved: real-only QR remains on `Rgeqrf`/`Rorgqr`;
- deferred: pivoted complex QR, mixed concatenation/assignment closure, and
  complex LU.

## Architecture

`complex_qr_operation` normalizes the complex payload to an operation-owned
matrix. `mplapack_mpc_matrix_qr` queries and runs `Cgeqrf`, copies the packed
factor and reflectors into Q-generation storage only when requested, and then
queries/runs `Cungqr`. R is extracted with exact zero in its strict lower
triangle. Full/economy shape construction follows the established real QR
policy, including a full orthonormal complement for tall full QR.

## Precision and numerical semantics

`p_op` is the stored input precision. `Cgeqrf`, `Cungqr`, tau, query work,
actual work, Q, and R all use exactly `p_op`. The boundary checks MPFR default,
active MPC real/imaginary overrides, storage precision, and uniform component
precision. One-output calls do not invoke `Cungqr`; no builtin binary64
complex arithmetic is used for the factorization.

## Public/backend audit

The installed declarations in `mplapack/mplapack_mpfr.h` match the direct
calls. Controlled sources `mplapack/reference/Cgeqrf.cpp` and
`mplapack/reference/Cungqr.cpp` use complex reflector and blocked workspace
helpers. The controlled MPLAPACK build uses the reference MPFR backend with
optimized variants disabled. Real-only QR dispatch is unchanged.

## QA

- full, economy, and wide complex QR shape tests: PASS;
- one-output R-only/no-Q path and deprecated `qr(A,0)`: PASS;
- complex Q'Q orthogonality: PASS;
- Q*R reconstruction: PASS;
- exact strict-lower R zeros: PASS;
- 1024-bit `2^-700` and 2048-bit `2^-1500` complex canaries: PASS;
- ambient precision independence and restoration: PASS;
- operation-owned immutability and output lifetime: PASS;
- empty shapes: PASS;
- ASan: full native wall PASS;
- UBSan: full native wall PASS;
- LSan: full native wall with `detect_leaks=1` PASS;
- full real/native M01–M23 regression wall: PASS;
- complete public M01–M23 plus C01–C09 wall: PASS;
- real `Rgeqrf`/`Rorgqr` parity: existing real native/public tests PASS.

## Commands run

```text
env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    make -C src check-complex-qr

env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    make -C src -B all \
      check-storage-sanitized check-arithmetic-sanitized check-matrix-sanitized \
      check-blas check-lapack check-inspection check-elementwise check-structure \
      check-concat check-assignment check-rgels check-rank check-cholesky \
      check-qr check-pivoted-qr check-lu check-dependency \
      check-complex-storage check-complex-structure check-complex-arithmetic \
      check-complex-blas check-complex-lapack check-complex-rank \
      check-complex-cholesky check-complex-qr

env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    octave-cli --no-gui --quiet --no-init-file --eval \
      'run("test/run_tests.m");'
```

## Upstream fixes

No new upstream defect was exposed by C09. MPLAPACK commit
`a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` remains the required precision
scope-header fix. No gmpfrxx_mkII fix was required.

## Gates

`G-C09-UPSTREAM`, `G-C09-FULL`, `G-C09-ECON`, `G-C09-ONE-OUTPUT`,
`G-C09-WORKSPACE`, `G-C09-ORTHOGONALITY`, `G-C09-RECONSTRUCTION`,
`G-C09-PRECISION`, and `G-C09-REAL-QR-PARITY`: PASS.

C09 PASS

## Known limitations

Complex pivoted QR, mixed concatenation and assignment closure, and complex
LU remain deferred to their required milestones.

## Recommended next action

Proceed to C10: implement pivoted complex QR through `Cgeqp3` and `Cungqr`,
with exact JPVT mapping and real/complex precision audit.

Branch: `topic/complex-c00-c12`
Starting commit: `62bfc9f3ba41a2e7b1e270299795cbfdad615d02`
Final commit: `ff2a86418ec90b53042bce8cae8d0312715a8950`
Files changed: `inst/@mp/qr.m`, `src/Makefile`, `src/octave_bridge.cc`,
`src/mp_complex_qr.cc`, `src/mp_complex_qr.h`, `test/complex_qr.tst`,
`test/mp_complex_qr_test.cc`, `test/run_tests.m`
Commands run: native C09 probe, full native wall, isolated public C09 suite,
and complete public wall listed above
Tests: C09 full/economy/R-only/workspace/orthogonality/reconstruction,
precision, ambient, lifetime, sanitizer, and real parity tests
Gate: C09 PASS
Known limitations: complex pivoted QR, API closure, and LU are deferred
