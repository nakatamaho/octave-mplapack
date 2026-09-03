# C08 RESULT

Repository: `octave-mplapack`
Branch: `topic/complex-c00-c12`
Starting commit: `f4ff4c5eb69829d9b879d288221ba07272213222`
Final implementation commit: `abf2c836b6b54b0bde1a87ecb2524369960a895a`
Branch tip at implementation gate: `abf2c836b6b54b0bde1a87ecb2524369960a895a`
PR: not opened; repository workflow uses the pushed topic branch.

## Dependency identity

- gmpfrxx_mkII: `32a7fb797202cdf92312ed9d133f96fdbcda590a` (`main`)
- MPLAPACK: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`
  (`topic/octave-mplapack-complex-mpfr-scope`)
- pkg-config: `mplapack_mpfr 3.0.1`
- runtime SONAME: `libmplapack_mpfr.so.3`

## Scope

- implemented: complex dense Hermitian Cholesky through MPLAPACK `Cpotrf`,
  upper and lower selected-triangle modes, diagonal imaginary-component
  behavior, partial non-PD status, one-/two-output public semantics, empty
  shapes, operation-owned inputs, output lifetime, and precision scope;
- preserved: real-only `chol` remains on the existing `Rpotrf` path with its
  M17 behavior;
- deferred: non-pivoted and pivoted complex QR, mixed concatenation/assignment
  closure, and complex LU.

## Architecture

Complex `chol` dispatch identifies an MPC scalar or matrix payload. Scalars are
represented as an operation-owned 1×1 matrix, while matrices are copied by
`mplapack_mpc_matrix_cholesky`. That wrapper calls `Cpotrf` inside the
operation-local MPFR/MPC scope. Because `Cpotrf` overwrites the selected
triangle, the public source is never modified. Successful output is normalized
to the selected factor triangle with the opposite triangle explicitly zeroed;
on `info > 0`, the completed leading factor and status are returned using the
existing dense `chol` convention.

## Precision and numerical semantics

`p_op` is the stored input precision. The boundary requires the MPFR default,
active MPC real/imaginary overrides, matrix precision, and every component to
match exactly. `Cpotrf` is not reached through builtin binary64 complex
arithmetic. The diagonal is produced by the backend from the real component,
and its imaginary component is verified to be zero. Ambient precision is
restored on success and failure.

## Public/backend audit

The installed declaration in `mplapack/mplapack_mpfr.h` is
`Cpotrf(const char*, mplapackint, mpc_class*, mplapackint, mplapackint&)`.
The controlled source is `mplapack/reference/Cpotrf.cpp`; its selected-triangle
blocked path uses reference `Cherk`, `Cgemm`, `Ctrsm`, and `Cpotrf2`. The
controlled library is the reference MPFR build with optimized variants
disabled. No real-only operation is routed through the complex implementation.

## QA

- native selected-triangle upper/lower Hermitian factorization: PASS;
- ignored-triangle independence and diagonal imaginary handling: PASS;
- non-PD partial factor and positive status: PASS;
- one-/two-output public non-PD behavior: PASS;
- 1024-bit `2^-700` and 2048-bit `2^-1500` precision canaries: PASS;
- ambient precision independence and restoration: PASS;
- operation-owned immutability and output lifetime: PASS;
- empty and non-square shapes: PASS;
- ASan: full native wall PASS;
- UBSan: full native wall PASS;
- LSan: full native wall with `detect_leaks=1` PASS;
- full real/native M01–M23 regression wall: PASS;
- complete public M01–M23 plus C01–C08 wall: PASS;
- real `Rpotrf`/`chol` parity: existing real native/public tests PASS.

## Commands run

```text
env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    make -C src check-complex-cholesky

env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    make -C src -B all

env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    octave-cli --no-gui --quiet --no-init-file --eval \
      'addpath("inst"); addpath("src"); assert(test("test/complex_cholesky.tst", "quiet", stdout));'

env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    make -C src -B all \
      check-storage-sanitized check-arithmetic-sanitized check-matrix-sanitized \
      check-blas check-lapack check-inspection check-elementwise check-structure \
      check-concat check-assignment check-rgels check-rank check-cholesky \
      check-qr check-pivoted-qr check-lu check-dependency \
      check-complex-storage check-complex-structure check-complex-arithmetic \
      check-complex-blas check-complex-lapack check-complex-rank \
      check-complex-cholesky

env PKG_CONFIG_PATH=/home/docker/work/complex-prefix/lib/pkgconfig \
    LD_LIBRARY_PATH=/home/docker/work/complex-prefix/lib:/usr/local/lib \
    octave-cli --no-gui --quiet --no-init-file --eval \
      'run("test/run_tests.m");'
```

## Upstream fixes

No new upstream defect was exposed by C08. MPLAPACK commit
`a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` remains the required precision
scope-header fix. No gmpfrxx_mkII fix was required.

## Gates

`G-C08-UPSTREAM`, `G-C08-HERMITIAN`, `G-C08-SELECTED-TRIANGLE`,
`G-C08-UPPER`, `G-C08-LOWER`, `G-C08-NONPD`, `G-C08-STATUS`,
`G-C08-PRECISION`, `G-C08-IMMUTABILITY`, and `G-C08-REAL-CHOL-PARITY`: PASS.

C08 PASS

## Known limitations

Complex QR, pivoted QR, mixed concatenation and assignment closure, and
complex LU remain deferred to their required milestones.

## Recommended next action

Proceed to C09: implement non-pivoted complex QR through `Cgeqrf` and
`Cungqr`, preserving the real-only QR path.

Branch: `topic/complex-c00-c12`
Starting commit: `f4ff4c5eb69829d9b879d288221ba07272213222`
Final commit: `abf2c836b6b54b0bde1a87ecb2524369960a895a`
Files changed: `inst/@mp/chol.m`, `src/Makefile`, `src/octave_bridge.cc`,
`src/mp_complex_cholesky.cc`, `src/mp_complex_cholesky.h`,
`test/complex_cholesky.tst`, `test/mp_complex_cholesky_test.cc`,
`test/run_tests.m`
Commands run: native C08 probe, full native wall, isolated public C08 suite,
and complete public wall listed above
Tests: C08 Hermitian, triangle, status, precision, ambient, immutability,
lifetime, shape, sanitizer, and real parity tests
Gate: C08 PASS
Known limitations: complex QR, pivoted QR, API closure, and LU are deferred
