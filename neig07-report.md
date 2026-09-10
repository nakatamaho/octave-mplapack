# NEIG07 report

Task and milestone: NEIG — difficult nonsymmetric eigensystems; all-family dispatch, deterministic result output, and optional visualization.

Branch: `main`

Starting commit: `1bb2bfe7ba1271441dbca24a639afb1110d8def6`

Validated implementation commit or uncommitted state: implementation and focused tests are present in the working tree; this report is written before the milestone commit.

## Scope

NEIG07 completes the all-family experiment wall. The default family selection runs these five representations:

1. Hadamard-similar triangular model;
2. Frank matrix;
3. Wilkinson-polynomial companion matrix;
4. Forsythe original form;
5. Forsythe explicitly scaled form.

Each representation is run with both `balance` and `nobalance`, with one explicit native-binary64 control and the profile's MP work precisions. Result rows are normalized to one `neig-v1` schema before cross-family aggregation.

Files created/modified:

- `examples/nonsymmetric_eig/nes_write.m`
- `examples/nonsymmetric_eig/nes_plot.m`
- `examples/nonsymmetric_eig/mp_eig_suite.m`
- `examples/nonsymmetric_eig/private/nes_cases.m`
- `tools/run-nonsymmetric-eig-suite.sh`
- `test/test_nonsymmetric_eig_suite.m`
- `neig07-report.md`

## Result bundle

When `options.output_dir` is supplied, the suite creates a new directory (or uses an empty existing directory) and refuses to overwrite any result file. It writes:

- `summary.tsv`: one row for each solver run, including mode, backend, precision, residuals, and accuracy status;
- `eigenvalues.tsv`: computed and reference real/imaginary MP components, serialized with `char(mp)`;
- `environment.txt`: schema, profile, precision, Octave, architecture, and working-directory metadata;
- `report.md`: a short bundle index and precision-conversion statement;
- optional `spectrum.png` when `options.plot=true`.

The numerical result columns do not pass through binary64. The optional plot is explicitly presentation-only and labels its conversion in the axis/title and bundle report.

## Environment and commands

- GNU Octave 11.1.0 from `/usr/bin/octave`, through `tools/dev-octave.sh`.
- MPLAPACK 3.0.1 MPFR/MPC stack from `/home/docker/opt/octave-mplapack-stack`, selected through `PKG_CONFIG_PATH`, `CPATH`, and `LD_LIBRARY_PATH`.

Commands run:

```text
PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/run-nonsymmetric-eig-suite.sh smoke

PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/run-nonsymmetric-eig-suite.sh demo

PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/dev-octave.sh --eval 'run ("test/test_nonsymmetric_eig_suite.m");'

git diff --check
```

Additional focused checks created a temporary owned output directory, verified all required files, attempted a second write, and verified `NEIG:WriteExists`. A separate smoke run with `plot=true` generated `spectrum.png` successfully with the headless gnuplot toolkit.

## Tests and numerical results

- All-family smoke: PASS; exactly 30 rows = 5 representations × 2 modes × (native + 128-bit + 256-bit MP).
- All-family demo: PASS; exactly 40 rows = 5 representations × 2 modes × (native + 128-bit + 256-bit + 512-bit MP).
- The per-family gates from NEIG03–NEIG06 remained active inside the aggregated run. Hadamard condition-disagreement, Frank reference consistency, companion coefficient precision, and Forsythe circle-error targets all passed.
- Result row schema: PASS; mixed family rows aggregate without field loss, and every MP metric remains an `mp` value until text serialization.
- Output safety: PASS; required files are created and an existing result file is never silently replaced.
- MP eigenvalue serialization: PASS; `eigenvalues.tsv` contains separate MP real and imaginary text fields and no solver-side `double` conversion.
- Optional visualization: PASS; `spectrum.png` was generated. The only `double` conversion is in `nes_plot.m`, which is explicitly outside solver and metric paths.
- Focused regression: PASS; `test/test_nonsymmetric_eig_suite.m` passed after re-running all earlier family tests, the all-family smoke/demo walls, and output safety checks.

## Gate

NEIG07 gate: **PASS**

## Known limitations

- The optional plot is a display artifact and cannot be used as numerical evidence.
- Stress-profile execution is implemented but is intentionally not part of the mandatory 30/40-row NEIG07 wall; the 2048-bit Forsythe constructor canary is covered by NEIG06.
- Clean source-package extraction, documentation/manual integration, and runnable example QA are deferred to NEIG08.

Next milestone: proceed to NEIG08.
