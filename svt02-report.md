# SVT02 report

## Result

SVT02: PASS. The common exact-construction layer is implemented in the
example tree. No SVD driver, package API, MPLAPACK source, or installed
method was changed.

## Implemented paths

```text
examples/svd_tiers/private/svt_ceil_log2_integer.m
examples/svd_tiers/private/svt_pow2.m
examples/svd_tiers/private/svt_hadamard.m
examples/svd_tiers/private/svt_mix.m
examples/svd_tiers/private/svt_known_projector.m
examples/svd_tiers/private/svt_require_guard.m
examples/svd_tiers/private/svt_phase_diagonal.m
examples/svd_tiers/private/svt_case_identity.m
examples/svd_tiers/svt_construction_selftest.m
```

`svt_hadamard` constructs Sylvester `H` and the prescribed one-row downward
shift `G` as dense `mp` matrices. `svt_mix` implements `H*B*G'/n` and avoids
forming `sqrt(n)`. `svt_pow2` uses native MP arithmetic for exact powers of
two, including the +/-600 demo scales. The integer log guard uses only exact
small-integer comparison. Quarter-turn phases and known Hadamard projectors
are available for subsequent family/control milestones.

`svt_case_identity` records model/represented shapes, stored precisions,
construction precision, real/complex kind, and exactness label without
claiming a certificate. `svt_require_guard` fails closed below a declared
construction guard.

## Gate and commands

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
tools/dev-octave.sh --eval \
  "addpath('examples/svd_tiers'); report=svt_construction_selftest(); assert(report.ok);"
```

Observed result: `SVT02 selftest PASS` under GNU Octave 11.1.0, with the
source-tree native module and MPLAPACK 3.0.1 environment recorded in SVT00.
The test covered Hadamard orders 1, 2, 4, 8, and 16; exact `H*H'`/`G*G'`
identities; the signed phase identity; fixed mixing; +/-600 power-of-two
round trips; insufficient-guard rejection; invalid construction inputs; and
input identity metadata.

Branch: `topic/svd-tier-sav-examples`
Starting commit: `ae72b006f0b7c4e5df2b8758d2e9c56b3df72893`
Final commit: recorded after this report is committed
Files changed: eight private construction helpers, `svt_construction_selftest.m`, `svt02-report.md`
Commands run: the SVT02 selftest command above
Tests: SVT02 construction selftest PASS
Gate: PASS
Known limitations: family-specific constructors and all measured SVD/V jobs remain pending
