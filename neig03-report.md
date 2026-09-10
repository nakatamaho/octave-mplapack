# NEIG03 report

Task and milestone: NEIG — difficult nonsymmetric eigensystems; NEIG03 complete Hadamard experiment.

Branch: `main`

Starting commit: `90dc8a6b6de76959584091927e576cd6af6ec8ee`

Validated implementation commit or uncommitted state: implementation and focused tests are present in the working tree; this report is written before the milestone commit.

Files created/modified:

- `examples/nonsymmetric_eig/private/nes_hadamard_run.m`
- `examples/nonsymmetric_eig/private/nes_reference.m`
- `examples/nonsymmetric_eig/private/nes_build.m`
- `examples/nonsymmetric_eig/mp_eig_suite.m`
- `examples/nonsymmetric_eig/mp_eig_suite_selftest.m`
- `test/test_nonsymmetric_eig_suite.m`
- `neig03-report.md`

Environment and executable/module resolution:

- GNU Octave 11.1.0 from `/usr/bin/octave`, through `tools/dev-octave.sh`.
- MPLAPACK 3.0.1 MPFR backend resolved via `/home/docker/opt/octave-mplapack-stack/lib/pkgconfig`; includes and runtime libraries were from the same prefix.
- The native baseline used Octave's builtin binary64 `eig` only for a native double matrix. MP runs used the public `mp` `eig` entry point; no binary64 fallback was used in MP numerical paths.

Commands run:

```text
PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/dev-octave.sh --eval 'run ("test/test_nonsymmetric_eig_suite.m");'

PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/dev-octave.sh --eval '<smoke/demo result summary>'

git diff --check
```

Tests and numerical results:

- The model was built as `H*T*H'/n` at the evaluation precision and the actual solver input was separately promoted.  The Hadamard fixture uses the transformed dense matrix, not the triangular source `T`.
- The exact native construction bound `n*(n+s)` was recorded and is safely below `2^53` for the smoke `(8,16)` and demo `(16,128)` fixtures.  Native and MP model constructions agreed exactly at the tested evaluation precision.
- Smoke produced 6 rows: 2 modes × (native + 128-bit MP + 256-bit MP).  Demo produced 8 rows: 2 modes × (native + 128/256/512-bit MP).
- Both `balance` and `nobalance` completed for every Hadamard row.  For this exact fixture their measured values were identical to the displayed precision; no balancing improvement was assumed.
- Smoke MP absolute bottleneck errors in log2 units were `-103.545` at 128 bits and `-232.057` at 256 bits.  The p=256 target `2^-120` passed in both modes.
- Demo MP absolute bottleneck errors in log2 units were `-43.690` (128 bits), `-173.361` (256 bits), and `-427.530` (512 bits).  The p=256 `2^-100` and p=512 `2^-300` targets passed in both modes.
- Demo MP normalized right/left residual log2 values were respectively approximately `(-126.159,-127.022)`, `(-254.479,-254.749)`, and `(-510.128,-510.796)` for p=128/256/512.  All passed the predeclared precision-dependent residual envelope.
- Demo p=512 maximum relative disagreement between returned left/right condition estimates and the analytic Hadamard formula was approximately `2^-428.204`, passing the `2^-80` target in both modes.
- Native demo rows ran successfully but showed the expected platform-dependent forward degradation; one representative native absolute bottleneck was approximately `1.10e1`.  Native rows had no mandatory forward target.
- Actual computed eigentriples, rather than known roots, were passed through the metrics engine.  Known roots were used only as the separate analytic reference.

Gate: PASS

Known limitations:

- Only the Hadamard family is wired into the public runner at this milestone.  Frank, companion, Forsythe, output files, and plotting are intentionally deferred.
- The current summary command displays logarithms for compactness; later output writers will preserve canonical MP decimal values and precision metadata.
- The native run uses the host Octave eigensolver and is a comparison baseline, not an assertion about every platform's failure pattern.

Next milestone or minimal blocker reproducer: proceed to NEIG04.

