# NEIGT05 report

Task and milestone: NEIGT — exact simple, repeated, defective, and merged
similarity regimes.

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `c88fef1`

## Implemented

- Added one exact S2 audit for SIM_SIMPLE, SIM_REPEAT, SIM_JORDAN, and
  SIM_TWO_JORDAN using the existing finite-series inverse pair.
- Added independently computed characteristic evaluations at integer points,
  exact `X*A=J*X` and `A*Y=Y*J` checks, and guarded nilpotent first/second-power
  checks.
- Added nontrivial range(Y(:,J)) QR subspace diagnostics with explicitly labeled
  orthogonal projectors, separate from the oblique spectral projector.
- Kept algebraic/geometric multiplicity and diagonalizability as exact-J model
  facts; no disk count or approximate basis is promoted to a proof.

## Gate

NEIGT05: **PASS** — all four regimes pass at n=8 and the merged two-Jordan
n=16 audit. Semisimple multiplicity is distinguished from defect, Jordan cases
are not reported as diagonalizable, and nontrivial invariant subspaces are
checked independently of solver output.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `c88fef1`
Final commit: pending NEIGT05 commit
Files changed: `examples/neig_tiers/private/net_similarity_audit.m`,
`test/test_neigt05.m`
Commands run: `tools/dev-octave.sh --eval 'run("test/test_neigt05.m");'`
Tests: four n=8 regimes plus merged n=16; characteristic, nilpotent,
intertwining, multiplicity, diagonalizability, and subspace checks PASS
Gate: NEIGT05 PASS
Known limitations: remaining ordinary families and Tier V proof layer pending
