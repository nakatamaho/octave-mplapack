# SVT09 report

## Result

SVT09: PASS. The A2 dyadic Vandermonde and A3 graded bidiagonal raw/mixed
families are implemented and their exactness/model checks pass. The A2/A3
smoke/demo measurement wall passed before the next milestone.

## Implemented paths

```text
examples/svd_tiers/private/svt_make_vandermonde.m
examples/svd_tiers/svt_vandermonde_selftest.m
examples/svd_tiers/private/svt_make_bidiagonal.m
examples/svd_tiers/svt_bidiagonal_selftest.m
```

The Vandermonde constructor uses exact MP nodes `i/2^d` and successive MP
powers, records the `n < 2^d` and
`2+(n-1)ceil_log2(n)` guards, and proves distinct positive nodes. The
bidiagonal constructor uses one-bit dyadic diagonal/superdiagonal entries,
the existing exact Hadamard equivalence for the mixed representation, and the
`a*(n-1)+4` guard. No generic dense HRA guarantee or new driver is claimed.

The A3 raw/mixed singular-value comparison was made at 512 bits after exact
widening. It is a provisional numerical consequence check; it is not a Tier V
certificate.

## Gate and commands

Vandermonde:

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_vandermonde_selftest(); assert(report.ok);"
```

Bidiagonal:

```sh
octave --no-gui --quiet --no-init-file --path inst --path src --eval \
  "addpath('examples/svd_tiers'); report=svt_bidiagonal_selftest(); assert(report.ok);"
```

Observed results: `SVT09 Vandermonde selftest PASS rows=20` and
`SVT10 bidiagonal selftest PASS rows=40` under GNU Octave 11.1.0 with the
recorded MPLAPACK 3.0.1 environment. Combined A2/A3 coverage is 60 measured
rows: each family has smoke 128/256-bit and demo 128/256/512-bit MP rows,
both `values` and `econ` modes, plus one explicit native comparison row per
mode.

The source history contains two implementation commits because the A2 and A3
families were developed consecutively: A2 ended at
`f99c92421946530eb519555e6a279dd2f9b5302a`, and A3 ended at
`0de2e170ac1b11c72d4f88c5ae2747b7214cded4`. This correction records the
authoritative SVT09 scope from `MILESTONES.md`; no numerical code was removed.

Branch: `topic/svd-tier-sav-examples`

Tests: A2/A3 constructor gates and 60 measured rows PASS

Gate: PASS

Known limitations: all references remain provisional until the Tier V
outward-certification milestones.
