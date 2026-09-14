# Hadamard-mixed repeated singular group (Tier A5)

## Quick idea

A5-REPEAT is a Tier A control. A repeated singular value makes individual left and right vectors nonunique. It is one fixed matrix with one matching runnable example. The tier identifies the verification question, not a claim that public dense svd implements any cited structured algorithm.

## Mathematical problem

Smoke and demo: $n=8$. The close-pair $\delta$ is exactly zero, so
$d=[4,2,1,1,1/2,1/4,1/8,1/16]$.

```math
A=\frac{1}{n}H\mathrm{diag}(4,2,1,1,1/2,1/4,1/8,1/16)G^{\mathsf T}.
```

The singular value 1 has multiplicity two and its left/right model subspaces are the corresponding H/G column spans.

## Concrete smoke matrix

<!-- smoke-matrix: A5-REPEAT -->

```math
A_{\mathrm{smoke}} = 2^{-7} \begin{bmatrix}
29 & 143 & 37 & 73 & 35 & 113 & 27 & 55 \\
55 & 37 & 143 & 35 & 73 & 27 & 113 & 29 \\
27 & 73 & 35 & 143 & 37 & 55 & 29 & 113 \\
113 & 35 & 73 & 37 & 143 & 29 & 55 & 27 \\
35 & 113 & 27 & 55 & 29 & 143 & 37 & 73 \\
73 & 27 & 113 & 29 & 55 & 37 & 143 & 35 \\
37 & 55 & 29 & 113 & 27 & 73 & 35 & 143 \\
143 & 29 & 55 & 27 & 113 & 35 & 73 & 37
\end{bmatrix}.
```

This is the full concrete smoke fixture for `A5-REPEAT`. The matching [`hadamard_repeat.m`](../../../../examples/tiered/svd-tier-a/hadamard_repeat.m) selects the same manifest case and hands this input to the public `svd` path; the displayed matrix is not solver output.

The entries are exact integers or dyadic rationals. If a common factor such as `2^{-q}` appears before the bracket, it multiplies every bracket entry and is part of the exact matrix, not a decimal approximation. Fixed-generation cases retain the declared generator precision in their model object; any separate exact widening and solver/work precision remain distinct recorded quantities.

The smoke configuration is the small, inspectable documentation and CI instance. Its matching demo is a separate manifest row that may change the dimension, parameter, or profile; it is not substituted for this input when interpreting the measured result. This separation keeps the source matrix, source precision, and solver output auditable.

## Why this problem is numerically difficult

A repeated singular value makes individual left and right vectors nonunique. This dense construction is designed so the target is a projector or subspace, not a particular factor basis. It is a semantic test: a checker that matches columns one by one can report failure for two mathematically correct SVDs.

The exact model, any analytic or structural reference, and measured SVD output are kept separate. A convenient identity is a check on the named matrix, never a silent replacement for it.

## What the Octave example computes

The matching [hadamard_repeat.m](../../../../examples/tiered/svd-tier-a/hadamard_repeat.m) selects only A5-REPEAT from the fixed manifest. The matching hadamard_repeat.m runs public svd and compares the repeated value group through left/right projectors, while checking the complete spectrum and reconstruction. It allows arbitrary orthogonal/unitary changes within the group. The exact diagonal source remains separate from measured factors. The runner records shape, parameters, source/model identity, operation precision, and any native control while retaining MPFR/MPC arithmetic.

## Construction and exactness

The zero gap is an exact model parameter, not a rounded small delta. Hadamard orthogonality proves the singular spectrum and gives exact projectors under the declared guard. The group multiplicity is known algebraically, not inferred from a numerical disk.

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

Input/source precision records an exact repeated group. Arithmetic precision controls dense products and SVD. Mathematical nonuniqueness remains at infinite precision; more bits reduce residuals but cannot choose one basis among infinitely many.

