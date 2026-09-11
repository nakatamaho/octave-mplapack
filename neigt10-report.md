# NEIGT10 report

Task and milestone: NEIGT — Grcar and Morimoto--Katori--Shirai model 1.

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `fed4fe205907f9dfb2c9183cd4c77717c5477449`

## Implemented

- Added the declared exact `0,+/-1` Grcar Hessenberg constructor and a pair of
  general MP eig references at distinct precisions. No analytic Grcar spectrum
  is assumed.
- Added the MKS `N^m + delta*ones` model, reduced polynomial and companion
  reference. Exact zero roots are appended only to the reference; the measured
  dense eig output remains untouched.
- Added independent small determinant checks, exact algebraic zero/geometric
  multiplicity fields, and an MP Euclidean polynomial gcd guard for the reduced
  polynomial and its derivative.

## Gate

NEIGT10: **PASS** — Grcar n=6 exact entries, two-precision reference agreement,
MKS n=6,m=3 determinant identities, q coefficients, zero multiplicities,
square-free reduced polynomial, nonzero reference agreement, and dense measured
residuals all pass.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `fed4fe205907f9dfb2c9183cd4c77717c5477449`
Final commit: pending NEIGT10 commit
Files changed: `examples/neig_tiers/private/net_grcar_model.m`,
`net_grcar_reference.m`, `net_grcar_audit.m`, `net_mks_model.m`,
`net_mks_reference.m`, `net_mks_audit.m`, `net_polynomial_gcd.m`,
`test/test_neigt10.m`
Commands run: `PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib CPATH=/home/docker/opt/octave-mplapack-stack/include timeout 300s octave-cli --no-gui --quiet --no-init-file --path /tmp/neigt-work2/inst --path /tmp/neigt-work2/src --eval 'run("/tmp/neigt-work2/test/test_neigt10.m");'` (exit 0)
Tests: Grcar n=6 and MKS n=6,m=3 at MP reference precision
Gate: NEIGT10 PASS
Known limitations: full ordinary profile integration and Tier V proof layer
remain pending; MKS determinant auditing is intentionally bounded to the small
independent-checker dimensions.
