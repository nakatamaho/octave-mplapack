# SVT16 report

## Result

SVT16: PASS. The V3 verified inverse residual, inverse-norm interval, and
positive `sigma_min` lower-bound baseline is implemented with the public solve
output and SVT12 interval matrix arithmetic.

## Implemented paths

```text
examples/svd_tiers/private/svt_certify_inverse.m
examples/svd_tiers/svt_v3_inverse_selftest.m
```

For square inputs, the checker forms `R=I-A*X` through the scalar-enclosed
matrix product and requires verified `r<1`. It obtains a certified Frobenius
upper bound and a maximum certified column-norm lower bound for `X`, then
returns the specified Neumann inverse-norm bounds and
`sigma_min(A) >= (1-r)/xhi`. A failed sufficient condition is reported as
`INCONCLUSIVE`, never as a singularity proof. Rectangular inputs are explicitly
`UNSUPPORTED_RECTANGULAR`.

The good diagonal inverse, computed NRO inverse, published equation-(82)
inverse, zero/poor inverse, singular rank-deficient control, and rectangular
rejection all passed. The known NRO inverse is an independent check, not a
replacement for the computed-solve path.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_v3_inverse_selftest(); assert(report.ok); disp('SVT16 V3 inverse selftest PASS');"
```

Observed result: `SVT16 V3 inverse selftest PASS` under GNU Octave 11.1.0
with the recorded MPLAPACK 3.0.1 environment.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `3d8b3744616f4717b271ae0c22cc530ed6a8752d`

Final commit: recorded after this report is committed

Tests: good inverse, NRO, published inverse, poor/singular negative controls, and rectangular gate PASS

Gate: PASS

Known limitations: V3 is a sufficient-condition route; it does not certify a
failed case as singular and does not provide a rectangular pseudoinverse proof.
