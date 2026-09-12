# Raw graded bidiagonal

**Corresponding example:** `examples/tiered/svd-tier-a/bidiag_raw.m`

**Original tier/source:** The exact raw formula and mixed variant are in `docs/codex/svt/CASES.md` Section A3.

## Question

A graded bidiagonal matrix with dyadic diagonal and superdiagonal. This is a one-case view of the repository's A tier; the complete profile remains the regression authority.

## Matrix or problem

A3 raw graded upper bidiagonal of order 8 with dyadic diagonal/superdiagonal and a=4.

The case ID, profile membership, dimensions, and parameters come from `docs/codex/svt/cases.json`. The short example does not silently replace the frozen represented input with a textbook proxy.

## Why it is difficult

The bidiagonal structure is simple to print but its singular values can span many scales.

The tier label is project-specific QA terminology, not a universal mathematical classification. A small residual is evidence that the computed factors satisfy an equation; it is not by itself a forward-error, conditioning, or stability certificate.

## What the example calls

`mp_svd_tiers` with `tier="A"`, `case_id="A3-BDI-RAW"`, and the public `svd` path. The operation restores the caller's ambient `mpbits()` default after the run. Native controls, work-precision results, reference values, and diagnostics are separate records.

## What to inspect

The case runner records reconstruction, orthogonality/unitarity, ordered nonnegative singular values, input identity, and precision roles. Inspect reconstruction, ordered values, and rank/condition estimates.

For SVD, inspect `A-U*S*V'`, `U'*U`/`V'*V` (or complex unitarity), descending nonnegative `diag(S)`, economy/full shapes, and rank/tolerance behavior where relevant. Factor signs and complex phases are not canonical.

## Expected qualitative behavior

Do not assume a bidiagonal matrix has diagonal singular values.

## Why multiple precision helps—and does not

The `mp` input is constructed and solved at the manifest's stored MPFR/MPC precision; the runner never routes a measured row through builtin binary64 complex arithmetic. Higher precision can preserve dyadic/decimal input data, reduce rounding error, and reveal smaller residuals or tail values. It cannot remove intrinsic eigenvalue/eigenvector conditioning, nonnormality, repeated-subspace nonuniqueness, rank thresholds, or a defective Jordan structure.

## Try changing this

Run the matching file after changing `mpbits()` before the input is created, then compare the recorded work and reference roles. For sensitive cases, vary the case parameter in a copied experiment and label the result as a new represented input. Do not edit the manifest fixture while interpreting the original case.

## Common mistakes

Do not compare repeated singular vectors column by column; do not use `U*S*V.'` for a complex case; do not infer rank without stating a tolerance; and do not treat a broad valid interval or a failed sufficient condition as a singularity proof.

## References

- `docs/codex/svt/cases.json` — exact case identity and profile parameters.
- `docs/codex/svt/CASES.md` — matrix formula, exactness rules, and interpretation.
- `docs/codex/svt/SOURCES.md` — source attribution and adaptation boundary.

## Implementation note

This file is a pedagogical front door only. The full SVT runner, manifest coverage, references, and verification jobs remain in `examples/svd_tiers/`. No package numerical implementation is duplicated here, and no new installed API is introduced.
