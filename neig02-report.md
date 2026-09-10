# NEIG02 report

Task and milestone: NEIG — difficult nonsymmetric eigensystems; NEIG02 bottleneck matching and diagnostic engine.

Branch: `main`

Starting commit: `1ddd756406ebadf82e8b66a3f251283a51d8cbcd`

Validated implementation commit or uncommitted state: implementation and focused tests are present in the working tree; this report is written before the milestone commit.

Files created/modified:

- `examples/nonsymmetric_eig/private/nes_match.m`
- `examples/nonsymmetric_eig/private/nes_metrics.m`
- `examples/nonsymmetric_eig/mp_eig_suite_selftest.m`
- `neig02-report.md`

Environment and executable/module resolution:

- GNU Octave 11.1.0 from `/usr/bin/octave`, through `tools/dev-octave.sh`.
- MPLAPACK 3.0.1 and the installed MPFR/MPC stack were selected through `/home/docker/opt/octave-mplapack-stack` using `PKG_CONFIG_PATH`, `CPATH`, and `LD_LIBRARY_PATH`.
- The matching and metrics code calls only public MP operations (`abs`, arithmetic, comparison, `sort`, `norm`, `cond`, `conj`, transpose/indexing, and `isfinite`). No private native operation is used by the helpers.

Commands run:

```text
PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/dev-octave.sh --eval 'run ("test/test_nonsymmetric_eig_suite.m");'
git diff --check
```

Tests and numerical results:

- Deterministic minimum-bottleneck matching: PASS.  The implementation forms an MP cost matrix, sorts MP thresholds, binary-searches feasibility, and uses deterministic augmenting paths; it does not use a native-double or minimum-sum surrogate.
- Identity/permutation matching, including the one-to-one mapping: PASS.
- Duplicate/missing-root trap `[0,0,2]` against `[0,1,2]`: PASS; bottleneck was 1 rather than the misleading nearest-neighbor value 0.
- Augmenting-path reassignment `[2,0]` against `[1,3]`: PASS; bottleneck was 1.
- Unsorted conjugate unit-circle matching: PASS.
- Exhaustive comparison over all 720 permutations of a six-root real spectrum: PASS; every MP bottleneck matched the exact zero reference.
- 1024-bit `2^-700` and 2048-bit `2^-1500` distance rows: PASS; values remained nonzero and were ordered by MP comparisons.
- Invalid empty sizes, zero relative reference roots, and nonfinite roots: PASS; each was rejected with an explicit NEIG error.
- Right residual convention `A*V=V*D`: PASS on a real nonsymmetric matrix with a genuine complex pair.
- Left residual convention `W'*A=D*W'` and equivalent `A'*W=W*D'`: PASS.  The wrong independently permuted `W` columns were detected by a large left residual.
- Deliberately perturbed eigenvectors were detected by the column/global residual metrics.
- Scalar scaling of left/right eigenvector columns preserved condition estimates within the 768-bit diagnostic tolerance; no elementwise eigenvector equality was assumed.
- Metrics reject zero eigenvector columns and zero residual denominators, preserve MP values, and report unresolved zero overlaps as `Inf` rather than dropping them.

Gate: PASS

Known limitations:

- Metrics currently accept a square matrix-form `D`; profile wiring and the family-specific construction/reference paths are deferred to NEIG03–NEIG06.
- Matching is optimal for the supplied MP evaluation values, not an interval certificate of mathematical roots.
- Exhaustive matcher tests are intentionally in the focused self-test and are not yet attached to the repository-wide test entry point; NEIG08 will integrate that path.

Next milestone or minimal blocker reproducer: proceed to NEIG03.

