# NRO two-level block: reciprocal singular groups (Tier S1)

## Quick idea

S1-NRO-TWO isolates The input is integer/dyadic and full rank, but the off-diagonal block makes reciprocal singular values as large and small as beta. It is a one-case, deterministic Tier S example: the matrix is small enough to inspect, but the singular spectrum or factors expose a failure mode that a generic smoke matrix would hide. Tier S describes the requested mathematical depth; it does not claim that the public dense svd call implements the cited structured algorithm.

## Mathematical problem

Smoke: $m=4$, $b=12$, giving a $2m=8$ square matrix. Demo: $m=16$,
$b=40$, giving a 32-by-32 matrix.

```math
B=H_m\mathrm{diag}(w_1,\ldots,w_m),\qquad
A=\begin{bmatrix}I_m&B\\0&I_m\end{bmatrix},\qquad w_j=2^b.
```

With $\beta_j=\sqrt{m}\,w_j$, the two singular values contributed by each
block are

```math
a_j=\frac{\sqrt{\beta_j^2+4}+\beta_j}{2},\qquad
b_j=\frac{2}{\sqrt{\beta_j^2+4}+\beta_j}.
```

## Why this problem is numerically difficult

The input is integer/dyadic and full rank, but the off-diagonal block makes reciprocal singular values as large and small as beta. Orthogonal reduction shows the spectrum exactly, while a dense SVD must still materialize A and compute factors. The small value must be evaluated by the reciprocal formula; subtracting nearly equal square roots would create an avoidable loss. The demo reaches a large condition range without asking native arithmetic to fail.

The exact model, any analytic/reference construction, and measured SVD output are separate records. A convenient formula is a reference or invariant check; it is never silently substituted for the matrix sent to the public solver.

## What the Octave example computes

The matching [nro_two.m](../../../../examples/tiered/svd-tier-s/nro_two.m) selects only S1-NRO-TWO from the fixed manifest. The matching nro_two.m selects S1-NRO-TWO, builds the block through the public MP path, runs svd(A), and compares sorted values with the stable two-by-two reference. It checks A times the explicit inverse formula, reconstruction, and factor orthogonality. The inverse formula is a construction invariant, not a replacement for the measured SVD. The runner records dimensions, case parameters, input/model identity, work/reference precision, measured rows, and any native control.

## Construction and exactness

$H_m$ is generated with integer entries and the block inverse is

```math
\begin{bmatrix}
I & -B\\
0 & I
\end{bmatrix}.
```

The generator records the significand/range guard and verifies $\det(A)=1$ and every dyadic entry. The singular reference follows from applying orthogonal factors to $B$, not from forming $A^{\mathsf H}A$. Exactness is checked independently of the returned factors.

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

The source/input values are exact dyadics at the selected m,b. Work precision controls B, A, svd, and the stable beta formula; mathematical conditioning is approximately the square of beta across the reciprocal pair. More bits preserve the small singular value but do not reduce the condition number. The scaled demo remains the same named model at every work precision.

Input/source precision identifies the stored matrix and any deliberate once-rounded model. Arithmetic/work precision is the MPFR/MPC precision used by the constructor, SVD, and references. Mathematical conditioning belongs to the model and can remain severe at arbitrary precision. Raising mpbits reduces arithmetic error but does not restore a singular-value tail lost in the input or make repeated factors unique. Ambient-precision and restoration tests ensure operation precision is owned by the stored operands.

## Reading the output

Read the largest and smallest singular values as a reciprocal pair, then inspect $r_{\mathrm{svd}}$ and the two orthogonality residuals. A good reconstruction can coexist with a poor relative error in the smallest value when its condition is extreme. The factor columns are not required to match a particular Hadamard basis when values are repeated.

A PASS line is scoped to the named case and profile. Compare only rows with identical parameters and model identity. If a cluster, rank, or exactness field is not claimed, do not infer it from a stable display.

## Common mistakes

Do not form $A^{\mathsf H}A$ as the primary SVD algorithm, use cancellation for the small value, compare individual repeated vectors, or claim native failure is required. Do not turn the inverse invariant into a measured SVD result.

For diagnosis, first verify case ID and shape, then model hash and input precision, then reconstruction/orthogonality, then the appropriate value or subspace metric. Do not alter parameters after seeing a failure and report the changed matrix as the original case.

## Scope of the claim

This page explains one fixed SVD model and the precise object that the runner measures. Changing a dimension, dyadic exponent, scale, phase, gap, or zero entry changes the source matrix and requires a new case identity. That is especially important for repeated and rank-deficient examples: a zero gap is not a tiny gap, and an exact zero is not merely a small positive singular value.

The analytic spectrum or projector is an independent model check. It is not inserted into the measured factorization, and the public dense SVD is not silently replaced by a structured bidiagonal or totally-nonnegative algorithm. Reconstruction, unitarity, value-wise forward error, and subspace comparisons answer different questions. The runner records all of them with the input and arithmetic precision roles. Binary64 is permitted only at an explicitly declared presentation boundary; it is never an unreported numerical fallback.
## References

- [Tetsuo Nishi, Siegfried M. Rump, and Shin'ichi Oishi, On the generation of very ill-conditioned integer matrices. Nonlinear Theory and Its Applications, IEICE 2(2) (2011), 226–245. DOI: 10.1587/nolta.2.226](https://doi.org/10.1587/nolta.2.226) — The block family and bounded-integer motivation; the chosen dimensions are suite fixtures.
- [GNU MPFR project, MPFR 4.2 manual, floating-point numbers and rounding](https://www.mpfr.org/mpfr-current/mpfr.html) — Correct-rounding and exponent-range terminology used when discussing exact dyadic inputs.

The cited works provide external mathematical context. The dimensions, powers of two, acceptance thresholds, and executable implementation are suite-specific adaptations unless explicitly identified as a formula above.

## Project provenance

- Runnable case: [nro_two.m](../../../../examples/tiered/svd-tier-s/nro_two.m).
- Case manifest: [SVT cases.json](../../../../docs/codex/svt/cases.json).
- Certificate scope and conservative baselines: [SVT VERIFICATION.md](../../../../docs/codex/svt/VERIFICATION.md) and [SVT SOURCES.md](../../../../docs/codex/svt/SOURCES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
