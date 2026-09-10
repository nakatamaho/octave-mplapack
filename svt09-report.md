# SVT09 report

## Result

SVT09: PASS. The dyadic Vandermonde constructor uses exact MP node and
successive-power construction, with distinct-node and positive-determinant
metadata. All A2 smoke/demo precision, mode, and explicit native comparison
rows passed.

## Implemented paths

```text
examples/svd_tiers/private/svt_make_vandermonde.m
examples/svd_tiers/svt_vandermonde_selftest.m
```

For `x_i=i/2^d`, the denominator is constructed by the exact power-of-two
helper and each row is filled by multiplying the preceding power by the same
MP node. The constructor enforces `n < 2^d`, records the specified
`2+(n-1)ceil_log2(n)` guard, checks strict node ordering, and records the
algebraic determinant-sign/full-rank proof. No determinant-based numerical
accuracy gate is substituted for the SVD measurement.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_vandermonde_selftest(); assert(report.ok); fprintf('SVT09 Vandermonde selftest PASS rows=%d\\n', report.measured_rows);"
```

Observed result: `SVT09 Vandermonde selftest PASS rows=20` under GNU Octave
11.1.0 with the recorded MPLAPACK 3.0.1 environment. The wall covers A2
`n=8,d=4` at 128/256 bits and `n=16,d=5` at 128/256/512 bits, both modes,
and one explicit native comparison row per mode.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `12322f51321f48cd6fc5044bb1e5e4611691d0e5`

Final commit: recorded after this report is committed

Tests: dyadic-node/power and determinant-sign gate and 20 A2 measured rows PASS

Gate: PASS

Known limitations: singular values are provisional until V1 certification;
native rounding is recorded rather than treated as exact model data.
