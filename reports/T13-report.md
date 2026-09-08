# T13 report — arbitrary-precision quadrature

## Result

`T13 PASS — ARBITRARY-PRECISION QUADRATURE CORE CLOSED`

## Implementation

`integral` and `quadgk` provide a scalar MP callback interface.  The backend
is adaptive tanh-sinh (double-exponential) quadrature with MPFR/MPC values for
all nodes, weights, endpoint transformations, and error estimates.  Finite,
semi-infinite, and two-sided infinite intervals, complex integrands, finite
waypoints, and MP `AbsTol`/`RelTol` are covered.  Endpoint evaluation is
avoided, including algebraic endpoint tests.  `ArrayValued` is cleanly
rejected as deferred scope.

## QA

`test/t13_quadrature.tst` passed finite polynomial and waypoint integrals,
the endpoint-singular `1/sqrt(x)` case, a semi-infinite exponential integral,
complex trigonometric/exponential integrals, and a 512-bit result at an
80-decimal scale below binary64 resolution.

## Controller metadata

| Field | Value |
|---|---|
| Repository / branch | `octave-mplapack` / `topic/t00-t14-continuation` |
| Starting commit / implementation tip | `dced45c3f977252d74ed3da7cb3389c8395ead8a` / `3f878016dea4d7de372c83d0f5554f6c64a48c93` |
| D03 baseline | `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31` / `v0.4.0` |
| Dependencies / Octave | gmpfrxx `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1`; MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`; GNU Octave 11.1.0 |
| API / backend | Scalar `integral`/`quadgk`; adaptive MP tanh-sinh with MPFR/MPC nodes, weights, transforms, and errors |
| Precision / behavior | one-operation/one-precision nodes/callbacks/tolerances; real/complex scalar callbacks; no binary64 fallback |
| Octave QA / 1024-2048 | finite/infinite/waypoint/singular/complex/tolerance forms; high-precision canaries PASS |
| Sanitizers / previous regression | ASan/UBSan/LSan PASS; T00–T12 and D03 walls retained |
| Status / TODO | PASS; `docs/todo/T13-array-valued-quadrature.md` |
