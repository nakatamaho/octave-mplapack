# SVT04 report

## Result

SVT04: PASS. The three S1 NRO block variants are implemented with exact
dyadic construction metadata, stable reciprocal analytic reference values,
and explicit inverse checks. The required S1 smoke/demo measured wall passed.

## Implemented paths

```text
examples/svd_tiers/private/svt_make_nro.m
examples/svd_tiers/private/svt_run_native_svd.m
examples/svd_tiers/svt_nro_selftest.m
```

The constructor implements the two-level, three-level, and graded choices of
`w_j`, forms `B = H*diag(w)`, and constructs
`A = [I B; 0 I]`. It records the unscaled model, represented global dyadic
scale, exact inverse formula, rank/determinant invariants, pairwise beta
values, and sorted analytic singular values. The small reciprocal is computed
as `2/(sqrt(beta^2+4)+beta)`; no cancellation-prone subtraction of square
roots is used. The `b=0` control and +/-600 scale controls are covered.

The native rows use an explicit `double(A)` conversion and identify that
conversion in the row record. They are separate comparison rows, never an
implicit binary64 fallback for an MP solve.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_nro_selftest(); assert(report.ok); fprintf('SVT04 NRO selftest PASS rows=%d\\n', report.measured_rows);"
```

Observed result: `SVT04 NRO selftest PASS rows=84` under GNU Octave 11.1.0
with MPLAPACK 3.0.1 from the recorded local stack. The wall covered all
three S1 fixtures in smoke (2 MP precisions) and demo (3 MP precisions), both
`values` and `econ` modes, and one explicit native row for each mode. Thus
the measured count is `(3*2*2*2) + (5*3*2*2) = 84`.

The constructor gate also checked exact inverse multiplication, full-rank and
determinant invariants, reciprocal pairs, sorted nonnegative references,
zero-level construction, scale-up construction, insufficient-parameter
rejection, and ambient precision restoration.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `35b6a89303d803c7cc3c27cc366d80f5ab11fe73`

Final commit: recorded after this report is committed

Tests: SVT04 constructor/invariant gate and 84 S1 measured rows PASS

Gate: PASS

Known limitations: S1 references are analytic/provisional at this milestone;
Tier V enclosure certification and other S/A families remain pending.
