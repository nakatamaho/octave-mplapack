# S06 report — basic descriptive statistics

## Result

```text
S06 PASS — BASIC DESCRIPTIVE STATISTICS CLOSED
```

Implementation commit: `0f3e9c8dd4bb00067c117e2144d0e1f3c7179d0b`.

## Public API

```text
mean: PASS — default/explicit dimension, all, nanflag, and double boundary
median: PASS — real MPFR and complex native magnitude/phase ordering
var: PASS — normalization 0/1, dimensions, all, nanflag, and second mean output
std: PASS — normalization 0/1, dimensions, all, nanflag, and second mean output
range: PASS — native min/max difference with Octave omitnan default
bounds: PASS — native lower/upper values with two outputs
```

The implementation uses operation-owned MPFR or MPC matrix storage. Real
means and variances use MPFR accumulators; complex means use MPC and complex
variance/std use real MPFR accumulators over native squared magnitudes. The
variance path computes the mean first and then the sum of squared deviations,
so it does not use the catastrophically cancelling `sum(x.^2) - n*mean(x)^2`
formula. `var(x,0)` and `std(x,0)` use N-1 normalization; the `1` forms use N.

`median` uses arbitrary-precision native ordering and averages the middle
native values for an even slice. Complex median, range, and bounds use the
same magnitude/phase ordering audited against Octave's complex ordering.
Complex variance and standard deviation return real MPFR values and their
optional second outputs retain the complex mean. Unsupported weighted or
multi-dimensional vector-dimension forms are not silently approximated.

## NaN and precision coverage

```text
mean/median/var/std default includenan: PASS
mean/median/var/std omitnan: PASS
range/bounds default omitnan: PASS
range/bounds includenan: PASS
empty/all-NaN slices: native NaN results
1024-bit 2^-700 canary: PASS
2048-bit 2^-1500 canary: PASS
ambient default changed after source construction: PASS
stable large-offset variance: PASS
binary64 numerical fallback: NONE
```

## Gates

```text
G-S06-MEAN: PASS
G-S06-MEDIAN: PASS
G-S06-VAR: PASS
G-S06-STD: PASS
G-S06-RANGE: PASS
G-S06-BOUNDS: PASS
G-S06-REAL: PASS
G-S06-COMPLEX-AUDIT: PASS
G-S06-NANFLAG: PASS
G-S06-STABILITY: PASS
G-S06-PRECISION: PASS
G-S06-REGRESSION: PASS
```

`test/script-compat/s06.tst` and the dedicated S06 gate passed. The required
post-milestone wall `tools/local-ci.sh` also passed M00–M23,
C00–C12 including mandatory C11L, N00–N08, S00–S06, native
ASan/UBSan/LSan gates, clean rebuild #2, deterministic source-package
generation, and isolated package install/unload/uninstall/reinstall QA.

The active package metadata remains `0.4.0-dev`; the immutable `v0.3.1`
source release and frozen gmpfrxx/MPLAPACK dependencies remain unchanged.

## Next milestone

Proceed automatically to S07 — Graphics boundary bridge.
