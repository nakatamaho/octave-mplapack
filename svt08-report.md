# SVT08 report

## Result

SVT08: PASS. The lower Pascal factor and symmetric Pascal matrix are built by
separate MP addition recurrences, and the exact `P=Q*Q'` relation is checked.
All A1 smoke/demo precision, mode, and explicit native comparison rows passed.

## Implemented paths

```text
examples/svd_tiers/private/svt_make_pascal.m
examples/svd_tiers/svt_pascal_selftest.m
```

`Q(i,j)` is generated as a unit lower-triangular Pascal recurrence. `P(i,j)`
is generated independently from its boundary ones and the two-dimensional
Pascal addition `P(i,j)=P(i,j-1)+P(i-1,j)`. No native `nchoosek`, factorial,
or binary64 coefficient path is used. The constructor records the conservative
`max(n+2,2*n+2)` budget, determinant/rank metadata, and the exact relation
error. The n=4 matrices were checked against their known binomial values.

The SVD rows are dense-driver measurements; they are not presented as a
numerical table reproduced from the Pascal or totally-nonnegative literature.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_pascal_selftest(); assert(report.ok); fprintf('SVT08 Pascal selftest PASS rows=%d\\n', report.measured_rows);"
```

Observed result: `SVT08 Pascal selftest PASS rows=40` under GNU Octave 11.1.0
with the recorded MPLAPACK 3.0.1 environment. The wall covers two A1 cases
at smoke 128/256 bits and demo 128/256/512 bits, both modes, and one explicit
native comparison row per mode: `(2*2*2*2) + (2*3*2*2) = 40`.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `a243451a28901f9e0bb691d9013ccb77b062d954`

Final commit: recorded after this report is committed

Tests: Pascal recurrence/identity gate and 40 A1 measured rows PASS

Gate: PASS

Known limitations: the SVD spectral relation to Q is a provisional numerical
cross-check until V1 certification; no paper-specific structured solver is
claimed.
