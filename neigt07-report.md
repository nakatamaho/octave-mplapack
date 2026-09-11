# NEIGT07 report

Task and milestone: NEIGT — Forsythe split, scaled, and zero-limit family.

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `05a64e4`

## Implemented

- Added direct exact MP constructors for the original Forsythe matrix, the
  explicitly scaled normal cyclic-shift form, and the zero-limit Jordan form.
- Verified `F*D=D*F_scaled` with the independent dyadic denominator checker.
- Added MP unit-circle references with exact real endpoints for odd and even n.
  Circle matching is performed on `(lambda-1)/r`, not ordinary relative error.
- Added a zero-limit nilpotency audit and explicitly marked unique-eigenvector
  and nontrivial cluster targets as not applicable/deferred to SIM_JORDAN.
- Added original/scaled balance-mode forward measurements without asserting a
  balancing-improvement requirement.

## Gate

NEIGT07: **PASS** — odd/even nonzero cases, exact scaling, circle matching, and
the n=8 zero-limit nilpotency audit pass. No nonexistent full eigenbasis is
claimed for the zero-limit Jordan matrix.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `05a64e4`
Final commit: pending NEIGT07 commit
Files changed: `examples/neig_tiers/private/net_mp_complex.m`,
`net_forsythe_model.m`, `net_forsythe_reference.m`, `net_forsythe_audit.m`,
`test/test_neigt07.m`
Commands run: `tools/dev-octave.sh --eval 'run("test/test_neigt07.m");'`
Tests: odd/even original/scaled circle rows and zero-limit n=8 PASS
Gate: NEIGT07 PASS
Known limitations: remaining ordinary families and Tier V proof layer pending
