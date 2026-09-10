# SVT14 report

## Result

SVT14: PASS. The V1b signed-dilation cluster checker is implemented with
external ±spectral separation, structural-zero handling, and raw-factor
projector radii. Internal multiplicity is accepted as a cluster, while
individual wrong-column/factor claims fail closed.

## Implemented paths

```text
examples/svd_tiers/private/svt_certify_projector.m
examples/svd_tiers/svt_v1_projector_selftest.m
```

The checker consumes the V1a certificate and does not recompute SVD or
orthonormalize returned factors. For every target index it includes positive
complement values, all negative dilation values including `-s_i`, and
rectangular structural zeros. It requires positive target lower endpoints and
`Delta > 2*epsilon`; otherwise the projector status is `INCONCLUSIVE` while
the valid V1a value result is retained. On success it returns the specified
`b_sub`, `bU`, and `bV` bounds, including raw-factor polar corrections.

The tests cover an exact repeated cluster, internal permutation, a nontrivial
3-4-5 internal rotation, an exterior-column corruption, a rectangular
structural-zero gap, and an exterior-gap collapse. The known exact projector
is used only as independent test data.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_v1_projector_selftest(); assert(report.ok); disp('SVT14 V1 projector selftest PASS');"
```

Observed result: `SVT14 V1 projector selftest PASS` under GNU Octave 11.1.0
with the recorded MPLAPACK 3.0.1 environment. Certified cases included square
and rectangular positive clusters; malformed exterior mixing was explicitly
not certified.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `f60ef5260b775769f0180ba6fe6b5bd903af9a1a`

Final commit: recorded after this report is committed

Tests: signed-dilation gap, projector radii, rotations/permutations, structural-zero, and collapse gates PASS

Gate: PASS

Known limitations: this is the specified conservative dilation baseline, not
a full reproduction of the cited paper's algorithm or componentwise bounds.
