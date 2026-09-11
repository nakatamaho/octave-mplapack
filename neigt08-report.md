# NEIGT08 report

Task and milestone: NEIGT — reuse Hadamard and Frank without semantic drift.

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `fbb9a6441e1e04dd25c0148d70d69aa772a167cf`

## Implemented

- Added explicit A1 Hadamard-similar upper-bidiagonal construction and its
  multiplicative-recurrence individual condition reference.
- Added explicit A2 Frank F0 and reflected F1 definitions, rather than relying
  on an unexamined gallery convention.
- Added an independent Hermite–Jacobi symmetric reference, reciprocal/positive
  checks, exact odd central root handling, and the small characteristic
  recurrence with determinant/Horner checks. The determinant identity check
  uses independent fraction-free MP elimination, rather than the numerical
  `det` result or solver output.
- Connected both orientations through the MP minimum-bottleneck matcher while
  preserving existing nonsymmetric-eig examples and helpers.

## Gate

NEIGT08: **PASS** — Hadamard spectrum/metrics, Frank n=5/n=8 orientations,
characteristic checks, reflection identity, positivity, reciprocal pairing, and
the odd central root all pass.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `fbb9a6441e1e04dd25c0148d70d69aa772a167cf`
Final commit: pending NEIGT08 commit
Files changed: `examples/neig_tiers/private/net_hadamard_model.m`,
`net_hadamard_reference.m`, `net_frank_model.m`, `net_frank_reference.m`,
`net_frank_polynomial.m`, `net_frank_audit.m`,
`net_exact_det_permutation.m`, `test/test_neigt08.m`
Commands run: `PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib CPATH=/home/docker/opt/octave-mplapack-stack/include octave-cli --no-gui --quiet --no-init-file --path /tmp/neigt-work2/inst --path /tmp/neigt-work2/src --eval 'run("/tmp/neigt-work2/test/test_neigt08.m");'` (exit 0; an initial permutation-expansion implementation timed out and was replaced by the independent fraction-free checker)
Tests: Hadamard n=8; Frank n=5/n=8; independent references and recurrence PASS
Gate: NEIGT08 PASS
Known limitations: the checker is limited to small matrices (1-by-1 through
8-by-8); later Wilkinson/Grcar/Markov profile integration and the Tier V proof
layer remain pending.
