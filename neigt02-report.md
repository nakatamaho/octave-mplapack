# NEIGT02 report

Task and milestone: NEIGT — exact construction, freezing, and widening.

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `75cd5f126e46044f314ecd4bd2b1239f74da2f84`

## Implemented

- Added example-local exact power-of-two, Hadamard, unit-triangular inverse,
  bit-length, product-guard, similarity, model, and widening helpers.
- Constructed `X=(I+N')*(I+N)` and
  `Y=(I+N)^(-1)*(I+N')^(-1)` by finite nilpotent series, then independently
  checked both `X*Y=I` and `Y*X=I`.
- Added the four S2 regimes' exact model constructor with distinct model/frozen/
  native fields. The native value is a single explicit conversion of the fixed
  exact model; it is not used as an MP solver input.
- Added the NEIGT02 focused test, including 1024-bit `2^-700`, 2048-bit
  `2^-1500`, source immutability, and below-target widening rejection.

## Gate

NEIGT02: **PASS** — exact similarity identities, Hadamard orthogonality,
conservative integer product guards, one-time native rounding, exact widening,
and precision-tail retention passed.

Known limitations: OO-specific generation and the remaining S/A families are
not implemented until their declared milestones; no Tier V claim is made.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `75cd5f126e46044f314ecd4bd2b1239f74da2f84`
Final commit: pending NEIGT02 commit
Files changed: exact-construction helpers and `test/test_neigt02.m`
Commands run: `tools/dev-octave.sh --eval 'run("test/test_neigt02.m");'`
Tests: NEIGT02 focused construction/widening test PASS
Gate: NEIGT02 PASS
Known limitations: later S/A/V layers pending
