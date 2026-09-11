# NEIGT04 report

Task and milestone: NEIGT — actual Ozaki–Ogita Theorem-1 generator.

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `c1505b2`

## Implemented

- Implemented the specified `L=I+N'`, `U=I+N`, finite nilpotent inverse pair
  and exact `XY=YX=I` checks.
- Implemented exact dyadic decomposition and comparison-based `ufp`, phi/psi
  lattice ratios, beta/gamma/theta/omega, alpha, sigma, and the Theorem-1
  predicate without native binary64 numerical evaluation.
- Implemented explicit scalar-by-scalar two-stage `RN_g` products and the
  `RN_g(RN_g(sigma+S)-sigma)` standard-form quantization.
- Implemented the paired real-block rule: one diagonal rounding is copied and
  the lower off-diagonal is the exact sign copy of the upper value.
- Preserved requested and realized standard forms/spectra, exact-product
  metadata, source/method identifiers, and deterministic model hashes.

## Gate

NEIGT04: **PASS** — six mandatory n=8/n=16 fixtures have exact inverse and
triple-product checks, requested/realized separation, deterministic generation,
and the OO53 paired-block and OO128 lost-2^-120 checks. Deliberately invalid
inverse and non-dyadic exact-product inputs are rejected.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `c1505b2`
Final commit: pending NEIGT04 commit
Files changed: `examples/neig_tiers/private/net_ufp.m`,
`net_dyadic_decompose.m`, `net_exact_product_dyadic.m`, `net_rounded_product.m`,
`net_oo_standard.m`, `net_oo_generator.m`, `net_oo_validate_pair.m`,
`test/test_neigt04.m`
Commands run: `tools/dev-octave.sh --eval 'run("test/test_neigt04.m");'`
Tests: six generator fixture loop, invalid-pair trap, non-dyadic trap PASS
Gate: NEIGT04 PASS
Known limitations: case-family integration and Tier V proof layer pending
