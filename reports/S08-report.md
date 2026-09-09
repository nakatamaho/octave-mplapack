# S08 report — ordinary script compatibility closure

## Result

```text
S08 PASS — ORDINARY SCRIPT COMPATIBILITY CLOSED
D03-READY
```

Implementation and documentation commit:
`51a0b420b6a47df3d84eba99bb27ec4b1d96a622`.

The active package metadata remains `0.4.0-dev`; immutable `v0.3.1` and the
frozen gmpfrxx/MPLAPACK dependencies were not modified.

## Closed surface

The six-script corpus in `test/script-compat/s08.tst` passed:

```text
Script A: linspace, power, sqrt, exp/log, sin/cos, sum, plot
Script B: comparisons, isfinite, logical indexing, min/max, mean/std
Script C: like constructors, diag, triu/tril, repmat, flip, cat
Script D: norm, right division, eig, svd, rank, cond
Script E: Grcar, eig, residual through /, plotting, balance/nobalance
Script F: negative-domain promotion, complex trig, abs/angle, statistics, plot
```

Native MPFR/MPC sequence support now covers `sort` and `diff`. Sort supports
both dimensions, ascending/descending forms, stable ties, Octave one-based
indices within each sorted dimension, native MPFR ordering, and native MPC
magnitude/phase ordering. NaNs are placed last for ascending and first for
descending order. Diff supports order and dimension forms, repeated native
MPFR/MPC subtraction, order-zero copies, and the scalar default empty result
shape. The structural audit closed `length`, `size`, `rows`, `columns`,
`numel`, `ndims`, and `isempty`, including empty matrices.

The existing S03 `find` implementation was reverified as part of the full
script-compatibility wall. Surface graphics such as `mesh (mp_matrix)` remain
an explicit firewall stop; the S07 line-graphics wrappers remain the only
automatic double boundary.

## Gates

```text
G-S08-CORPUS: PASS
G-S08-SORT: PASS
G-S08-FIND: PASS — S03 implementation reverified by full wall
G-S08-DIFF: PASS
G-S08-STRUCTURAL: PASS
G-S08-FIREWALL: PASS
G-S08-DOCS: PASS
G-S08-REAL: PASS
G-S08-COMPLEX: PASS
G-S08-PRECISION: PASS — 1024-bit 2^-700 and 2048-bit 2^-1500
G-S08-ASAN: PASS
G-S08-UBSAN: PASS
G-S08-LSAN: PASS
G-S08-FULL-REGRESSION: PASS
```

The dedicated S08 gate passed all 12 tests. The native sequence test passed
under ASan and UBSan with leak detection enabled. The post-milestone
`tools/local-ci.sh` wall passed mandatory D00 prerequisites, M00–M23,
C00–C12 including mandatory C11L, N00–N08, S00–S08, the native
ASan/UBSan/LSan wall, clean rebuild #2, deterministic source-package
generation, isolated archive installation, full regression, unload,
uninstall, and reinstall QA. The host emitted only the known gnuplot and
singular-matrix warnings; all assertions passed.

No numerical path uses builtin binary64 as an implicit fallback. Native
sequence results preserve source precision and ambient `mpbits` changes do
not rewrite stored values.

## Next milestone

Proceed automatically to D03 — Final Source Re-freeze.
