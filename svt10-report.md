# SVT10 report

## Result

SVT10: PASS. The A4 Lauchli controls and A5 Hadamard known-spectrum,
close/repeated-group, and exact-rank fixtures are implemented. All A4/A5
smoke/demo measured rows passed.

## Implemented paths

```text
examples/svd_tiers/private/svt_make_lauchli.m
examples/svd_tiers/svt_lauchli_selftest.m
examples/svd_tiers/private/svt_make_hadamard_spectrum.m
examples/svd_tiers/svt_hadamard_spectrum_selftest.m
```

Lauchli covers tall/wide `T=[ones;mu*I]`, the known repeated-small-group
projectors, and the quarter-turn complex tall control. Its normal-equations
identity is explicitly a negative control and is not the SVD oracle.

A5 uses `mix(diag(d))` with exact dyadic `d`. The constructor records geometric,
close, repeated, rank-four, and rank-five model ranks and known projectors.
Close/rank perturbations are built as MP dyadics; native input rounding does
not alter the ideal model metadata. The raw/mixed and analytic checks remain
provisional until Tier V. The implementation does not infer generic null-space
multiplicity from tiny approximate singular values.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_hadamard_spectrum_selftest(); assert(report.ok); fprintf('SVT10 A4/A5 selftest PASS rows=%d\\n', report.measured_rows);"
```

Observed result: `SVT10 A4/A5 selftest PASS rows=152` under GNU Octave
11.1.0 with the recorded MPLAPACK 3.0.1 environment. A5 contributes 100
rows (five cases in smoke and five in demo); A4 contributes 52 rows (two
smoke and three demo cases), for 152 total. Each profile uses every listed
MP work precision, both `values` and `econ`, and one explicit native
comparison row per mode.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `8e791b6962292bef163bfa6caba7076e977b4342`

Final commit: recorded after this report is committed

Tests: A4/A5 constructor/projector/negative-control gate and 152 measured rows PASS

Gate: PASS

Known limitations: analytic spectra/projector bounds are not yet outward
certificates; A6 and Tier V remain pending.
