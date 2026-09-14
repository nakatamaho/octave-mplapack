# Two-sided Hadamard-mixed bidiagonal (Tier A3)

## Quick idea

A3-BDI-MIXED is a Tier A control. The mixed matrix has the same singular spectrum as the raw bidiagonal but dense signed entries and a different reduction path. It is one fixed matrix with one matching runnable example. The tier identifies the verification question, not a claim that public dense svd implements any cited structured algorithm.

## Mathematical problem

Smoke: $n=8$, $a=4$. Demo: $n=16$, $a=8$. $A=HBG^{\mathsf T}/n$, with
$G$ a cyclic row-shift of $H$.

```math
A=\frac{1}{n}HBG^{\mathsf T},
\qquad HH^{\mathsf T}=GG^{\mathsf T}=nI.
```

The two-sided orthogonal equivalence preserves singular values exactly, but it is not an eigenvalue similarity.

## Concrete smoke matrix

<!-- smoke-matrix: A3-BDI-MIXED -->

```math
A_{\mathrm{smoke}} = 2^{-31} \begin{bmatrix}
108558727 & 429496729 & 126322567 & 409442407 & 108627577 & 429418087 & 126253177 & 409364377 \\
158824073 & 378967703 & 143165577 & 392730473 & 158763383 & 379021673 & 143226743 & 392784023 \\
109541753 & 426154343 & 125339513 & 412653721 & 109479559 & 426206873 & 125401223 & 412706663 \\
159938167 & 376018537 & 142051447 & 395810711 & 160008585 & 375941527 & 141981577 & 395733097 \\
108562041 & 429483623 & 126318713 & 409429913 & 108624263 & 429431193 & 126257031 & 409376871 \\
158828919 & 378956137 & 143161207 & 392718487 & 158758537 & 379033239 & 143231113 & 392796009 \\
109545095 & 426141337 & 125335687 & 412641127 & 109476217 & 426219879 & 125405049 & 412719257 \\
159943049 & 376007063 & 142047113 & 395798633 & 160003703 & 375953001 & 141985911 & 395745175
\end{bmatrix}.
```

This is the full concrete smoke fixture for `A3-BDI-MIXED`. The matching [`bidiag_mixed.m`](../../../../examples/tiered/svd-tier-a/bidiag_mixed.m) selects the same manifest case and hands this input to the public `svd` path; the displayed matrix is not solver output.

The entries are exact integers or dyadic rationals. If a common factor such as `2^{-q}` appears before the bracket, it multiplies every bracket entry and is part of the exact matrix, not a decimal approximation. Fixed-generation cases retain the declared generator precision in their model object; any separate exact widening and solver/work precision remain distinct recorded quantities.

The smoke configuration is the small, inspectable documentation and CI instance. Its matching demo is a separate manifest row that may change the dimension, parameter, or profile; it is not substituted for this input when interpreting the measured result. This separation keeps the source matrix, source precision, and solver output auditable.

## Why this problem is numerically difficult

The mixed matrix has the same singular spectrum as the raw bidiagonal but dense signed entries and a different reduction path. It tests whether the public SVD handles a dense representation without confusing orthogonal equivalence with similarity. The product is a finite sum of dyadic terms and must be constructed at a declared precision.

The exact model, any analytic or structural reference, and measured SVD output are kept separate. A convenient identity is a check on the named matrix, never a silent replacement for it.

## What the Octave example computes

The matching [bidiag_mixed.m](../../../../examples/tiered/svd-tier-a/bidiag_mixed.m) selects only A3-BDI-MIXED from the fixed manifest. The matching bidiag_mixed.m constructs raw B and dense A separately, verifies the Hadamard identities, runs svd(A), and compares its spectrum with raw B and an independent MP reference. It reports the mixed input hash and keeps the raw run as a control. No measured output is replaced by the raw singular values. The runner records shape, parameters, source/model identity, operation precision, and any native control while retaining MPFR/MPC arithmetic.

## Construction and exactness

The Hadamard matrices are integer and the common denominator bound covers both product stages and division by n. Exact equality of spectra is a model theorem; measured agreement is checked separately. A binary64 plotting or display conversion is not part of construction.

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

