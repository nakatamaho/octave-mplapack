# Ozaki--Ogita real standard form

**Corresponding example:** `examples/tiered/neig-tier-s/oo53_real.m`

**Original tier/source:** The source is the manifest entry plus `docs/codex/neigt/GENERATOR-OO.md`; its requested and realized standard forms remain separate.

## Question

The fixed-precision error-free triple-product generator in real standard form. This is a one-case view of the repository's S tier; the complete profile remains the regression authority.

## Matrix or problem

S1 Ozaki--Ogita exact triple-product generator in real standard form, with n=8 and generation precision 53 bits.

The case ID, profile membership, dimensions, and parameters come from `docs/codex/neigt/cases.json`. The short example does not silently replace the frozen represented input with a textbook proxy.

## Why it is difficult

Fixed generation precision and paired-block arithmetic make a residual-only reading unsafe; a requested spectrum is not silently substituted.

The tier label is project-specific QA terminology, not a universal mathematical classification. A small residual is evidence that the computed factors satisfy an equation; it is not by itself a forward-error, conditioning, or stability certificate.

## What the example calls

`mp_neig_tiers` with `tier="S"`, `case_id="OO53_REAL"`, and the public `eig` path. The operation restores the caller's ambient `mpbits()` default after the run. Native controls, work-precision results, reference values, and diagnostics are separate records.

## What to inspect

Inspect `A*V-V*D`, `W'*A-D*W'`, one-to-one eigenvalue matching, and the recorded generation/solver/reference precisions.

For a general eigensystem, inspect `A*V-V*D` and `W'*A-D*W'`. Match eigenvalues bijectively rather than by returned position; account for eigenvector phase and scale. Compare `balance` and `nobalance` only as explicitly labeled solver modes.

## Expected qualitative behavior

The actual runner preserves the realized spectrum and exactness checks; the short script is only a one-case view.

## Why multiple precision helps—and does not

The `mp` input is constructed and solved at the manifest's stored MPFR/MPC precision; the runner never routes a measured row through builtin binary64 complex arithmetic. Higher precision can preserve dyadic/decimal input data, reduce rounding error, and reveal smaller residuals or tail values. It cannot remove intrinsic eigenvalue/eigenvector conditioning, nonnormality, repeated-subspace nonuniqueness, rank thresholds, or a defective Jordan structure.

## Try changing this

Run the matching file after changing `mpbits()` before the input is created, then compare the recorded work and reference roles. For sensitive cases, vary the case parameter in a copied experiment and label the result as a new represented input. Do not edit the manifest fixture while interpreting the original case.

## Common mistakes

Do not compare eigenvalue vectors by index; do not call a repeated or defective cluster a set of simple roots; do not confuse an invariant-subspace certificate with an isolated spectral cluster; and do not use a transpose in place of the complex left-vector convention.

## References

- `docs/codex/neigt/cases.json` — exact case identity and profile parameters.
- `docs/codex/neigt/CASES.md` — matrix formula, exactness rules, and interpretation.
- `docs/codex/neigt/SOURCES.md` — source attribution and adaptation boundary.

## Implementation note

This file is a pedagogical front door only. The full NEIGT runner, manifest coverage, references, and verification jobs remain in `examples/neig_tiers/`. No package numerical implementation is duplicated here, and no new installed API is introduced.
