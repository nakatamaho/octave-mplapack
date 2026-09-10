# SVT11 report

## Result

SVT11: PASS. The Lauchli tall/wide family, repeated-small-singular-group
projectors, quarter-turn complex control, and named normal-equations negative
control are implemented. All A4 smoke/demo rows passed.

## Implemented paths

```text
examples/svd_tiers/private/svt_make_lauchli.m
examples/svd_tiers/svt_lauchli_selftest.m
```

The constructor forms `T=[ones;mu*I]`, with `mu=2^-b`, and its wide transpose.
The analytic spectrum is `sqrt(n+mu^2)` followed by `n-1` copies of `mu`.
Known left/right projectors for the repeated small group are generated from
the exact MP rank-one complement; wide-form projectors are swapped. The
quarter-turn case uses `D_L*T*D_R'`, preserving singular values while
transforming the projectors by the corresponding unitary phases.

`T'*T = ones(n)+mu^2*I` is recorded and checked only as the specified
negative control. No normal-equations result is used as the SVD oracle, and no
claim is made that native binary64 SVD must fail.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_lauchli_selftest(); assert(report.ok); fprintf('SVT11 Lauchli selftest PASS rows=%d\\n', report.measured_rows);"
```

Observed result: `SVT11 Lauchli selftest PASS rows=52` under GNU Octave
11.1.0 with the recorded MPLAPACK 3.0.1 environment. The wall covers tall
and wide smoke rows plus the demo complex tall case at 128/256/512 bits,
both modes, and one explicit native comparison row per mode.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `0de2e170ac1b11c72d4f88c5ae2747b7214cded4`

Final commit: recorded after this report is committed

Tests: Lauchli spectrum/projector/phase gate, negative control, and 52 A4 measured rows PASS

Gate: PASS

Known limitations: analytic values and projector identities are not yet
outward-certified; Tier V implementation remains pending.
