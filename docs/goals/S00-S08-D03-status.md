# S00-S08 / D03 status

Updated: 2026-09-08

## Current state

```text
branch: topic/s00-s08-script-compat
baseline: D02R1 v0.3.1 freeze, tag v0.3.1 preserved
active package version: 0.4.0-dev
S00: PASS; committed and pushed as c17b48c0a8bf7e39c3c9a111bcc8e3ae0c60e048
S01: PASS; committed and pushed as 29f3539 (full SHA in git history)
S02: PASS; committed and pushed as 07c047d08d64ecd8c0d623cd2e1e621882b6c8b9
S03: PASS; committed and pushed as a71c13f and 5714787
S04: PASS; committed and pushed as 2247480a4835519f27cb53b6a39173d05f16bdc8
S05-S08: not started
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

## S02 evidence

Implementation/report commit: `07c047d08d64ecd8c0d623cd2e1e621882b6c8b9`.

```text
sum/prod/sumsq: PASS — native MPFR/MPC reduction accumulators
cumsum/cumprod: PASS — dimensions and forward/reverse direction
dimension/default/all forms: PASS
omitnan/includenan: PASS
min/max values and first indices: PASS
pairwise extrema and singleton expansion: PASS
complex magnitude/phase ordering: PASS
1024/2048 precision and ambient default isolation: PASS
binary64 numerical fallback: NONE
```

```text
G-S02-SUM: PASS
G-S02-PROD: PASS
G-S02-CUMSUM: PASS
G-S02-CUMPROD: PASS
G-S02-SUMSQ: PASS
G-S02-DIM: PASS
G-S02-NANFLAG: PASS
G-S02-MINMAX: PASS
G-S02-COMPLEX-ORDER: PASS
G-S02-INDICES: PASS
G-S02-PRECISION: PASS
G-S02-REGRESSION: PASS
```

```text
S02 PASS — REDUCTIONS AND EXTREMA CLOSED
```

## S03 evidence

Implementation commits: `a71c13f` and `5714787`.

```text
comparisons: native MPFR real relations and native MPC equality/inequality
logicals: native MPFR/MPC truth classification and &, |, xor, ~
any/all: dimensions and all reduction forms
find: linear, row/column, value, count, and direction forms
indexing: numeric vectors, logical masks, and value-semantic assignment
complex ordered comparisons: explicit rejection retained
1024/2048 precision and ambient default isolation: PASS
binary64 numerical fallback: NONE
```

```text
G-S03-COMPARE: PASS
G-S03-COMPLEX-EQUALITY: PASS
G-S03-ORDER-FIREWALL: PASS
G-S03-LOGICAL: PASS
G-S03-ANY-ALL: PASS
G-S03-FIND: PASS
G-S03-INDEX: PASS
G-S03-ASSIGNMENT: PASS
G-S03-PRECISION: PASS
G-S03-REGRESSION: PASS
```

```text
S03 PASS — COMPARISONS, LOGICALS, AND LOGICAL INDEXING CLOSED
```

## S04 evidence

Implementation commits: `2247480a4835519f27cb53b6a39173d05f16bdc8` and
`a742fce4dc6f3c372a050e41f25eefe886561dab` (native matrix-structure backend).

```text
diag construction/extraction and offsets: PASS
triu/tril dense copies and offsets: PASS; "pack" explicitly rejected
zeros/ones/eye/NaN/Inf "like" constructors: PASS
repmat scalar/vector dimensions: PASS
flip/fliplr/flipud/rot90: PASS
cat(1/2): PASS through native concat paths
real/complex precision preservation: PASS
1024/2048 precision and ambient default isolation: PASS
binary64 numerical fallback: NONE
```

```text
G-S04-DIAG: PASS
G-S04-TRIU: PASS
G-S04-TRIL: PASS
G-S04-LIKE-CONSTRUCTORS: PASS
G-S04-REPMAT: PASS
G-S04-FLIP: PASS
G-S04-ROT90: PASS
G-S04-CAT: PASS
G-S04-PRECISION: PASS
G-S04-REGRESSION: PASS
```

The post-milestone wall passed M00–M23, C00–C12/C11L, N00–N08, S00–S04,
native ASan/UBSan/LSan, clean rebuild #2, deterministic package generation,
and isolated install/lifecycle QA against the frozen dependencies.

```text
S04 PASS — MATRIX UTILITIES AND CONSTRUCTORS CLOSED
```

## Next milestone

Proceed automatically to S05 — Ranges, rounding, and utility arithmetic.
