# S00 report — compatibility audit and basic predicates

## Result

```text
S00 PASS — COMPATIBILITY AUDIT AND BASIC PREDICATES CLOSED
```

The public `mp` class now supports native arbitrary-precision `abs`, `arg`,
`angle`, and `sign` for real and complex scalars/matrices. The special-value
predicates return builtin logical values, and exact equality methods cover
shape/value comparison and Octave-compatible NaN handling.

## Public API

```text
abs: PASS — real MPFR magnitude or MPC magnitude
arg/angle: PASS — MPFR/MPC argument with Octave quadrant behavior
sign: PASS — MPFR sign or MPC x/abs(x), zero special case
isnan/isinf/isfinite: PASS — scalar and dense logical masks
isreal: PASS — existing payload-kind predicate
isequal: PASS — exact native values and shape, NaN unequal
isequaln: PASS — exact native values and shape, NaN equal
isscalar/isvector/ismatrix/isempty: PASS — generic audit
isnumeric: PASS — public @mp wrapper required by Octave class dispatch
```

## Precision and implementation

All outputs retain the source precision. MPFR functions operate directly on
the stored MPFR values; MPC functions operate inside the existing composed
MPFR/MPC precision scope. No S00 numerical operation calls `double`, builtin
numeric functions, or a binary64 fallback. Public values remain immutable and
new storage is operation-owned.

## Tests

```text
test/script-compat/s00.tst: PASS
real/complex signed-zero audit: PASS
real/complex Inf and NaN audit: PASS
generic structural predicate audit: PASS
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

## Scope note

The active package metadata is `0.4.0-dev` during the S00-S08 development
series. The final `0.4.0` source freeze remains reserved for D03. S01-S08
are not yet claimed by this report.