The raw and mixed source models are exact dyadic when the guard is met. Arithmetic precision controls the mixed products and SVD. Mathematical singular-value conditioning is inherited from B, while representation affects backward errors and factor geometry. More bits cannot repair an incorrectly rounded mixed input.

Input/source precision identifies the stored matrix and deliberate once-rounded variants. Arithmetic/work precision is the MPFR/MPC precision used by construction, SVD, and references. Mathematical conditioning belongs to the model and can remain severe at arbitrary precision. Raising mpbits reduces arithmetic error but does not restore a tail lost in the input or make a repeated basis unique. Ambient-precision and restoration tests protect operation ownership.

## Reading the output

Read the spectrum identity, $r_{\mathrm{svd}}$, and both factor orthogonality residuals. Dense mixing can change factor vectors even when singular values agree. For repeated values compare left/right subspaces, not $H$ or $G$ columns individually.

A PASS line is scoped to this case and profile. Compare rows only when parameters and model identity match. If a rank, subspace, or exactness field is not claimed, do not infer it from a visually stable display.

## Common mistakes

Do not use $HBG^{\mathsf T}$ as an eigenvalue similarity, solve the raw $B$ in place of $A$, compare factor columns without phases, or claim a dense HRA algorithm.

For diagnosis, verify case ID and shape, then model hash/input precision, then reconstruction and orthogonality, then the case-specific value or subspace metric. Do not change parameters after a failure and report the changed input as this case.

## Parameter boundary and comparison protocol

The parameter in this page is part of the case identity, not a tuning knob. Record n, the dyadic exponents, the representation (raw, mixed, tall, wide, complex, repeated, or rank-deficient), and the source/model hash before comparing outputs. A reference generated from a neighboring case can be mathematically related and still be the wrong target. This is especially important for a close pair, where replacing a nonzero gap by zero changes the forward problem, and for a rank case, where replacing an exact zero by a tiny positive number changes the rank.

Use a bijective matching for values and a phase-aware or subspace-aware comparison for factors. The matching is performed in MP arithmetic and is a diagnostic, not a way to hide an unmatched value. If the output shape is rectangular, state which economy/full convention is being used. If a factor is not identifiable because of a repeated singular value or a null space, report the projector or range and do not manufacture an individual-vector error. These rules make the short runner reproducible and keep its PASS result scoped to the named model.
## Scope of the claim

This page explains one fixed SVD model and the precise object that the runner measures. Changing a dimension, dyadic exponent, scale, phase, gap, or zero entry changes the source matrix and requires a new case identity. That is especially important for repeated and rank-deficient examples: a zero gap is not a tiny gap, and an exact zero is not merely a small positive singular value.

The analytic spectrum or projector is an independent model check. It is not inserted into the measured factorization, and the public dense SVD is not silently replaced by a structured bidiagonal or totally-nonnegative algorithm. Reconstruction, unitarity, value-wise forward error, and subspace comparisons answer different questions. The runner records all of them with the input and arithmetic precision roles. Binary64 is permitted only at an explicitly declared presentation boundary; it is never an unreported numerical fallback.
## References

- [LAPACK Working Group, “DLASQ1: Compute the singular values of a real
  bidiagonal matrix,” LAPACK online documentation (current).](https://www.netlib.org/lapack/explore-html/d5/dce/group__lasq1_ga5a8c1474ef61ff7c59c17412ae456ca6.html)
  — The official bidiagonal singular-value reference; this case measures the
  public dense SVD interface and does not claim to call DLASQ1.
- [GNU MPFR project, MPFR 4.2 manual, floating-point numbers and rounding](https://www.mpfr.org/mpfr-current/mpfr.html) — Correct-rounding and exponent-range terminology for dyadic input audits.

These sources establish external mathematical context. The selected dimensions, dyadic values, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated above.

## Project provenance

- Runnable case: [bidiag_mixed.m](../../../../examples/tiered/svd-tier-a/bidiag_mixed.m).
- Case manifest: [SVT cases.json](../../../../docs/codex/svt/cases.json).
- Certificate scope: [SVT VERIFICATION.md](../../../../docs/codex/svt/VERIFICATION.md) and [SVT SOURCES.md](../../../../docs/codex/svt/SOURCES.md).
- This page explains the model; the family runner and milestone logs remain the measurement authority.
