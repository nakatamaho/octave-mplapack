# NRO graded block: geometric singular scales (Tier S1)

## Quick idea

S1-NRO-GRADED isolates The graded weights test a spectrum with several scales rather than only one extreme. It is a one-case, deterministic Tier S example: the matrix is small enough to inspect, but the singular spectrum or factors expose a failure mode that a generic smoke matrix would hide. Tier S describes the requested mathematical depth; it does not claim that the public dense svd call implements the cited structured algorithm.

## Mathematical problem

Smoke: $m=4$, $g=4$. Demo: $m=16$, $g=3$. The weights are
$w_j=2^{g(j-1)}$.

```math
B=H_m\operatorname{diag}\!\left(2^{g(j-1)}\right),\qquad
A=\begin{bmatrix}I_m&B\\0&I_m\end{bmatrix}.
```

Each $\beta_j=\sqrt{m}\,2^{g(j-1)}$ produces a reciprocal pair $a_j$ and
$b_j$, so the singular values span multiple exact powers of two before the
square-root transformation.

## Why this problem is numerically difficult

The graded weights test a spectrum with several scales rather than only one extreme. The matrix entries remain powers of two, but the singular values are algebraic expressions with different magnitudes, making sorting and relative comparisons important. A single normwise reconstruction residual can hide one lost small group. The chosen m is a power of four so the Sylvester Hadamard construction is exact and deterministic.

The exact model, any analytic/reference construction, and measured SVD output are separate records. A convenient formula is a reference or invariant check; it is never silently substituted for the matrix sent to the public solver.

## What the Octave example computes

The matching [nro_graded.m](../../../../examples/tiered/svd-tier-s/nro_graded.m) selects only S1-NRO-GRADED from the fixed manifest. The matching nro_graded.m builds the graded B and dense A, runs public svd, and reports all pairs after a bijective MP match. It checks the inverse identity, the sorted reference spectrum, reconstruction, and factor unitarity. The demo is the broad dynamic-range control; it is not a claim that the source paper’s published table is reproduced. The runner records dimensions, case parameters, input/model identity, work/reference precision, measured rows, and any native control.

## Construction and exactness

Weights and Hadamard entries are exact under the declared guard. The reference uses beta_j and the cancellation-safe reciprocal expression independently for each j. The block inverse and determinant are checked before SVD. Cross-precision equality does not replace the exact power-of-two audit.

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

Input/source precision is exact dyadic. Work precision controls each pair and the dense SVD; mathematical conditioning varies geometrically with j and g. More bits improve the smallest groups only if the input and reference remain unchanged. The generator is not regenerated from the solve precision.

Input/source precision identifies the stored matrix and any deliberate once-rounded model. Arithmetic/work precision is the MPFR/MPC precision used by the constructor, SVD, and references. Mathematical conditioning belongs to the model and can remain severe at arbitrary precision. Raising mpbits reduces arithmetic error but does not restore a singular-value tail lost in the input or make repeated factors unique. Ambient-precision and restoration tests ensure operation precision is owned by the stored operands.

## Reading the output

Inspect pairwise reciprocal structure, per-value relative error, $r_{\mathrm{svd}}$, and the count of all $2m$ values. A stable global residual does not prove the smallest group has the requested relative digits. Factor phases and order are arbitrary.

A PASS line is scoped to the named case and profile. Compare only rows with identical parameters and model identity. If a cluster, rank, or exactness field is not claimed, do not infer it from a stable display.

## Common mistakes

Do not use one absolute tolerance for every scale, sort factors by raw columns, form $A^{\mathsf H}A$, or assume a geometric input makes geometric singular values. Do not claim dense SVD has become a structured bidiagonal algorithm.

For diagnosis, first verify case ID and shape, then model hash and input precision, then reconstruction/orthogonality, then the appropriate value or subspace metric. Do not alter parameters after seeing a failure and report the changed matrix as the original case.

## Scope of the claim

This page explains one fixed SVD model and the precise object that the runner measures. Changing a dimension, dyadic exponent, scale, phase, gap, or zero entry changes the source matrix and requires a new case identity. That is especially important for repeated and rank-deficient examples: a zero gap is not a tiny gap, and an exact zero is not merely a small positive singular value.

The analytic spectrum or projector is an independent model check. It is not inserted into the measured factorization, and the public dense SVD is not silently replaced by a structured bidiagonal or totally-nonnegative algorithm. Reconstruction, unitarity, value-wise forward error, and subspace comparisons answer different questions. The runner records all of them with the input and arithmetic precision roles. Binary64 is permitted only at an explicitly declared presentation boundary; it is never an unreported numerical fallback.
## References

- [Tetsuo Nishi, Siegfried M. Rump, and Shin'ichi Oishi, On the generation of very ill-conditioned integer matrices. Nonlinear Theory and Its Applications, IEICE 2(2) (2011), 226–245. DOI: 10.1587/nolta.2.226](https://doi.org/10.1587/nolta.2.226) — The block family and bounded-integer motivation; the chosen dimensions are suite fixtures.
- [GNU MPFR project, MPFR 4.2 manual, floating-point numbers and rounding](https://www.mpfr.org/mpfr-current/mpfr.html) — Correct-rounding and exponent-range terminology used when discussing exact dyadic inputs.

The cited works provide external mathematical context. The dimensions, powers of two, acceptance thresholds, and executable implementation are suite-specific adaptations unless explicitly identified as a formula above.

## Project provenance

- Runnable case: [nro_graded.m](../../../../examples/tiered/svd-tier-s/nro_graded.m).
- Case manifest: [SVT cases.json](../../../../docs/codex/svt/cases.json).
- Certificate scope and conservative baselines: [SVT VERIFICATION.md](../../../../docs/codex/svt/VERIFICATION.md) and [SVT SOURCES.md](../../../../docs/codex/svt/SOURCES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
