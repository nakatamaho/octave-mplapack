# NEIGT03 report

Task and milestone: NEIGT — MP minimum-bottleneck matching, metrics, and
reference roles.

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `fc9ef380a7205958d151e2f7f36ef2ed176369d7`

## Implemented

- Added `net_match`, an example-local facade over the existing tested
  deterministic bijective minimum-bottleneck matcher, with explicit method
  identity and no native-double cost path.
- Added raw right/left residuals, column residuals, simple-root condition status,
  zero-root relative-match handling, and the correct complex left convention.
- Added an exact-algebraic S2 reference role that widens the fixed model without
  rebuilding it or replacing measured eig outputs.
- Added focused duplicate/missing-root, tiny `2^-1500`, wrong-left-conjugation,
  and defective-condition-status tests.

## Gate

NEIGT03: **PASS** — MP matching is bijective/minimum-bottleneck, the complex left
identity is enforced, zero and defective cases are labeled separately, and
reference/model/output roles remain distinct.

Known limitations: structured analytic references, ordinary profile dispatch,
and Tier V certificate arithmetic are later milestones.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `fc9ef380a7205958d151e2f7f36ef2ed176369d7`
Final commit: pending NEIGT03 commit
Files changed: `net_match.m`, `net_metrics.m`, `net_reference.m`, `test/test_neigt03.m`
Commands run: `tools/dev-octave.sh --eval 'run("test/test_neigt03.m");'`
Tests: NEIGT03 focused matching/metrics/reference test PASS
Gate: NEIGT03 PASS
Known limitations: later families and proof layer pending
