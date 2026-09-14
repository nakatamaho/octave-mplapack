# Tall Läuchli matrix (Tier A4)

## Quick idea

A4-LAU-TALL is a Tier A control. The small singular group is controlled by μ while the normal-equation matrix contains μ^2, which is much easier to lose. It is one fixed matrix with one matching runnable example. The tier identifies the verification question, not a claim that public dense svd implements any cited structured algorithm.

## Mathematical problem

Smoke: $n=4$, $b=20$, $\mu=2^{-20}$. Demo: $n=8$, $b=100$,
$\mu=2^{-100}$. $T$ has shape $(n+1)$-by-$n$.

```math
T=\begin{bmatrix}\mathbf{1}^{\mathsf T}\\ \mu I_n\end{bmatrix},
\qquad T^{\mathsf T}T=\mathbf{1}\mathbf{1}^{\mathsf T}+\mu^2 I_n.
```

The singular values are $\sqrt{n+\mu^2}$, followed by $n-1$ copies of $\mu$.

## Concrete smoke matrix

<!-- smoke-matrix: A4-LAU-TALL -->

```math
A_{\mathrm{smoke}} = \begin{bmatrix}
1 & 1 & 1 & 1 \\
2^{-20} & 0 & 0 & 0 \\
0 & 2^{-20} & 0 & 0 \\
0 & 0 & 2^{-20} & 0 \\
0 & 0 & 0 & 2^{-20}
\end{bmatrix}.
```

This is the full concrete smoke fixture for `A4-LAU-TALL`. The matching [`lauchli_tall.m`](../../../../examples/tiered/svd-tier-a/lauchli_tall.m) selects the same manifest case and hands this input to the public `svd` path; the displayed matrix is not solver output.

The entries are exact integers or dyadic rationals. If a common factor such as `2^{-q}` appears before the bracket, it multiplies every bracket entry and is part of the exact matrix, not a decimal approximation. Fixed-generation cases retain the declared generator precision in their model object; any separate exact widening and solver/work precision remain distinct recorded quantities.

The smoke configuration is the small, inspectable documentation and CI instance. Its matching demo is a separate manifest row that may change the dimension, parameter, or profile; it is not substituted for this input when interpreting the measured result. This separation keeps the source matrix, source precision, and solver output auditable.

## Why this problem is numerically difficult

The small singular group is controlled by μ while the normal-equation matrix contains μ^2, which is much easier to lose. This is a rank-sensitive example with a repeated small singular value; individual small singular vectors are not identifiable. The exact Gram identity is a control, not a replacement for measuring T with svd.

The exact model, any analytic or structural reference, and measured SVD output are kept separate. A convenient identity is a check on the named matrix, never a silent replacement for it.

## What the Octave example computes

The matching [lauchli_tall.m](../../../../examples/tiered/svd-tier-a/lauchli_tall.m) selects only A4-LAU-TALL from the fixed manifest. The matching lauchli_tall.m builds $T$ in MP, runs public svd, and compares the values with the analytic spectrum. It checks the repeated right subspace $I-\mathbf{1}\mathbf{1}^{\mathsf T}/n$, the left subspace, reconstruction, and factor orthogonality. A native $T^{\mathsf T}T$ calculation is logged only as a negative control. The runner records shape, parameters, source/model identity, operation precision, and any native control while retaining MPFR/MPC arithmetic.

## Construction and exactness

The row of ones and dyadic μ are exact within the selected input guard. The Gram identity is checked entrywise, and the repeated projector is generated exactly. The null direction in a full SVD is not counted as an additional economy singular value.

Exactness is proved from the declared integer/dyadic construction and guard. Two agreeing MP computations are useful corroboration but are not an exactness proof. Binary64 conversion is allowed only at an explicitly labelled presentation boundary.

## Diagnostics

For $A\in\mathbb{C}^{m\times n}$, use

```math
A=U\Sigma V^{\mathsf H},\qquad
r_{\mathrm{svd}}=\frac{\lVert A-U\Sigma V^{\mathsf H}\rVert_F}{\lVert A\rVert_F},
\qquad
r_U=\lVert U^{\mathsf H}U-I\rVert_F,\quad
r_V=\lVert V^{\mathsf H}V-I\rVert_F.
```

For a repeated or rank cluster compare the associated left/right projectors or ranges; individual factors are not canonical.

Also inspect the value-wise forward bottleneck, rank/cluster metric, and any model-specific identity. Keep residuals as MP values until display. A small reconstruction residual alone does not certify each singular value digit.

## Backward error versus forward error

The reconstruction residual is a backward-error style measure for the factorization equation: the returned factors nearly explain the stored A. Forward singular-value error compares values with the mathematical spectrum of that exact stored model and depends on gaps, scales, and conditioning. For repeated values the forward object is a subspace; for rank-deficient data exact model rank is separate from thresholding measured values.

