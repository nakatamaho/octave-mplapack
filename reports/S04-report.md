# S04 report — matrix utilities and constructors

## Result

```text
S04 PASS — MATRIX UTILITIES AND CONSTRUCTORS CLOSED
```

Implementation commit: `2247480a4835519f27cb53b6a39173d05f16bdc8`.

## Public API

```text
diag: PASS — diagonal construction/extraction and signed offsets
triu/tril: PASS — dense shape-preserving triangular copies and offsets
triu/tril "pack": explicit rejection — packed sparse output is outside the 2-D dense contract
like constructors: PASS — zeros, ones, eye, NaN, Inf for mp templates
repmat: PASS — scalar and two-element repetition dimensions
flip: PASS — default, dimension-1, and dimension-2 forms
fliplr/flipud: PASS — native row/column reversal
rot90: PASS — positive, negative, and multi-turn counts
cat: PASS — dimensions 1 and 2 through native vertical/horizontal paths
dimensions above two: explicit rejection
```

The implementation uses operation-owned MPFR or MPC matrix storage. Structural
copies use `mpfr_set` or `mpc_set`, and generated zero/one/Inf/NaN entries are
written directly with MPFR/MPC setters. No S04 path routes real operations
through a complex kernel or uses builtin binary64 arithmetic as a numerical
fallback. Existing dense concatenation remains the authoritative `cat(1/2)`
backend.

The explicit `"like"` constructor methods are selected by Octave's class
dispatch when an `mp` template is present. The template determines both the
stored precision and whether the result is real MPFR or complex MPC. The
constructor surface intentionally does not replace ordinary builtin
constructors without a `"like"` template.

## Precision and edge coverage

```text
256/320-bit ordinary matrix fixtures: PASS
1024-bit 2^-700 canary: PASS
2048-bit 2^-1500 canary: PASS
ambient default changed after source construction: PASS
real/complex precision preservation: PASS
empty/rectangular 2-D handling: PASS
signed diagonal offsets and rot90 negative count: PASS
```

## Gates

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

`test/script-compat/s04.tst` passed. The required post-milestone wall also
passed: M00–M23 real regression, C00–C12 including C11L, N00–N08, S00–S04,
native ASan/UBSan/LSan gates, clean rebuild #2, deterministic source archive,
and isolated package install/lifecycle QA.

The active package metadata remains `0.4.0-dev`; the immutable `v0.3.1`
source release and frozen gmpfrxx/MPLAPACK dependencies are unchanged.
