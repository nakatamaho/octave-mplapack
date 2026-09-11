# NEIGT09 report

Task and milestone: NEIGT — Wilkinson and polynomial backward error.

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `3407a72e56c2e25f0a1b95f5ea2c3c38be55918c`

## Implemented

- Added the exact coefficient recurrence for the Frobenius companion of
  `product(z-j)`, its explicit first-row/subdiagonal construction, and a
  separately recorded once-rounded work input.
- Added the guarded integer-root Horner reference. It does not use `poly` or
  eigenvalues to construct the coefficients.
- Added the non-monic complex coefficientwise indicator
  `abs(p(z))/sum(abs(c_j)*abs(z)^(n-j))`, including the exact zero-denominator
  case. Model and frozen-input indicators remain separate fields.

## Gate

NEIGT09: **PASS** — exact n=4 coefficients and companion entries, guarded
Horner zero checks, n=6 MP root matching, matrix residuals, polynomial
backward-error indicators, complex evaluation, and zero-denominator handling
all pass.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `3407a72e56c2e25f0a1b95f5ea2c3c38be55918c`
Final commit: pending NEIGT09 commit
Files changed: `examples/neig_tiers/private/net_wilkinson_model.m`,
`net_wilkinson_reference.m`, `net_polynomial_backward_error.m`,
`net_wilkinson_audit.m`, `test/test_neigt09.m`
Commands run: `PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib CPATH=/home/docker/opt/octave-mplapack-stack/include timeout 240s octave-cli --no-gui --quiet --no-init-file --path /tmp/neigt-work2/inst --path /tmp/neigt-work2/src --eval 'run("/tmp/neigt-work2/test/test_neigt09.m");'` (exit 0)
Tests: exact recurrence/Horner and n=6 MP eig/backward-error audit
Gate: NEIGT09 PASS
Known limitations: full 120/168 profile integration and Tier V proof layer
remain pending; this audit does not claim a companion-QR implementation.
