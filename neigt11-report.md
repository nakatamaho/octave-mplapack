# NEIGT11 report

Task and milestone: NEIGT — stochastic and positive Perron models.

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `3a9a4ce6e85ed82bc4063768eee5a3738dd9cc9a`

## Implemented

- Added exact lazy cyclic block construction, nonuniform dyadic teleportation,
  the Markov matrix and a separate once-rounded native representation.
- Added the positive Perron matrix by explicit binary diagonal scaling, with
  distinct Markov/Perron spectra and no forced row-sum repair.
- Added Fourier-mode spectrum references plus two stationary linear solves:
  the specified formula solve and an independently normalized stationary system.
- Added positive normalized right/left Perron vectors. The left vector is
  derived from the solved stationary vector, not substituted with `r`.

## Gate

NEIGT11: **PASS** — n=8, epsilon=2^-24 exact row sums and positivity, analytic
spectrum matching, independent stationary equations and agreement, nontrivial
stationary-vs-teleportation distinction, and normalized positive Perron
eigenvector equations all pass.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `3a9a4ce6e85ed82bc4063768eee5a3738dd9cc9a`
Final commit: pending NEIGT11 commit
Files changed: `examples/neig_tiers/private/net_markov_model.m`,
`net_perron_model.m`, `net_markov_reference.m`, `net_markov_audit.m`,
`test/test_neigt11.m`
Commands run: `PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib CPATH=/home/docker/opt/octave-mplapack-stack/include timeout 300s octave-cli --no-gui --quiet --no-init-file --path /tmp/neigt-work2/inst --path /tmp/neigt-work2/src --eval 'run("/tmp/neigt-work2/test/test_neigt11.m");'` (exit 0)
Tests: Markov/Perron n=8, epsilon=2^-24, 256-bit measured/reference audit
Gate: NEIGT11 PASS
Known limitations: complete 120/168 ordinary profile integration and Tier V
proof layer remain pending; analytic Fourier values use MP `acos(mp(-1))` and
are numerical references, not interval certificates.
