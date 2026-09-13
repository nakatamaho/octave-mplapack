# Jacobi–Stirling second-kind matrix (Tier S2)

## Quick idea

S2-JS isolates The entries grow combinatorially while the diagonal remains one. It is a one-case, deterministic Tier S example: the matrix is small enough to inspect, but the singular spectrum or factors expose a failure mode that a generic smoke matrix would hide. Tier S describes the requested mathematical depth; it does not claim that the public dense svd call implements the cited structured algorithm.

## Mathematical problem

Smoke: $n=8$ and $z=1$. Demo: $n=16$ and $z=1$. Indices $i,j$ are
zero-based in the recurrence.

```math
J(0,0)=1,\qquad
J(i,j)=J(i-1,j-1)+j(j+1)J(i-1,j),\qquad 1\le j\le i.
```

The matrix is lower triangular with unit diagonal; its leading rows are [1], [0 1], [0 2 1], [0 4 8 1]. Therefore det(J)=1.

## Why this problem is numerically difficult

The entries grow combinatorially while the diagonal remains one. A rounded lower-triangular input can still have full rank but a materially different small singular spectrum. The structural zero pattern also makes the phrase totally positive unsafe if it means every minor is strictly positive; the appropriate nonnegative terminology is part of the documentation.

The exact model, any analytic/reference construction, and measured SVD output are separate records. A convenient formula is a reference or invariant check; it is never silently substituted for the matrix sent to the public solver.

## What the Octave example computes

The matching [jacobi_stirling.m](../../../../examples/tiered/svd-tier-s/jacobi_stirling.m) selects only S2-JS from the fixed manifest. The matching jacobi_stirling.m generates the integer recurrence in MP, runs public svd, and compares the complete spectrum with a high-precision reference. It checks unit diagonal, lower-triangular structure, determinant, small known rows, reconstruction, and factor orthogonality. The SVD call is dense; it is not advertised as an implementation of the paper’s structured bidiagonal-factor method. The runner records dimensions, case parameters, input/model identity, work/reference precision, measured rows, and any native control.

## Construction and exactness

The recurrence is evaluated with an explicit conservative bit budget and row-sum bound. n=1 and small rows are checked independently. The exact matrix is serialized before the SVD and reconstructed at a wider precision to distinguish source exactness from solver agreement.

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

Input/source precision is exact integer recurrence data. Arithmetic precision controls recurrence, dense SVD, and reference. Mathematical conditioning grows with combinatorial entries and can dominate after arithmetic residuals are small. More bits protect relative accuracy but do not change J’s unit diagonal structure.

Input/source precision identifies the stored matrix and any deliberate once-rounded model. Arithmetic/work precision is the MPFR/MPC precision used by the constructor, SVD, and references. Mathematical conditioning belongs to the model and can remain severe at arbitrary precision. Raising mpbits reduces arithmetic error but does not restore a singular-value tail lost in the input or make repeated factors unique. Ambient-precision and restoration tests ensure operation precision is owned by the stored operands.

## Reading the output

Read singular values in descending order, then the full reconstruction and orthogonality diagnostics. A small singular value can be sensitive even when det(J)=1. Repeated or near-repeated values require subspace interpretation; individual factors are phase/sign ambiguous.

A PASS line is scoped to the named case and profile. Compare only rows with identical parameters and model identity. If a cluster, rank, or exactness field is not claimed, do not infer it from a stable display.

## Common mistakes

Do not compute entries with binary64 factorials, infer SVD accuracy from det=1, claim every minor is strictly positive, or call the dense run a structured TN/Jacobi–Stirling algorithm.

For diagnosis, first verify case ID and shape, then model hash and input precision, then reconstruction/orthogonality, then the appropriate value or subspace metric. Do not alter parameters after seeing a failure and report the changed matrix as the original case.

## Scope of the claim

This page explains one fixed SVD model and the precise object that the runner measures. Changing a dimension, dyadic exponent, scale, phase, gap, or zero entry changes the source matrix and requires a new case identity. That is especially important for repeated and rank-deficient examples: a zero gap is not a tiny gap, and an exact zero is not merely a small positive singular value.

The analytic spectrum or projector is an independent model check. It is not inserted into the measured factorization, and the public dense SVD is not silently replaced by a structured bidiagonal or totally-nonnegative algorithm. Reconstruction, unitarity, value-wise forward error, and subspace comparisons answer different questions. The runner records all of them with the input and arithmetic precision roles. Binary64 is permitted only at an explicitly declared presentation boundary; it is never an unreported numerical fallback.
## References

- [Jorge Delgado and Juan Manuel Peña, Fast and accurate algorithms for Jacobi–Stirling matrices. Applied Mathematics and Computation 236 (2014), 253–259. DOI: 10.1016/j.amc.2014.03.047](https://doi.org/10.1016/j.amc.2014.03.047) — The recurrence family and high-relative-accuracy motivation.
- [GNU MPFR project, MPFR 4.2 manual, floating-point numbers and rounding](https://www.mpfr.org/mpfr-current/mpfr.html) — Correct-rounding and exponent-range terminology used when discussing exact dyadic inputs.

The cited works provide external mathematical context. The dimensions, powers of two, acceptance thresholds, and executable implementation are suite-specific adaptations unless explicitly identified as a formula above.

## Project provenance

- Runnable case: [jacobi_stirling.m](../../../../examples/tiered/svd-tier-s/jacobi_stirling.m).
- Case manifest: [SVT cases.json](../../../../docs/codex/svt/cases.json).
- Certificate scope and conservative baselines: [SVT VERIFICATION.md](../../../../docs/codex/svt/VERIFICATION.md) and [SVT SOURCES.md](../../../../docs/codex/svt/SOURCES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