## What arbitrary precision changes

Input precision controls μ itself; arithmetic precision controls T, svd, and analytic sqrt(n+μ^2). Mathematical sensitivity is concentrated in the small repeated group and in the squaring of μ under normal equations. More bits preserve μ but do not select a unique small basis.

Input/source precision identifies the stored matrix and deliberate once-rounded variants. Arithmetic/work precision is the MPFR/MPC precision used by construction, SVD, and references. Mathematical conditioning belongs to the model and can remain severe at arbitrary precision. Raising mpbits reduces arithmetic error but does not restore a tail lost in the input or make a repeated basis unique. Ambient-precision and restoration tests protect operation ownership.

## Reading the output

Expect one large value and a repeated μ group. Read the repeated-group projector rather than individual columns, and compare σ_min to μ with an absolute metric. A reconstruction pass does not establish that a native normal-equation path retained μ.

A PASS line is scoped to this case and profile. Compare rows only when parameters and model identity match. If a rank, subspace, or exactness field is not claimed, do not infer it from a visually stable display.

## Common mistakes

Do not compute the main answer from $T^{\mathsf T}T$, take $\sqrt{\lvert\mathrm{eig}(\cdot)\rvert}$ as an oracle, compare repeated columns individually, or claim the full-SVD null direction is a listed singular value.

For diagnosis, verify case ID and shape, then model hash/input precision, then reconstruction and orthogonality, then the case-specific value or subspace metric. Do not change parameters after a failure and report the changed input as this case.

## Parameter boundary and comparison protocol

The parameter in this page is part of the case identity, not a tuning knob. Record n, the dyadic exponents, the representation (raw, mixed, tall, wide, complex, repeated, or rank-deficient), and the source/model hash before comparing outputs. A reference generated from a neighboring case can be mathematically related and still be the wrong target. This is especially important for a close pair, where replacing a nonzero gap by zero changes the forward problem, and for a rank case, where replacing an exact zero by a tiny positive number changes the rank.

Use a bijective matching for values and a phase-aware or subspace-aware comparison for factors. The matching is performed in MP arithmetic and is a diagnostic, not a way to hide an unmatched value. If the output shape is rectangular, state which economy/full convention is being used. If a factor is not identifiable because of a repeated singular value or a null space, report the projector or range and do not manufacture an individual-vector error. These rules make the short runner reproducible and keep its PASS result scoped to the named model.
## Scope of the claim

This page explains one fixed SVD model and the precise object that the runner measures. Changing a dimension, dyadic exponent, scale, phase, gap, or zero entry changes the source matrix and requires a new case identity. That is especially important for repeated and rank-deficient examples: a zero gap is not a tiny gap, and an exact zero is not merely a small positive singular value.

The analytic spectrum or projector is an independent model check. It is not inserted into the measured factorization, and the public dense SVD is not silently replaced by a structured bidiagonal or totally-nonnegative algorithm. Reconstruction, unitarity, value-wise forward error, and subspace comparisons answer different questions. The runner records all of them with the input and arithmetic precision roles. Binary64 is permitted only at an explicitly declared presentation boundary; it is never an unreported numerical fallback.
## References

- [Peter Läuchli, Jordan-Elimination und Ausgleichung nach kleinsten Quadraten. Numerische Mathematik 3 (1961), 226–240. DOI: 10.1007/BF01386022](https://doi.org/10.1007/BF01386022) — Historical source for the Läuchli matrix convention; the exact spectrum here follows directly from its Gram matrix.
- [Per-Åke Wedin, Perturbation bounds in connection with singular value decomposition. BIT 12 (1972), 99–111. DOI: 10.1007/BF01932678](https://doi.org/10.1007/BF01932678) — Separates individual singular-vector claims from separated-subspace claims.
- [GNU MPFR project, MPFR 4.2 manual, floating-point numbers and rounding](https://www.mpfr.org/mpfr-current/mpfr.html) — Correct-rounding and exponent-range terminology for dyadic input audits.

These sources establish external mathematical context. The selected dimensions, dyadic values, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated above.

## Project provenance

- Runnable case: [lauchli_tall.m](../../../../examples/tiered/svd-tier-a/lauchli_tall.m).
- Case manifest: [SVT cases.json](../../../../docs/codex/svt/cases.json).
- Certificate scope: [SVT VERIFICATION.md](../../../../docs/codex/svt/VERIFICATION.md) and [SVT SOURCES.md](../../../../docs/codex/svt/SOURCES.md).
- This page explains the model; the family runner and milestone logs remain the measurement authority.
