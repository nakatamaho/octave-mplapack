# NRO bounded-integer companion-like control (Tier A6)

## Quick idea

A6-NRO-COMPANION is a Tier A control. This is a nonsymmetric bounded-integer construction whose singular spectrum is not supplied by a simple diagonal formula. It is one fixed matrix with one matching runnable example. The tier identifies the verification question, not a claim that public dense svd implements any cited structured algorithm.

## Mathematical problem

Smoke: n=8, nu=16. Demo: n=16, nu=256. The first row is generated from an alternating sign sequence k_i.

$$
k_i=(-1)^{i-1}\quad (k_n=1),
\qquad a_1=k_1,\quad a_i=k_i-nu k_{i-1}.
$$
The matrix has first row a, subdiagonal ones, and diagonal -nu as specified by the companion-like construction. Horner recurrence preserves the target k sequence and det(A)=(-1)^(n-1).

## Why this problem is numerically difficult

This is a nonsymmetric bounded-integer construction whose singular spectrum is not supplied by a simple diagonal formula. The large parameter nu creates a scale-separated dense eigen/singular problem while the exact recurrence supplies an independent construction invariant. It is a control against treating a companion-like matrix as if its eigenvalues were its singular values.

The exact model, any analytic or structural reference, and measured SVD output are kept separate. A convenient identity is a check on the named matrix, never a silent replacement for it.

## What the Octave example computes

The matching [nro_companion.m](../../../../examples/tiered/svd-tier-a/nro_companion.m) selects only A6-NRO-COMPANION from the fixed manifest. The matching nro_companion.m constructs the integer matrix in MP, runs public svd, and checks the Horner/state recurrence, determinant sign, reconstruction, and factor orthogonality. It compares the measured spectrum with an independent wider MP run; no known singular values are substituted. The runner records shape, parameters, source/model identity, operation precision, and any native control while retaining MPFR/MPC arithmetic.

## Construction and exactness

All first-row coefficients and the subdiagonal/diagonal pattern are checked by exact integer arithmetic under the declared guard. The determinant and recurrence are independent of SVD. A high-precision reference is a numerical comparator, not a proof of a hidden closed-form singular spectrum.

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

The source is exact integer for the selected nu. Arithmetic precision controls construction, SVD, and reference; mathematical conditioning is driven by nu and the companion-like nonnormal pattern. More bits reduce arithmetic error but do not make singular values equal to eigenvalues.

Input/source precision identifies the stored matrix and deliberate once-rounded variants. Arithmetic/work precision is the MPFR/MPC precision used by construction, SVD, and references. Mathematical conditioning belongs to the model and can remain severe at arbitrary precision. Raising mpbits reduces arithmetic error but does not restore a tail lost in the input or make a repeated basis unique. Ambient-precision and restoration tests protect operation ownership.

## Reading the output

Read the complete singular spectrum, r_svd, and factor residuals. The determinant is a rank/invariant check, not a product-based accuracy certificate in finite precision. Because values may be clustered or widely scaled, use value-wise metrics appropriate to magnitude and avoid individual-vector claims without a gap.

A PASS line is scoped to this case and profile. Compare rows only when parameters and model identity match. If a rank, subspace, or exactness field is not claimed, do not infer it from a visually stable display.

## Common mistakes

Do not use eig values as singular values, build coefficients through native overflow-prone arithmetic, infer full accuracy from det, or claim a published companion experiment was reproduced.

For diagnosis, verify case ID and shape, then model hash/input precision, then reconstruction and orthogonality, then the case-specific value or subspace metric. Do not change parameters after a failure and report the changed input as this case.

## Parameter boundary and comparison protocol

The parameter in this page is part of the case identity, not a tuning knob. Record n, the dyadic exponents, the representation (raw, mixed, tall, wide, complex, repeated, or rank-deficient), and the source/model hash before comparing outputs. A reference generated from a neighboring case can be mathematically related and still be the wrong target. This is especially important for a close pair, where replacing a nonzero gap by zero changes the forward problem, and for a rank case, where replacing an exact zero by a tiny positive number changes the rank.

Use a bijective matching for values and a phase-aware or subspace-aware comparison for factors. The matching is performed in MP arithmetic and is a diagnostic, not a way to hide an unmatched value. If the output shape is rectangular, state which economy/full convention is being used. If a factor is not identifiable because of a repeated singular value or a null space, report the projector or range and do not manufacture an individual-vector error. These rules make the short runner reproducible and keep its PASS result scoped to the named model.
## Scope of the claim

This page explains one fixed SVD model and the precise object that the runner measures. Changing a dimension, dyadic exponent, scale, phase, gap, or zero entry changes the source matrix and requires a new case identity. That is especially important for repeated and rank-deficient examples: a zero gap is not a tiny gap, and an exact zero is not merely a small positive singular value.

The analytic spectrum or projector is an independent model check. It is not inserted into the measured factorization, and the public dense SVD is not silently replaced by a structured bidiagonal or totally-nonnegative algorithm. Reconstruction, unitarity, value-wise forward error, and subspace comparisons answer different questions. The runner records all of them with the input and arithmetic precision roles. Binary64 is permitted only at an explicitly declared presentation boundary; it is never an unreported numerical fallback.
## References

- [Tetsuo Nishi, Siegfried M. Rump, and Shin'ichi Oishi, On the generation of very ill-conditioned integer matrices. Nonlinear Theory and Its Applications, IEICE 2(2) (2011), 226–245. DOI: 10.1587/nolta.2.226](https://doi.org/10.1587/nolta.2.226) — Bounded-integer companion-like construction context.
- [GNU MPFR project, MPFR 4.2 manual, floating-point numbers and rounding](https://www.mpfr.org/mpfr-current/mpfr.html) — Correct-rounding and exponent-range terminology for dyadic input audits.

These sources establish external mathematical context. The selected dimensions, dyadic values, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated above.

## Project provenance

- Runnable case: [nro_companion.m](../../../../examples/tiered/svd-tier-a/nro_companion.m).
- Case manifest: [SVT cases.json](../../../../docs/codex/svt/cases.json).
- Certificate scope: [SVT VERIFICATION.md](../../../../docs/codex/svt/VERIFICATION.md) and [SVT SOURCES.md](../../../../docs/codex/svt/SOURCES.md).
- This page explains the model; the family runner and milestone logs remain the measurement authority.
