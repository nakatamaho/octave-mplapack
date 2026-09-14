# Symmetric diagonally dominant path (Tier S4)

## Quick idea

S4-DD-SYM isolates The smallest singular value is the tiny diagonal-dominance margin tau, while neighboring values are controlled by a path Laplacian. It is a one-case, deterministic Tier S example: the matrix is small enough to inspect, but the singular spectrum or factors expose a failure mode that a generic smoke matrix would hide. Tier S describes the requested mathematical depth; it does not claim that the public dense svd call implements the cited structured algorithm.

## Mathematical problem

Smoke: $n=8$, $b=32$, $\rho=1$. Demo: $n=24$, $b=160$, $\rho=1$. The
positive shift is $\tau=2^{-b}$.

```math
A_{11}=1+\tau,\quad A_{12}=-1;
```


```math
A_{i,i-1}=-1,\quad A_{ii}=2+\tau,\quad A_{i,i+1}=-1,\\
A_{n,n-1}=-1,\quad A_{nn}=1+\tau.
```

The exact ascending singular values are

```math
\sigma_k=\tau+4\sin^2\!\left(\frac{k\pi}{2n}\right),
\qquad k=0,\ldots,n-1.
```

## Why this problem is numerically difficult

The smallest singular value is the tiny diagonal-dominance margin tau, while neighboring values are controlled by a path Laplacian. This makes loss of tau in a low-precision or native construction immediately visible. The symmetric case has an analytic positive-term formula, but its trigonometric evaluation is not itself an outward interval proof.

The exact model, any analytic/reference construction, and measured SVD output are separate records. A convenient formula is a reference or invariant check; it is never silently substituted for the matrix sent to the public solver.

## What the Octave example computes

The matching [dd_sym.m](../../../../examples/tiered/svd-tier-s/dd_sym.m) selects only S4-DD-SYM from the fixed manifest. The matching dd_sym.m constructs the path directly, runs public svd, and compares with the MP formula after setting $\sigma_0=\tau$ exactly. It reports the explicit model, any below-guard rounded input, reconstruction, orthogonality, and the smallest-value error. The demo deliberately records when $p=128$ is below the exact construction guard for $b=160$. The runner records dimensions, case parameters, input/model identity, work/reference precision, measured rows, and any native control.

## Construction and exactness

Each row has dominance margin $\tau$ and the dyadic inputs are checked. For $\rho=1$, SPD and the path eigenvalue formula provide independent checks; $\pi$ and sine are evaluated in MP. A separate V1 certificate is required for rigorous enclosures. Native $\tau$ loss is logged as an altered input, not called an MP failure.

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

Input/source precision determines whether tau is present; arithmetic precision controls construction, SVD, and formula. Mathematical conditioning is severe at the small end even in the symmetric case. More bits preserve tau and reduce solver error but cannot recover it from a pre-rounded zero.

Input/source precision identifies the stored matrix and any deliberate once-rounded model. Arithmetic/work precision is the MPFR/MPC precision used by the constructor, SVD, and references. Mathematical conditioning belongs to the model and can remain severe at arbitrary precision. Raising mpbits reduces arithmetic error but does not restore a singular-value tail lost in the input or make repeated factors unique. Ambient-precision and restoration tests ensure operation precision is owned by the stored operands.

## Reading the output

The first singular value should equal $\tau$ in the exact model. Read its absolute and relative errors separately, because $\tau$ is tiny. A good reconstruction and orthogonality result does not compensate for a rounded input with $\tau=0$. The sorted values are the measured spectrum, not an insertion of the formula.

A PASS line is scoped to the named case and profile. Compare only rows with identical parameters and model identity. If a cluster, rank, or exactness field is not claimed, do not infer it from a stable display.

## Common mistakes

Do not use 2-2cos as the small-value formula, call tau loss a solver failure, use native trigonometric constants for MP reference, or claim the formula alone is a certified interval.

For diagnosis, first verify case ID and shape, then model hash and input precision, then reconstruction/orthogonality, then the appropriate value or subspace metric. Do not alter parameters after seeing a failure and report the changed matrix as the original case.

## Scope of the claim

This page explains one fixed SVD model and the precise object that the runner measures. Changing a dimension, dyadic exponent, scale, phase, gap, or zero entry changes the source matrix and requires a new case identity. That is especially important for repeated and rank-deficient examples: a zero gap is not a tiny gap, and an exact zero is not merely a small positive singular value.

The analytic spectrum or projector is an independent model check. It is not inserted into the measured factorization, and the public dense SVD is not silently replaced by a structured bidiagonal or totally-nonnegative algorithm. Reconstruction, unitarity, value-wise forward error, and subspace comparisons answer different questions. The runner records all of them with the input and arithmetic precision roles. Binary64 is permitted only at an explicitly declared presentation boundary; it is never an unreported numerical fallback.
## References

- [Froilán M. Dopico and Plamen Koev, Perturbation theory for the LDU factorization and accurate computations for diagonally dominant matrices. Numerische Mathematik 119 (2011), 337–371. DOI: 10.1007/s00211-011-0382-3](https://doi.org/10.1007/s00211-011-0382-3) — Diagonal-dominance representation context; the path formulas here are suite adaptations.
- [Netlib LAPACK, DLASQ1 documentation, current reference page](https://www.netlib.org/lapack/explore-html/d5/dce/group__lasq1_ga5a8c1474ef61ff7c59c17412ae456ca6.html) — A relative-accuracy bidiagonal comparator; it is not the dense SVD implementation used by this case.
- [GNU MPFR project, MPFR 4.2 manual, floating-point numbers and rounding](https://www.mpfr.org/mpfr-current/mpfr.html) — Correct-rounding and exponent-range terminology used when discussing exact dyadic inputs.

The cited works provide external mathematical context. The dimensions, powers of two, acceptance thresholds, and executable implementation are suite-specific adaptations unless explicitly identified as a formula above.

## Project provenance

- Runnable case: [dd_sym.m](../../../../examples/tiered/svd-tier-s/dd_sym.m).
- Case manifest: [SVT cases.json](../../../../docs/codex/svt/cases.json).
- Certificate scope and conservative baselines: [SVT VERIFICATION.md](../../../../docs/codex/svt/VERIFICATION.md) and [SVT SOURCES.md](../../../../docs/codex/svt/SOURCES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
