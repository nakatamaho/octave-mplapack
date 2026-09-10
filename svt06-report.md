# SVT06 report

## Result

SVT06: PASS. The unsigned Lah constructor is implemented by the specified
MP-integer recurrence, with exact unit-lower-triangular/full-rank metadata.
All S3 smoke/demo precision, mode, and explicit native comparison rows passed.

## Implemented paths

```text
examples/svd_tiers/private/svt_make_lah.m
examples/svd_tiers/svt_lah_selftest.m
```

For `j <= i`, the constructor evaluates
`L(i,j)=L(i-1,j-1)+(i+j-1)L(i-1,j)` with out-of-range terms zero. It does not
evaluate factorials, binomial coefficients, or parameters through binary64.
The conservative construction budget is recorded as
`3 + sum(ceil_log2(2*i), i=2..n)`. The first four rows, unit diagonal,
strict lower-triangular support, and determinant-one invariant were checked.
The unit diagonal establishes full rank, but no spectral accuracy claim is
made from that fact.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_lah_selftest(); assert(report.ok); fprintf('SVT06 Lah selftest PASS rows=%d\\n', report.measured_rows);"
```

Observed result: `SVT06 Lah selftest PASS rows=20` under GNU Octave 11.1.0
with the recorded MPLAPACK 3.0.1 environment. The wall covers S3 `n=8` at
128/256 bits and `n=20` at 128/256/512 bits, both `values` and `econ` modes,
and one explicit native comparison row per mode.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `6ba442bea1d8e461281ad09b7c0ec87106fac3ce`

Final commit: recorded after this report is committed

Tests: constructor/invariant gate and 20 S3 measured rows PASS

Gate: PASS

Known limitations: Lah singular values remain provisional references until
Tier V; no structured HRA algorithm is claimed or added.
