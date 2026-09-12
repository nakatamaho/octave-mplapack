# Nonnormal Toeplitz representation

**Corresponding example:** `examples/tiered/neig-tier-s/toeplitz.m`

**Original tier/source:** The formula and analytic circle reference are in `docs/codex/neigt/CASES.md` Section 3.

## Question

The diagonally scaled nonsymmetric tridiagonal Toeplitz model. This is a one-case view of the repository's S tier; the complete profile remains the regression authority.

## Matrix or problem

S3 original coordinates: diagonal 3, upper `2^(-2b)`, lower 1, with n=16 and b=4.

The case ID, profile membership, dimensions, and parameters come from `docs/codex/neigt/cases.json`. The short example does not silently replace the frozen represented input with a textbook proxy.

## Why it is difficult

A diagonal similarity hides severe eigenvector scaling while the eigenvalues can remain well spaced.

The tier label is project-specific QA terminology, not a universal mathematical classification. A small residual is evidence that the computed factors satisfy an equation; it is not by itself a forward-error, conditioning, or stability certificate.

## What the example calls

`mp_neig_tiers` with `tier="S"`, `case_id="TOEPLITZ"`, and the public `eig` path. The operation restores the caller's ambient `mpbits()` default after the run. Native controls, work-precision results, reference values, and diagnostics are separate records.

## What to inspect

Inspect `A*V-V*D`, left residuals, analytic circle matching, and individual left/right conditions.

For a general eigensystem, inspect `A*V-V*D` and `W'*A-D*W'`. Match eigenvalues bijectively rather than by returned position; account for eigenvector phase and scale. Compare `balance` and `nobalance` only as explicitly labeled solver modes.

## Expected qualitative behavior

MP controls arithmetic; it does not turn the original nonnormal matrix into the symmetric control.

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
