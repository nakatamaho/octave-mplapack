# NEIGT01 report

Task and milestone: NEIGT — integration skeleton and manifest coverage.

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `7c98d86fa48c7b0e3a8ace458f431dcc2e384330`

## Implemented

- Allocated the next four example numbers without renumbering existing examples:
  `14_neig_tier_s.m`, `15_neig_tier_a.m`, `16_neig_verified_vs.m`, and
  `17_neig_verified_va.m`.
- Added the example-local `neig_tiers` facade and strict options parser.
- Added manifest loading/validation for `cases.json` and
  `verification-jobs.json`, preserving dyadic parameters as manifest strings and
  validating only bounded integer dimensions/counts as JSON integers.
- Added separate ordinary and verification facades with `scope_ok=true` for a
  parsed filtered scope and `ok=false`, `status=NOT_IMPLEMENTED` until the
  corresponding numerical milestones implement the requested rows.
- Added the NEIGT01 focused self-test and root-level report.

## Coverage audit

```text
smoke: 20 cases, 120 measured ordinary eig rows, 26 V jobs
demo:  21 cases, 168 measured ordinary eig rows, 26 V jobs
stress: 8 cases, 64 measured ordinary eig rows, no V schedule
filtered smoke S: 12 cases, 72 ordinary rows
filtered smoke A: 8 cases, 48 ordinary rows
filtered smoke V-S: 16 jobs
filtered smoke V-A: 10 jobs
```

No numerical row or verification job is claimed as implemented by this
milestone. The skeleton deliberately reports `NOT_IMPLEMENTED` and cannot
return `ok=true` for an all-tier run.

## Commands and results

```text
PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/dev-octave.sh --eval \
  'addpath("examples/neig_tiers"); r=mp_neig_tiers_selftest(); assert(r.ok);'
    PASS

PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/dev-octave.sh --eval \
  'run("test/test_neigt01.m");'
    PASS
```

The self-test verified unknown-option rejection, invalid-tier rejection,
filtered counts, all 26 job IDs per mandatory profile, manifest schema/version,
precision restoration, and path restoration. No source, dependency, installed
API, or compiler behavior was changed.

## Gate

NEIGT01: **PASS** — integration skeleton and manifest coverage are present, and
unimplemented numerical work is explicitly non-PASS.

Known limitations: all S/A constructors, ordinary eig rows, outward arithmetic,
certificates, output writers, and clean-package QA remain for later milestones.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `7c98d86fa48c7b0e3a8ace458f431dcc2e384330`
Final commit: pending NEIGT01 commit
Files changed: four numbered examples, `examples/neig_tiers/`, `test/test_neigt01.m`, `neigt01-report.md`
Commands run: manifest/profile self-test and focused NEIGT01 test
Tests: all NEIGT01 tests PASS; numerical work intentionally NOT_IMPLEMENTED
Gate: NEIGT01 PASS
Known limitations: no numerical implementation yet
