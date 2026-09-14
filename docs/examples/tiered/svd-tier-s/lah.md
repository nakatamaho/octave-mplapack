# Unsigned Lah matrix (Tier S3)

## Quick idea

S3-LAH isolates Lah entries grow rapidly down the triangle, producing a full-rank matrix whose smallest singular values are sensitive to small relative entry errors. It is a one-case, deterministic Tier S example: the matrix is small enough to inspect, but the singular spectrum or factors expose a failure mode that a generic smoke matrix would hide. Tier S describes the requested mathematical depth; it does not claim that the public dense svd call implements the cited structured algorithm.

## Mathematical problem

Smoke: $n=8$. Demo: $n=20$. The matrix is lower triangular with exact
integer entries and unit diagonal.

```math
L_{ij}=\binom{i-1}{j-1}\frac{i!}{j!}\quad (j\le i),
\qquad L_{ij}=0\quad (j>i).
```

Equivalently L(i,j)=L(i-1,j-1)+(i+j-1)L(i-1,j), with out-of-range entries zero. The first rows are [1], [2 1], [6 6 1], [24 36 12 1].

## Concrete smoke matrix

<!-- smoke-matrix: S3-LAH -->

```math
A_{\mathrm{smoke}} = \begin{bmatrix}
1 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
2 & 1 & 0 & 0 & 0 & 0 & 0 & 0 \\
6 & 6 & 1 & 0 & 0 & 0 & 0 & 0 \\
24 & 36 & 12 & 1 & 0 & 0 & 0 & 0 \\
120 & 240 & 120 & 20 & 1 & 0 & 0 & 0 \\
720 & 1800 & 1200 & 300 & 30 & 1 & 0 & 0 \\
5040 & 15120 & 12600 & 4200 & 630 & 42 & 1 & 0 \\
40320 & 141120 & 141120 & 58800 & 11760 & 1176 & 56 & 1
\end{bmatrix}.
```

This is the full concrete smoke fixture for `S3-LAH`. The matching [`lah.m`](../../../../examples/tiered/svd-tier-s/lah.m) selects the same manifest case and hands this input to the public `svd` path; the displayed matrix is not solver output.

The entries are exact integers or dyadic rationals. If a common factor such as `2^{-q}` appears before the bracket, it multiplies every bracket entry and is part of the exact matrix, not a decimal approximation. Fixed-generation cases retain the declared generator precision in their model object; any separate exact widening and solver/work precision remain distinct recorded quantities.

The smoke configuration is the small, inspectable documentation and CI instance. Its matching demo is a separate manifest row that may change the dimension, parameter, or profile; it is not substituted for this input when interpreting the measured result. This separation keeps the source matrix, source precision, and solver output auditable.

## Why this problem is numerically difficult

Lah entries grow rapidly down the triangle, producing a full-rank matrix whose smallest singular values are sensitive to small relative entry errors. The unit diagonal proves nonsingularity but says little about the conditioning of the singular vectors or the relative accuracy of σ_min. A recurrence and closed form give two independent construction checks.

The exact model, any analytic/reference construction, and measured SVD output are separate records. A convenient formula is a reference or invariant check; it is never silently substituted for the matrix sent to the public solver.

## What the Octave example computes

The matching [lah.m](../../../../examples/tiered/svd-tier-s/lah.m) selects only S3-LAH from the fixed manifest. The matching lah.m generates L by the integer recurrence, runs public svd, and compares the measured values with a wider MP reference. It checks the first rows, unit diagonal, lower-triangular pattern, reconstruction, and unitarity. It does not compute factorials through native binary64 and does not replace the SVD with a structured algorithm. The runner records dimensions, case parameters, input/model identity, work/reference precision, measured rows, and any native control.

## Construction and exactness

The recurrence has a declared conservative budget based on the largest multiplier 2i and a maximum-entry bound. The closed form is checked for small indices using exact MP arithmetic. The source matrix is frozen before any SVD call; a wider reconstruction is evidence about the solver, not about the generator alone.

The source audit distinguishes exactness of the constructed matrix from agreement between two floating computations. All arithmetic on the model and measured path remains MPFR/MPC; conversion to binary64 is limited to explicitly labelled presentation controls.

## Diagnostics

For $A\in\mathbb{C}^{m\times n}$, $U$, $\Sigma$, and $V$, use

