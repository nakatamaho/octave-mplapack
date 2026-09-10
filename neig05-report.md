# NEIG05 report

Task and milestone: NEIG — difficult nonsymmetric eigensystems; NEIG05 companion construction and input-error accounting.

Branch: `main`

Starting commit: `643c3cbe0a54cfc2e1f8b2cfa559371506c9142a`

Validated implementation commit or uncommitted state: implementation and focused tests are present in the working tree; this report is written before the milestone commit.

Files created/modified:

- `examples/nonsymmetric_eig/private/nes_companion_coefficients.m`
- `examples/nonsymmetric_eig/private/nes_companion_min_bits.m`
- `examples/nonsymmetric_eig/private/nes_ceil_log2_integer.m`
- `examples/nonsymmetric_eig/private/nes_companion_run.m`
- `examples/nonsymmetric_eig/private/nes_build.m`
- `examples/nonsymmetric_eig/private/nes_reference.m`
- `examples/nonsymmetric_eig/private/nes_cases.m`
- `examples/nonsymmetric_eig/mp_eig_suite.m`
- `examples/nonsymmetric_eig/mp_eig_suite_selftest.m`
- `test/test_nonsymmetric_eig_suite.m`
- `neig05-report.md`

Environment and executable/module resolution:

- GNU Octave 11.1.0 from `/usr/bin/octave`, through `tools/dev-octave.sh`.
- MPLAPACK 3.0.1 MPFR/MPC stack from `/home/docker/opt/octave-mplapack-stack`, selected through `PKG_CONFIG_PATH`, `CPATH`, and `LD_LIBRARY_PATH`.
- Companion coefficients are constructed by the repository-local recurrence with public MP arithmetic.  The native baseline is formed by one explicit `double` conversion of the exact MP coefficient vector and is labeled as a once-rounded input.

Commands run:

```text
PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/dev-octave.sh --eval 'run ("test/test_nonsymmetric_eig_suite.m");'

PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/dev-octave.sh --eval '<companion demo summary>'

git diff --check
```

Tests and numerical results:

- n=4 exact coefficient fixture: PASS; coefficients were `[1,-10,35,-50,24]`.
- Sufficient precision guard: PASS.  The exact integer guard is `n*ceil_log2(n+1)+2`; below-guard requests are rejected and the ambient default is restored.
- Cross-precision coefficient reconstruction: PASS for n=10 and n=20; 128-bit and 512-bit sufficient-precision coefficient vectors agreed after exact MP promotion.
- High-precision Horner root substitution: PASS for n=10 and n=20 at `q_check=2*n*ceil_log2(n+1)+32`; all integer roots evaluated to exact MP zero in the checked representation.
- Native `poly(1:20)` negative control: PASS.  Its once-rounded coefficient vector differed from the independently constructed exact MP coefficient vector; the suite never uses it to build the main companion fixture.
- Native input-rounding accounting: PASS for companion n=20.  The model/input Frobenius difference was approximately `6.69328e2` in both balance modes; this is recorded separately from solver residual and spectrum error.
- Companion smoke: 6 rows, both modes, native/128-bit/256-bit MP; `results.ok=true`.  MP absolute bottleneck log2 values were approximately `-103.80/-106.05` at 128 bits and `-230.89/-231.43` at 256 bits for balance/nobalance.  The p=256 target `2^-120` passed in both modes.
- Companion demo: 8 rows, both modes, native/128/256/512-bit MP; `results.ok=true`.  MP absolute bottleneck log2 values were approximately `-79.41/-78.52`, `-207.33/-206.49`, and `-462.44/-460.32` for balance/nobalance at p=128/256/512.  The p=512 target `2^-200` passed in both modes.
- Actual-input residuals were evaluated from the rounded native matrix or exact MP matrix sent to each solver.  The intended roots were used only for separately labeled total forward error.

Gate: PASS

Known limitations:

- Companion references are the analytically known integer roots and do not require noninteger reference agreement.
- Output-file serialization and the Forsythe family are deferred.
- The native coefficient rounding is intentionally reported, not corrected; it is not an MPLAPACK defect.

Next milestone or minimal blocker reproducer: proceed to NEIG06.

