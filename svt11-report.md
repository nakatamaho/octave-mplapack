# SVT11 report

## Result

SVT11: PASS. The deterministic bounded-integer NRO companion-like family is
implemented with the specified alternating `k/nu` construction, Horner
unimodularity proof, entry bound, and published equation-(82) inverse fixture.
All A6 smoke/demo rows passed.

## Implemented paths

```text
examples/svd_tiers/private/svt_make_nro_companion.m
examples/svd_tiers/svt_nro_companion_selftest.m
```

The first row is generated from `a_1=k_1` and
`a_i=k_i-nu*k_(i-1)`, while the lower rows use the prescribed subdiagonal
one and diagonal `-nu`. Horner states are retained and compared directly with
the exact `k_i` sequence; determinant sign is recorded from the construction,
not inferred from a small floating determinant. Every entry is checked against
`nu+1`.

The independent 4-by-4 equation-(82) matrices `C` and `X` satisfy both
`C*X=I` and `X*C=I` exactly in MP arithmetic. Their printed singular values
are not used as an oracle.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_nro_companion_selftest(); assert(report.ok); fprintf('SVT11 NRO companion selftest PASS rows=%d\\n', report.measured_rows);"
```

Observed result: `SVT11 NRO companion selftest PASS rows=20` under GNU
Octave 11.1.0 with the recorded MPLAPACK 3.0.1 environment. The wall covers
`n=8,nu=16` at 128/256 bits and `n=16,nu=256` at 128/256/512 bits, both
`values` and `econ` modes, and one explicit native comparison row per mode.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `2ac674afaf5c0347b94d9050d586bf5eef0ccf41`

Final commit: recorded after this report is committed

Tests: Horner/entry-bound/inverse gate and 20 A6 measured rows PASS

Gate: PASS

Known limitations: SVD values remain provisional until the independent Tier V
enclosures are consumed; this is the selected deterministic specialization,
not every sign/parameter choice in the source paper.
