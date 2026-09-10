# SVT15 report

## Result

SVT15: PASS. The V2 compatible simple-factor box baseline is implemented
with common-phase semantics and explicit unsupported multiplicity handling.

## Implemented paths

```text
examples/svd_tiers/private/svt_certify_factor_boxes.m
examples/svd_tiers/svt_v2_factor_selftest.m
```

For each selected positive simple singular value, the checker computes the
full Hermitian-dilation separation including all opposite-sign values and
rectangular structural zeros. It requires `Delta > 2*epsilon`, then returns
the specified norm-derived `z`, `radius_U`, and `radius_V` rectangles centered
on the raw returned columns. Real and imaginary components are both enclosed
in the complex case. It never normalizes or reorthogonalizes the returned
factors.

Exact repeated values return `UNSUPPORTED_MULTIPLICITY` rather than an
individual-vector claim, while the underlying V1a value certificate is
retained. The record states that one common phase is used for each compatible
pair. This is the conservative baseline specified by SVT, not a full
componentwise Rump--Ogita implementation.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_v2_factor_selftest(); assert(report.ok); disp('SVT15 V2 factor selftest PASS');"
```

Observed result: `SVT15 V2 factor selftest PASS` under GNU Octave 11.1.0
with the recorded MPLAPACK 3.0.1 environment. The gate covered the mandatory
3-by-2 real factor, quarter-turn complex factor, common signs, single-sided
phase corruption, repeated multiplicity, nontrivial Hadamard geometric
values, and an insufficient exterior-gap control.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `2e0ae606f67b22484e6d2ca986475bf1d99c5679`

Final commit: recorded after this report is committed

Tests: V2 simple-factor boxes, common-phase, multiplicity, complex, and gap gates PASS

Gate: PASS

Known limitations: boxes are conservative norm-derived rectangles and do not
identify a unique basis at multiplicity or reproduce the cited algorithm's
sharp componentwise bounds.
