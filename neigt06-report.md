# NEIGT06 report

Task and milestone: NEIGT — tridiagonal Toeplitz and symmetric control.

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `40e3a74`

## Implemented

- Added direct exact constructors for `A=tridiag(1,3,2^(-2b))`,
  `B=tridiag(2^-b,3,2^-b)`, and `D=diag(2^(b*j))`; B is constructed directly,
  never by an approximate inverse.
- Added common-dyadic-denominator verification of `A*D=D*B`.
- Added MP `acos(-1)`, sine/cosine references, closed-form left/right vectors,
  overlap checks, and individual eigenvalue condition values.
- Added separate matrix-A, scaling-D, similarity-scaling, and individual-root
  condition fields. Original-coordinate output remains explicitly labeled.
- Added n=2 and n=16 tests for both original and directly symmetric forms,
  including independent symmetric eig cross-checks and both balance modes where
  the original representation is measured.

## Gate

NEIGT06: **PASS** — Toeplitz similarity, stable MP references, symmetric control,
and separated condition semantics pass at the focused dimensions.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `40e3a74`
Final commit: pending NEIGT06 commit
Files changed: `examples/neig_tiers/private/net_toeplitz_model.m`,
`net_toeplitz_reference.m`, `net_toeplitz_audit.m`, `test/test_neigt06.m`
Commands run: `tools/dev-octave.sh --eval 'run("test/test_neigt06.m");'`
Tests: n=2 relation/overlap and n=16 original/symmetric measured audits PASS
Gate: NEIGT06 PASS
Known limitations: remaining ordinary families and Tier V proof layer pending
