# SVT03 report

## Result

SVT03: PASS. The measured values-only/economy runner, frozen-input
reference path, provisional reference comparison, and MP reevaluation
diagnostics are implemented in the example tree.

## Implemented paths

```text
examples/svd_tiers/private/svt_run_svd.m
examples/svd_tiers/private/svt_metrics.m
examples/svd_tiers/private/svt_reference.m
examples/svd_tiers/private/svt_compare_references.m
examples/svd_tiers/svt_svd_contract_selftest.m
```

The runner calls the existing public `mp` SVD interface once per requested
mode: one-output `svd(A)` for values and `[U,S,V] = svd(A, "econ")` for
economy factors. It checks dimensions, real finite nonnegative descending
singular values, the complex `V` (not `V'`) convention, and input
immutability. Returned values are widened for diagnostics by adding an exact
zero at the requested target precision; no text or binary64 conversion is
used.

The metric layer computes reconstruction, two triplet residuals, and both
factor orthogonality residuals with MP arithmetic. A zero-norm input is
reported with absolute diagnostics rather than divided by zero. The
reference comparison remains explicitly `consistent_reference`; it does not
claim verification and marks values below the declared resolution floor as
unresolved.

## Gate and command

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
tools/dev-octave.sh --eval \
  "addpath('examples/svd_tiers'); report=svt_svd_contract_selftest(); assert(report.ok); disp('SVT03 selftest PASS');"
```

Observed result: `SVT03 selftest PASS` under GNU Octave 11.1.0 with the
source-tree native module and the candidate MPLAPACK 3.0.1 environment.
The test covered real values/economy modes, complex economy factors, zero
input handling, 128/256-bit reference comparison, below-resolution
classification, ambient precision restoration, shapes, and input
immutability. The test deliberately uses a residual threshold compatible
with the 256-bit solver input; widening an already computed result cannot
recover precision discarded by that solve.

Branch: `topic/svd-tier-sav-examples`

Starting commit: `71861dcb8ad182442d30f770a55f049fe67f055b`

Final commit: recorded after this report is committed

Tests: SVT03 measured-runner selftest PASS

Gate: PASS

Known limitations: family-specific constructors, full profile execution,
dyadic serialization, and Tier V certificates remain pending. Provisional
references are not certificates.
