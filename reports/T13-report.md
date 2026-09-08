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
