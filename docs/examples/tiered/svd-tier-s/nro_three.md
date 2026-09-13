# NRO three-level block: extreme and unit singular groups (Tier S1)

## Quick idea

S1-NRO-THREE isolates This variant adds a true unit group to the extreme reciprocal groups. It is a one-case, deterministic Tier S example: the matrix is small enough to inspect, but the singular spectrum or factors expose a failure mode that a generic smoke matrix would hide. Tier S describes the requested mathematical depth; it does not claim that the public dense svd call implements the cited structured algorithm.

## Mathematical problem

Smoke: m=4, b=12. Demo: m=16, b=40. The first half of the weights are 2^b and the second half are zero.

$$
B = H_m diag(2^b,...,2^b,0,...,0),
\qquad A=[I_m\ B;0\ I_m].
$$
For a nonzero weight the pair is (a,b) above; for w_j=0, beta_j=0 and both singular values are exactly 1.

## Why this problem is numerically difficult

This variant adds a true unit group to the extreme reciprocal groups. It checks whether a solver and its matching logic preserve multiplicity rather than treating the middle values as accidental. The matrix remains nonsingular even though B is rank deficient, because A is block unit triangular. Individual singular vectors in the unit group are not identifiable; the correct comparison is a subspace/projector comparison.

The exact model, any analytic/reference construction, and measured SVD output are separate records. A convenient formula is a reference or invariant check; it is never silently substituted for the matrix sent to the public solver.

## What the Octave example computes

The matching [nro_three.m](../../../../examples/tiered/svd-tier-s/nro_three.m) selects only S1-NRO-THREE from the fixed manifest. The matching nro_three.m selects the three-level case, measures the complete 2m singular spectrum, checks the exact inverse and reconstruction, and compares the unit group as a cluster. It records the expected number of unit singular values separately from the extreme group. No known singular values are inserted into measured output. The runner records dimensions, case parameters, input/model identity, work/reference precision, measured rows, and any native control.

## Construction and exactness

The zero weights are represented exactly, the Hadamard entries are integer, and the inverse identity is checked directly. The stable two-by-two formula gives a=b=1 when beta=0; this is an analytic reference, not an SVD shortcut. The exact rank of B and full rank of A are checked separately.

The source audit distinguishes exactness of the constructed matrix from agreement between two floating computations. All arithmetic on the model and measured path remains MPFR/MPC; conversion to binary64 is limited to explicitly labelled presentation controls.

## Diagnostics

For $A\in\mathbb{C}^{m\times n}$, $U$, $\Sigma$, and $V$, use
$$
A=U\Sigma V^{\mathsf H},\qquad
r_{\mathrm{svd}}=\frac{\lVert A-U\Sigma V^{\mathsf H}\rVert_F}{\lVert A\rVert_F},
\qquad
r_U=\lVert U^{\mathsf H}U-I\rVert_F,\quad
r_V=\lVert V^{\mathsf H}V-I\rVert_F.
$$
For repeated singular values compare the associated left/right subspaces, not individual columns.

Also inspect the value-wise forward bottleneck against the exact or analytic reference, the rank/cluster diagnostic when applicable, and any inverse or projector check. Keep the residuals as MP values until display. A small reconstruction residual does not certify every singular value digit.

## Backward error versus forward error

The reconstruction residual is a backward-error style measure for the factorization equation: the returned factors nearly explain A. Forward singular-value error compares each returned value with the mathematical value of the stored model and depends on gaps, scaling, and conditioning. For a repeated group, the stable forward object is a subspace/projector. For rank-deficient data, an exact model rank proof is distinct from thresholding tiny measured values.

## What arbitrary precision changes

Input precision records the zero/nonzero dyadic weights. Arithmetic precision controls dense construction and the SVD. Mathematical conditioning is determined by the extreme beta values, while the unit cluster has multiplicity and basis nonuniqueness. More bits should protect the extreme values but cannot make a repeated factor basis unique.

Input/source precision identifies the stored matrix and any deliberate once-rounded model. Arithmetic/work precision is the MPFR/MPC precision used by the constructor, SVD, and references. Mathematical conditioning belongs to the model and can remain severe at arbitrary precision. Raising mpbits reduces arithmetic error but does not restore a singular-value tail lost in the input or make repeated factors unique. Ambient-precision and restoration tests ensure operation precision is owned by the stored operands.

## Reading the output

Expect a reciprocal extreme group plus a repeated unit group. r_svd and factor orthogonality describe the computed factors; a projector or subspace metric describes the repeated unit group. Sorting is done only in the reference and does not impose a basis order on the returned factors.

A PASS line is scoped to the named case and profile. Compare only rows with identical parameters and model identity. If a cluster, rank, or exactness field is not claimed, do not infer it from a stable display.

## Common mistakes

Do not interpret rank(B)=m/2 as rank(A)<2m, compare unit singular vectors one by one, or append known ones to the measured spectrum. Do not cancel the small reciprocal values.

For diagnosis, first verify case ID and shape, then model hash and input precision, then reconstruction/orthogonality, then the appropriate value or subspace metric. Do not alter parameters after seeing a failure and report the changed matrix as the original case.

## Scope of the claim

This page explains one fixed SVD model and the precise object that the runner measures. Changing a dimension, dyadic exponent, scale, phase, gap, or zero entry changes the source matrix and requires a new case identity. That is especially important for repeated and rank-deficient examples: a zero gap is not a tiny gap, and an exact zero is not merely a small positive singular value.

The analytic spectrum or projector is an independent model check. It is not inserted into the measured factorization, and the public dense SVD is not silently replaced by a structured bidiagonal or totally-nonnegative algorithm. Reconstruction, unitarity, value-wise forward error, and subspace comparisons answer different questions. The runner records all of them with the input and arithmetic precision roles. Binary64 is permitted only at an explicitly declared presentation boundary; it is never an unreported numerical fallback.
## References

- [Tetsuo Nishi, Siegfried M. Rump, and Shin'ichi Oishi, On the generation of very ill-conditioned integer matrices. Nonlinear Theory and Its Applications, IEICE 2(2) (2011), 226–245. DOI: 10.1587/nolta.2.226](https://doi.org/10.1587/nolta.2.226) — The block family and bounded-integer motivation; the chosen dimensions are suite fixtures.
- [GNU MPFR project, MPFR 4.2 manual, floating-point numbers and rounding](https://www.mpfr.org/mpfr-current/mpfr.html) — Correct-rounding and exponent-range terminology used when discussing exact dyadic inputs.

The cited works provide external mathematical context. The dimensions, powers of two, acceptance thresholds, and executable implementation are suite-specific adaptations unless explicitly identified as a formula above.

## Project provenance

- Runnable case: [nro_three.m](../../../../examples/tiered/svd-tier-s/nro_three.m).
- Case manifest: [SVT cases.json](../../../../docs/codex/svt/cases.json).
- Certificate scope and conservative baselines: [SVT VERIFICATION.md](../../../../docs/codex/svt/VERIFICATION.md) and [SVT SOURCES.md](../../../../docs/codex/svt/SOURCES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
