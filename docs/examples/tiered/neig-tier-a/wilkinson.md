# Wilkinson companion-like matrix

**Corresponding example:** `examples/tiered/neig-tier-a/wilkinson.m`

**Original tier/source:** The recurrence and companion construction are recorded in the NEIG source ledger and manifest.

## Question

The recurrence-generated Wilkinson polynomial companion model. This is a one-case view of the repository's A tier; the complete profile remains the regression authority.

## Matrix or problem

A2 recurrence-generated Wilkinson polynomial companion model with n=10.

The case ID, profile membership, dimensions, and parameters come from `docs/codex/neigt/cases.json`. The short example does not silently replace the frozen represented input with a textbook proxy.

## Why it is difficult

Clustered roots and companion scaling can make tiny forward errors coexist with large vector sensitivity.

The tier label is project-specific QA terminology, not a universal mathematical classification. A small residual is evidence that the computed factors satisfy an equation; it is not by itself a forward-error, conditioning, or stability certificate.

## What the example calls

`mp_neig_tiers` with `tier="A"`, `case_id="WILKINSON"`, and the public `eig` path. The operation restores the caller's ambient `mpbits()` default after the run. Native controls, work-precision results, reference values, and diagnostics are separate records.

## What to inspect

Inspect matched forward error, residuals, root separations, and native rounded-input status.

For a general eigensystem, inspect `A*V-V*D` and `W'*A-D*W'`. Match eigenvalues bijectively rather than by returned position; account for eigenvector phase and scale. Compare `balance` and `nobalance` only as explicitly labeled solver modes.

## Expected qualitative behavior

The runner records realized roots; known polynomial roots are not substituted into measured output.

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
