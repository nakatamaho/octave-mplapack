# N07 report — numerical API closure

## Result

N07 PASS — the 0.3.0-dev numerical API is closed on
`topic/d01r1-mplapack-interop`. N07 adds no new numerical algorithm.

## Closure

The public documentation now covers norm, determinant/inverse, SVD,
rank/condition, structured and general standard eig, generalized eig, the
precision/ownership contract, and the supported dense real/complex surface.
The permanent Grcar example `examples/06_grcar_eig.m` uses
`gallery("grcar",32)`, transfers the fixture to MP storage, and computes the
eig residual with native high-precision operations.

The compatibility firewall confirms clean rejection of standalone `schur`,
`qz`, `hess`, `expm`, `logm`, sparse/N-dimensional values, powers,
comparisons/logical operations, and right division. Dense generalized eig is
now supported through N06 and is no longer listed as a deferred API.

## QA

```text
N07 public compatibility firewall: PASS
N07 permanent Grcar(32) residual: PASS
Grcar high-precision example at 1024 bits: PASS
standard/generalized eig API documentation: PASS
full test/run_tests.m (M00-M23, C00-C12 including C11L, N00-N07): PASS
native ASan/UBSan/LSan wall: PASS
full tools/local-ci.sh: PASS (exit code 0)
```

## Gates

```text
G-N07-API:          PASS
G-N07-DOCS:         PASS
G-N07-GRCAR:        PASS
G-N07-FIREWALL:     PASS
G-N07-REGRESSION:   PASS
```

The N07 implementation, documentation, and final regression evidence are
recorded in `docs/goals/N00-N07-D02-status.md`. D02 is the separate release
engineering milestone and is not started by this report.