Input/source precision identifies the stored matrix and deliberate once-rounded variants. Arithmetic/work precision is the MPFR/MPC precision used by construction, SVD, and references. Mathematical conditioning belongs to the model and can remain severe at arbitrary precision. Raising mpbits reduces arithmetic error but does not restore a tail lost in the input or make a repeated basis unique. Ambient-precision and restoration tests protect operation ownership.

## Reading the output

Expect two singular values equal to one within arithmetic error and arbitrary bases for their subspaces. Read projector/angle residuals, $r_{\mathrm{svd}}$, $r_U$, and $r_V$. Individual phase/sign or column-order comparisons are intentionally not used.

A PASS line is scoped to this case and profile. Compare rows only when parameters and model identity match. If a rank, subspace, or exactness field is not claimed, do not infer it from a visually stable display.

## Common mistakes

Do not call a rotated basis wrong, infer distinct vectors from two equal values, or use a simple-gap factor bound.

For diagnosis, verify case ID and shape, then model hash/input precision, then reconstruction and orthogonality, then the case-specific value or subspace metric. Do not change parameters after a failure and report the changed input as this case.

## Parameter boundary and comparison protocol

The parameter in this page is part of the case identity, not a tuning knob. Record n, the dyadic exponents, the representation (raw, mixed, tall, wide, complex, repeated, or rank-deficient), and the source/model hash before comparing outputs. A reference generated from a neighboring case can be mathematically related and still be the wrong target. This is especially important for a close pair, where replacing a nonzero gap by zero changes the forward problem, and for a rank case, where replacing an exact zero by a tiny positive number changes the rank.

Use a bijective matching for values and a phase-aware or subspace-aware comparison for factors. The matching is performed in MP arithmetic and is a diagnostic, not a way to hide an unmatched value. If the output shape is rectangular, state which economy/full convention is being used. If a factor is not identifiable because of a repeated singular value or a null space, report the projector or range and do not manufacture an individual-vector error. These rules make the short runner reproducible and keep its PASS result scoped to the named model.
## Scope of the claim

This page explains one fixed SVD model and the precise object that the runner measures. Changing a dimension, dyadic exponent, scale, phase, gap, or zero entry changes the source matrix and requires a new case identity. That is especially important for repeated and rank-deficient examples: a zero gap is not a tiny gap, and an exact zero is not merely a small positive singular value.

The analytic spectrum or projector is an independent model check. It is not inserted into the measured factorization, and the public dense SVD is not silently replaced by a structured bidiagonal or totally-nonnegative algorithm. Reconstruction, unitarity, value-wise forward error, and subspace comparisons answer different questions. The runner records all of them with the input and arithmetic precision roles. Binary64 is permitted only at an explicitly declared presentation boundary; it is never an unreported numerical fallback.
## References

- [Per-Åke Wedin, Perturbation bounds in connection with singular value decomposition. BIT 12 (1972), 99–111. DOI: 10.1007/BF01932678](https://doi.org/10.1007/BF01932678) — Separates individual singular-vector claims from separated-subspace claims.
- [Plamen Koev, Accurate Eigenvalues and SVDs of Totally Nonnegative Matrices. SIAM Journal on Matrix Analysis and Applications 27(1) (2005), 1–23. DOI: 10.1137/S0895479803438225](https://doi.org/10.1137/S0895479803438225) — The structured-factor accuracy context; this page does not claim a dense SVD implementation of that algorithm.

These sources establish external mathematical context. The selected dimensions, dyadic values, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated above.

## Project provenance

- Runnable case: [hadamard_repeat.m](../../../../examples/tiered/svd-tier-a/hadamard_repeat.m).
- Case manifest: [SVT cases.json](../../../../docs/codex/svt/cases.json).
- Certificate scope: [SVT VERIFICATION.md](../../../../docs/codex/svt/VERIFICATION.md) and [SVT SOURCES.md](../../../../docs/codex/svt/SOURCES.md).
- This page explains the model; the family runner and milestone logs remain the measurement authority.
