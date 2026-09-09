# S02 report — reductions and extrema

## Result

```text
S02 PASS — REDUCTIONS AND EXTREMA CLOSED
```

Implementation commit: `07c047d08d64ecd8c0d623cd2e1e621882b6c8b9`.

## Public API

```text
sum/prod: PASS — real and complex native accumulation
sumsq: PASS — real MPFR and complex magnitude-squared reduction
cumsum/cumprod: PASS — explicit dimensions and forward/reverse direction
min/max: PASS — reductions, pairwise forms, dimensions, and first indices
NaN controls: PASS — omitnan and includenan
complex ordering: PASS — native magnitude/phase and ComparisonMethod forms
```

## Precision and implementation

Reduction inputs are copied into operation-owned MPFR or MPC matrices at the
stored source precision. Accumulators and outputs retain that precision. The
complex `sumsq` path computes native MPC magnitudes and accumulates the real
MPFR squares. `min`/`max` return builtin one-based index matrices only for
single-input reductions; pairwise operations preserve native values and
support two-dimensional singleton expansion.

The public wrappers accept `native`/`default` and explicit `double` output,
dimensions, `"all"` for non-cumulative reductions, NaN flags, and cumulative
direction. No S02 numerical path calls builtin binary64 arithmetic or routes a
real operation through a complex kernel.

## Tests and gates

```text
test/script-compat/s02.tst: PASS
real reductions/extrema: PASS
complex reductions/extrema: PASS
NaN/index/order audit: PASS
1024-bit 2^-700 canary: PASS
2048-bit 2^-1500 canary: PASS
ambient precision isolation: PASS
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

The active package metadata remains `0.4.0-dev`; D03 owns the final source
version freeze. The immutable `v0.3.1` source and frozen dependency stack are
unchanged.
