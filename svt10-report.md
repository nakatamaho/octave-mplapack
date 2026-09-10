# SVT10 report

## Result

SVT10: PASS. The graded bidiagonal raw/mixed pair is implemented with exact
dyadic entries and the prescribed Hadamard two-sided mixing. The raw/mixed
singular-spectrum cross-check and all A3 smoke/demo rows passed.

## Implemented paths

```text
examples/svd_tiers/private/svt_make_bidiagonal.m
examples/svd_tiers/svt_bidiagonal_selftest.m
```

The raw matrix uses the one-bit entries
`B(i,i)=2^(-a*(i-1))` and
`B(i,i+1)=2^(-a*(i-1)-1)`. The mixed representation reuses the exact dense
`H*B*G'/n` helper, records the common-denominator guard
`a*(n-1)+4`, and retains the raw representation for independent comparison.
No HRA/LASQ1 binding or unconditional dense-driver guarantee is claimed.

At 512 bits the raw and mixed singular values agree within the focused
cross-check tolerance after exact widening; this is a numerical consequence
check, not a Tier V certificate.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_bidiagonal_selftest(); assert(report.ok); fprintf('SVT10 bidiagonal selftest PASS rows=%d\\n', report.measured_rows);"
```

Observed result: `SVT10 bidiagonal selftest PASS rows=40` under GNU Octave
11.1.0 with the recorded MPLAPACK 3.0.1 environment. The wall covers raw
and mixed A3 cases at smoke 128/256 bits and demo 128/256/512 bits, both
`values` and `econ` modes, and one explicit native row per mode.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `f99c92421946530eb519555e6a279dd2f9b5302a`

Final commit: recorded after this report is committed

Tests: exact raw/mixed construction, high-precision spectrum cross-check, and 40 A3 measured rows PASS

Gate: PASS

Known limitations: the raw/mixed agreement is provisional until independent
outward verification; no structured bidiagonal solver is implemented.
