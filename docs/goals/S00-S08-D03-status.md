# S00-S08 / D03 status

Updated: 2026-09-08

## Current state

```text
branch: topic/s00-s08-script-compat
baseline: D02R1 v0.3.1 freeze, tag v0.3.1 preserved
active package version: 0.4.0-dev
S00: PASS; committed and pushed as c17b48c0a8bf7e39c3c9a111bcc8e3ae0c60e048
S01: implementation complete; metadata/report commit pending
S02-S08: not started
D03: not started
```

S00 adds native MPFR/MPC `abs`, `arg`, `angle`, and `sign`; logical
`isnan`, `isinf`, and `isfinite`; exact `isequal`/`isequaln`; and the missing
`isnumeric` class predicate. Existing `isreal`, `isscalar`, `isvector`,
`ismatrix`, and `isempty` behavior was audited. The old `v0.3.1` source tag
and the frozen gmpfrxx/MPLAPACK dependencies remain unchanged.

## S00 evidence

```text
real abs/angle/sign: PASS
complex abs/angle/sign: PASS
complex conjugate/quadrant and signed zero: PASS
isnan/isinf/isfinite: PASS
isequal/isequaln: PASS
isscalar/isvector/ismatrix/isempty/isnumeric/isreal: PASS
special values +0/-0/Inf/NaN: PASS
native MPFR/MPC implementation: PASS
binary64 numerical fallback: NONE
```

## Gates

```text
G-S00-COMPAT-MATRIX: PASS
G-S00-ABS: PASS
G-S00-ANGLE: PASS
G-S00-SIGN: PASS
G-S00-PREDICATES: PASS
G-S00-ISEQUAL: PASS
G-S00-SPECIAL: PASS
G-S00-PRECISION: PASS
G-S00-REGRESSION: PASS
```

```text
S00 PASS — COMPATIBILITY AUDIT AND BASIC PREDICATES CLOSED
```

## S01 evidence

```text
real/complex/mixed element-wise power: PASS
integer scalar and square-matrix mpower: PASS
MPFR/MPC elementary family: PASS
domain promotion and branch fixtures: PASS
1024/2048 precision tails: PASS
ambient precision independence: PASS
binary64 numerical fallback: NONE
```

```text
G-S01-POWER: PASS
G-S01-MPOWER: PASS
G-S01-EXPLOG: PASS
G-S01-TRIG: PASS
G-S01-HYPERBOLIC: PASS
G-S01-DOMAIN-PROMOTION: PASS
G-S01-COMPLEX-BRANCH: PASS
G-S01-BROADCAST: PASS
G-S01-PRECISION: PASS
G-S01-REGRESSION: PASS
```

```text
S01 PASS — ELEMENT-WISE POWER AND ELEMENTARY FUNCTIONS CLOSED
```

## Next milestone

Proceed automatically to S01 — Element-wise Power and Elementary Functions.
