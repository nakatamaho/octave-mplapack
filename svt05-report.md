# SVT05 report

## Result

SVT05: PASS. The `z=1` Jacobi--Stirling second-kind constructor uses the
specified MP integer recurrence and preserves the leading 5-by-5 fixture.
All S2 smoke/demo precision, mode, and explicit native comparison rows passed.

## Implemented paths

```text
examples/svd_tiers/private/svt_make_jacobi_stirling.m
examples/svd_tiers/svt_jacobi_stirling_selftest.m
```

The recurrence is evaluated with MP additions and integer multiplications;
factorials and binary64 coefficient generation are not used. The constructor
records the conservative exactness budget
`3 + sum(ceil_log2(1+r*(r+1)))`, verifies the requested precision, and records
unit lower triangular/full-rank metadata. The 5-by-5 output was checked
against the normative matrix in `CASES.md`, along with the `n=1` identity and
invalid-`z` rejection. The implementation does not claim that the generic
dense driver is the paper's structured HRA algorithm.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_jacobi_stirling_selftest(); assert(report.ok); fprintf('SVT05 Jacobi-Stirling selftest PASS rows=%d\\n', report.measured_rows);"
```

Observed result: `SVT05 Jacobi-Stirling selftest PASS rows=20` under GNU
Octave 11.1.0 with the recorded MPLAPACK 3.0.1 environment. The measured
wall covers the S2 fixture at smoke 128/256 bits and demo 128/256/512 bits,
both `values` and `econ` modes, plus one explicit native row per mode.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `1d337398832cd351552467c95aef0e7930ae43fb`

Final commit: recorded after this report is committed

Tests: constructor/invariant gate and 20 S2 measured rows PASS

Gate: PASS

Known limitations: S2 references remain provisional until the later Tier V
certifier is implemented; no structured HRA solver is included.
