# SVT07 report

## Result

SVT07: PASS. The symmetric and nonsymmetric diagonally-dominant path
constructors are implemented, including the exact-`tau` model, deliberate
below-guard rounding control, symmetric analytic spectrum, and the `tau=0`
rank proof metadata. All S4 smoke/demo rows passed.

## Implemented paths

```text
examples/svd_tiers/private/svt_make_dd_path.m
examples/svd_tiers/svt_dd_selftest.m
```

The constructor uses MP dyadic `tau=2^-b` and rational dyadic `rho`. It keeps
the exact model separate from the represented work-precision input. For the
demo 128-bit rows with `b=160`, `1+tau`/`rho+tau` intentionally round to the
declared `tau=0` represented path and are labeled accordingly; these rows are
not judged as if they still contained tau. The leading principal determinant
recurrence is recorded as ones with full determinant zero for that control.

For the symmetric path, the ascending analytic values use
`tau + 4*sin(k*pi/(2*n))^2`, with `pi=acos(mp(-1))` and all trigonometric
arguments in MP. The nonsymmetric path deliberately has no claim that tau is
the smallest singular value; its values remain provisional dense-SVD
references.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_dd_selftest(); assert(report.ok); fprintf('SVT07 DD selftest PASS rows=%d\\n', report.measured_rows);"
```

Observed result: `SVT07 DD selftest PASS rows=40` under GNU Octave 11.1.0
with the recorded MPLAPACK 3.0.1 environment. The wall covers the two S4
fixtures at smoke 128/256 bits and demo 128/256/512 bits, both `values` and
`econ` modes, and one explicit native comparison row per mode. The count is
`(2*2*2*2) + (2*3*2*2) = 40`.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `c965768d9c5f0a963aaf82aed9430a6ad8b7f428`

Final commit: recorded after this report is committed

Tests: constructor/model separation, tau-loss control, rank proof, and 40 S4 measured rows PASS

Gate: PASS

Known limitations: the transcendental symmetric values are analytic but not
yet certified intervals; Tier V and the remaining S/A families remain pending.