```math
A=U\Sigma V^{\mathsf H},\qquad
r_{\mathrm{svd}}=\frac{\lVert A-U\Sigma V^{\mathsf H}\rVert_F}{\lVert A\rVert_F},
\qquad
r_U=\lVert U^{\mathsf H}U-I\rVert_F,\quad
r_V=\lVert V^{\mathsf H}V-I\rVert_F.
```

For repeated singular values compare the associated left/right subspaces, not individual columns.

Also inspect the value-wise forward bottleneck against the exact or analytic reference, the rank/cluster diagnostic when applicable, and any inverse or projector check. Keep the residuals as MP values until display. A small reconstruction residual does not certify every singular value digit.

## Backward error versus forward error

The reconstruction residual is a backward-error style measure for the factorization equation: the returned factors nearly explain A. Forward singular-value error compares each returned value with the mathematical value of the stored model and depends on gaps, scaling, and conditioning. For a repeated group, the stable forward object is a subspace/projector. For rank-deficient data, an exact model rank proof is distinct from thresholding tiny measured values.

## What arbitrary precision changes

The source is exact integer recurrence data. Arithmetic precision controls entry generation, SVD, and references; mathematical conditioning is driven by the combinatorial growth. More bits improve the measured factorization but cannot make a poorly conditioned singular value well conditioned.

Input/source precision identifies the stored matrix and any deliberate once-rounded model. Arithmetic/work precision is the MPFR/MPC precision used by the constructor, SVD, and references. Mathematical conditioning belongs to the model and can remain severe at arbitrary precision. Raising mpbits reduces arithmetic error but does not restore a singular-value tail lost in the input or make repeated factors unique. Ambient-precision and restoration tests ensure operation precision is owned by the stored operands.

## Reading the output

Inspect $\sigma_i$ relative errors across the full range, not only the largest value. $r_{\mathrm{svd}}$ can be small while $\sigma_{\min}$ loses relative digits. Factor columns may change sign or phase and should be matched only under a separation condition.

A PASS line is scoped to the named case and profile. Compare only rows with identical parameters and model identity. If a cluster, rank, or exactness field is not claimed, do not infer it from a stable display.

## Common mistakes

Do not infer spectral accuracy from unit diagonal or determinant, use binary64 factorials, compare factor columns without phase matching, or claim the reference is a published numerical table.

For diagnosis, first verify case ID and shape, then model hash and input precision, then reconstruction/orthogonality, then the appropriate value or subspace metric. Do not alter parameters after seeing a failure and report the changed matrix as the original case.

## Scope of the claim

This page explains one fixed SVD model and the precise object that the runner measures. Changing a dimension, dyadic exponent, scale, phase, gap, or zero entry changes the source matrix and requires a new case identity. That is especially important for repeated and rank-deficient examples: a zero gap is not a tiny gap, and an exact zero is not merely a small positive singular value.

The analytic spectrum or projector is an independent model check. It is not inserted into the measured factorization, and the public dense SVD is not silently replaced by a structured bidiagonal or totally-nonnegative algorithm. Reconstruction, unitarity, value-wise forward error, and subspace comparisons answer different questions. The runner records all of them with the input and arithmetic precision roles. Binary64 is permitted only at an explicitly declared presentation boundary; it is never an unreported numerical fallback.
## References

- [Jorge Delgado, Héctor Orera, and Juan Manuel Peña, Accurate computations with Laguerre matrices. Numerical Linear Algebra with Applications 26(1) (2019), e2217. DOI: 10.1002/nla.2217](https://doi.org/10.1002/nla.2217) — Lah-factor data and accurate singular-value context.
- [GNU MPFR project, MPFR 4.2 manual, floating-point numbers and rounding](https://www.mpfr.org/mpfr-current/mpfr.html) — Correct-rounding and exponent-range terminology used when discussing exact dyadic inputs.

The cited works provide external mathematical context. The dimensions, powers of two, acceptance thresholds, and executable implementation are suite-specific adaptations unless explicitly identified as a formula above.

## Project provenance

- Runnable case: [lah.m](../../../../examples/tiered/svd-tier-s/lah.m).
- Case manifest: [SVT cases.json](../../../../docs/codex/svt/cases.json).
- Certificate scope and conservative baselines: [SVT VERIFICATION.md](../../../../docs/codex/svt/VERIFICATION.md) and [SVT SOURCES.md](../../../../docs/codex/svt/SOURCES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
