# Hadamard-mixed geometric spectrum (Tier A5)

## Quick idea

A5-GEO is a Tier A control. This is a dense matrix with a known geometrically decaying singular spectrum. It is one fixed matrix with one matching runnable example. The tier identifies the verification question, not a claim that public dense svd implements any cited structured algorithm.

## Mathematical problem

Smoke: n=8, a=4. Demo: n=16, a=8. The exact diagonal values are d_j=2^(-a(j-1)).

$$
A=H diag(d_1,...,d_n) G^T/n,
\qquad d_j=2^{-a(j-1)}.
$$
Orthogonal equivalence gives singular values exactly d_1,...,d_n.

## Why this problem is numerically difficult

This is a dense matrix with a known geometrically decaying singular spectrum. The source entries are finite signed sums of dyadics, so construction precision and cancellation need an explicit guard. A global reconstruction residual can conceal a small tail value; the geometric reference makes that failure visible.

The exact model, any analytic or structural reference, and measured SVD output are kept separate. A convenient identity is a check on the named matrix, never a silent replacement for it.

## What the Octave example computes

The matching [hadamard_geometric.m](../../../../examples/tiered/svd-tier-a/hadamard_geometric.m) selects only A5-GEO from the fixed manifest. The matching hadamard_geometric.m constructs H, G, and A in MP, runs svd, and compares all values with d. It checks the exact mixed-product identity, projectors for separated groups, reconstruction, and factor orthogonality. The measured dense input is not replaced by the diagonal source. The runner records shape, parameters, source/model identity, operation precision, and any native control while retaining MPFR/MPC arithmetic.

## Construction and exactness

Hadamard orthogonality and the common denominator bound are checked independently. The exact singular values follow from two-sided unitary equivalence, while the dense factorization is still measured. The zero-free source rank is known by construction.

Exactness is proved from the declared integer/dyadic construction and guard. Two agreeing MP computations are useful corroboration but are not an exactness proof. Binary64 conversion is allowed only at an explicitly labelled presentation boundary.

## Diagnostics

For $A\in\mathbb{C}^{m\times n}$, use
$$
A=U\Sigma V^{\mathsf H},\qquad
r_{\mathrm{svd}}=\frac{\lVert A-U\Sigma V^{\mathsf H}\rVert_F}{\lVert A\rVert_F},
\qquad
r_U=\lVert U^{\mathsf H}U-I\rVert_F,\quad
r_V=\lVert V^{\mathsf H}V-I\rVert_F.
$$
For a repeated or rank cluster compare the associated left/right projectors or ranges; individual factors are not canonical.

Also inspect the value-wise forward bottleneck, rank/cluster metric, and any model-specific identity. Keep residuals as MP values until display. A small reconstruction residual alone does not certify each singular value digit.

## Backward error versus forward error

The reconstruction residual is a backward-error style measure for the factorization equation: the returned factors nearly explain the stored A. Forward singular-value error compares values with the mathematical spectrum of that exact stored model and depends on gaps, scales, and conditioning. For repeated values the forward object is a subspace; for rank-deficient data exact model rank is separate from thresholding measured values.

## What arbitrary precision changes

Input/source precision is the guarded dyadic Hadamard product. Arithmetic precision controls construction and SVD. Mathematical conditioning increases across the geometric spectrum. More bits protect the tail but do not make the dense factors unique.

Input/source precision identifies the stored matrix and deliberate once-rounded variants. Arithmetic/work precision is the MPFR/MPC precision used by construction, SVD, and references. Mathematical conditioning belongs to the model and can remain severe at arbitrary precision. Raising mpbits reduces arithmetic error but does not restore a tail lost in the input or make a repeated basis unique. Ambient-precision and restoration tests protect operation ownership.

## Reading the output

Use relative error across the geometric scale and r_svd together. The singular-value order is canonical mathematically, but factor signs/phases are not. A good largest value is not evidence for the smallest.

A PASS line is scoped to this case and profile. Compare rows only when parameters and model identity match. If a rank, subspace, or exactness field is not claimed, do not infer it from a visually stable display.

## Common mistakes

Do not use H A H^T as the inverse operation, compare one absolute tolerance for all values, form A^T A, or treat the diagonal source as the measured dense input.

For diagnosis, verify case ID and shape, then model hash/input precision, then reconstruction and orthogonality, then the case-specific value or subspace metric. Do not change parameters after a failure and report the changed input as this case.

## Parameter boundary and comparison protocol

The parameter in this page is part of the case identity, not a tuning knob. Record n, the dyadic exponents, the representation (raw, mixed, tall, wide, complex, repeated, or rank-deficient), and the source/model hash before comparing outputs. A reference generated from a neighboring case can be mathematically related and still be the wrong target. This is especially important for a close pair, where replacing a nonzero gap by zero changes the forward problem, and for a rank case, where replacing an exact zero by a tiny positive number changes the rank.

Use a bijective matching for values and a phase-aware or subspace-aware comparison for factors. The matching is performed in MP arithmetic and is a diagnostic, not a way to hide an unmatched value. If the output shape is rectangular, state which economy/full convention is being used. If a factor is not identifiable because of a repeated singular value or a null space, report the projector or range and do not manufacture an individual-vector error. These rules make the short runner reproducible and keep its PASS result scoped to the named model.
## Scope of the claim

This page explains one fixed SVD model and the precise object that the runner measures. Changing a dimension, dyadic exponent, scale, phase, gap, or zero entry changes the source matrix and requires a new case identity. That is especially important for repeated and rank-deficient examples: a zero gap is not a tiny gap, and an exact zero is not merely a small positive singular value.

The analytic spectrum or projector is an independent model check. It is not inserted into the measured factorization, and the public dense SVD is not silently replaced by a structured bidiagonal or totally-nonnegative algorithm. Reconstruction, unitarity, value-wise forward error, and subspace comparisons answer different questions. The runner records all of them with the input and arithmetic precision roles. Binary64 is permitted only at an explicitly declared presentation boundary; it is never an unreported numerical fallback.
## References

- [Per-Åke Wedin, Perturbation bounds in connection with singular value decomposition. BIT 12 (1972), 99–111. DOI: 10.1007/BF01932678](https://doi.org/10.1007/BF01932678) — Separates individual singular-vector claims from separated-subspace claims.
- [GNU MPFR project, MPFR 4.2 manual, floating-point numbers and rounding](https://www.mpfr.org/mpfr-current/mpfr.html) — Correct-rounding and exponent-range terminology for dyadic input audits.

These sources establish external mathematical context. The selected dimensions, dyadic values, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated above.

## Project provenance

- Runnable case: [hadamard_geometric.m](../../../../examples/tiered/svd-tier-a/hadamard_geometric.m).
- Case manifest: [SVT cases.json](../../../../docs/codex/svt/cases.json).
- Certificate scope: [SVT VERIFICATION.md](../../../../docs/codex/svt/VERIFICATION.md) and [SVT SOURCES.md](../../../../docs/codex/svt/SOURCES.md).
- This page explains the model; the family runner and milestone logs remain the measurement authority.
