# SVT13 report

## Result

SVT13: PASS. The V1a `svt_polar_weyl_v1` checker certifies all ordered
singular-value inclusions from the actual supplied economy `U,S,V` factors and
the represented input. It does not recompute SVD or use precision agreement
as verification.

## Implemented paths

```text
examples/svd_tiers/private/svt_certify_values.m
examples/svd_tiers/svt_v1_values_selftest.m
```

The checker validates finite 2-D inputs, economy shapes, real diagonal `S`,
nonnegative descending values, and finite factors. It builds the Gram defects
and reconstruction residual with the SVT12 scalar interval matrix product,
then applies the specified polar corrections `dU`, `dV`, `vN`, and `epsilon`.
It requires `gU<1` and `gV<1`, returns `INCONCLUSIVE` for failed conditions,
and returns outward `[max(0,s_i-epsilon), s_i+epsilon]` intervals only on
`CERTIFIED`. The zero-spectrum branch does not divide by `s(1)`.

The bad-Gram, malformed-value, exact diagonal, tall economy, complex, and
all-zero cases are covered. Known values are used only as independent test
targets; the checker consumes the provided factors once.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_v1_values_selftest(); assert(report.ok); disp('SVT13 V1a selftest PASS');"
```

Observed result: `SVT13 V1a selftest PASS` under GNU Octave 11.1.0 with the
recorded MPLAPACK 3.0.1 environment. The gate covered exact real diagonal,
tall economy, complex square, all-zero spectrum, invalid negative/malformed
S, and a deliberately bad Gram matrix returning `INCONCLUSIVE`.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `acbf0c68efa3f4fe0e971ec8d364b10bf8bddf4b`

Final commit: recorded after this report is committed

Tests: V1a enclosure, input validation, complex path, zero path, and adversarial fail-closed gate PASS

Gate: PASS

Known limitations: this milestone certifies values only; cluster projectors,
factor boxes, inverse-norm bounds, output artifacts, and profile integration
remain pending.
