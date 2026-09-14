# Dyadic Vandermonde matrix (Tier A2)

## Quick idea

A2-VAND is a Tier A control. Vandermonde powers amplify small node errors and produce a rapidly changing singular spectrum even when every node is an exact dyadic. It is one fixed matrix with one matching runnable example. The tier identifies the verification question, not a claim that public dense svd implements any cited structured algorithm.

## Mathematical problem

Smoke: $n=8$ and node denominator $2^4$. Demo: $n=16$ and node denominator
$2^5$. Nodes are $x_i=i/2^d$.

```math
V_{ij}=x_i^{j-1},\qquad x_i=i/2^d,
\qquad \det(V)=\prod_{1\le i<j\le n}(x_j-x_i)>0.
```

The nodes are distinct because $n<2^d$ in the selected profiles.

## Concrete smoke matrix

<!-- smoke-matrix: A2-VAND -->

```math
A_{\mathrm{smoke}} = 2^{-28} \begin{bmatrix}
268435456 & 16777216 & 1048576 & 65536 & 4096 & 256 & 16 & 1 \\
268435456 & 33554432 & 4194304 & 524288 & 65536 & 8192 & 1024 & 128 \\
268435456 & 50331648 & 9437184 & 1769472 & 331776 & 62208 & 11664 & 2187 \\
268435456 & 67108864 & 16777216 & 4194304 & 1048576 & 262144 & 65536 & 16384 \\
268435456 & 83886080 & 26214400 & 8192000 & 2560000 & 800000 & 250000 & 78125 \\
268435456 & 100663296 & 37748736 & 14155776 & 5308416 & 1990656 & 746496 & 279936 \\
268435456 & 117440512 & 51380224 & 22478848 & 9834496 & 4302592 & 1882384 & 823543 \\
268435456 & 134217728 & 67108864 & 33554432 & 16777216 & 8388608 & 4194304 & 2097152
\end{bmatrix}.
```

This is the full concrete smoke fixture for `A2-VAND`. The matching [`vandermonde.m`](../../../../examples/tiered/svd-tier-a/vandermonde.m) selects the same manifest case and hands this input to the public `svd` path; the displayed matrix is not solver output.

The entries are exact integers or dyadic rationals. If a common factor such as `2^{-q}` appears before the bracket, it multiplies every bracket entry and is part of the exact matrix, not a decimal approximation. Fixed-generation cases retain the declared generator precision in their model object; any separate exact widening and solver/work precision remain distinct recorded quantities.

The smoke configuration is the small, inspectable documentation and CI instance. Its matching demo is a separate manifest row that may change the dimension, parameter, or profile; it is not substituted for this input when interpreting the measured result. This separation keeps the source matrix, source precision, and solver output auditable.

## Why this problem is numerically difficult

Vandermonde powers amplify small node errors and produce a rapidly changing singular spectrum even when every node is an exact dyadic. The determinant identity proves nonsingularity but is not a useful accuracy bound for individual singular values. Building successive powers in MP is part of the input contract; native decimal or binary64 nodes would define a different matrix.

The exact model, any analytic or structural reference, and measured SVD output are kept separate. A convenient identity is a check on the named matrix, never a silent replacement for it.

## What the Octave example computes

The matching [vandermonde.m](../../../../examples/tiered/svd-tier-a/vandermonde.m) selects only A2-VAND from the fixed manifest. The matching vandermonde.m generates nodes and powers in MP, runs public svd, and compares values and reconstruction with a wider reference. It verifies node distinctness and determinant-sign algebraically. A dense SVD result is kept separate from any structured totally-nonnegative algorithm suggested by the literature. The runner records shape, parameters, source/model identity, operation precision, and any native control while retaining MPFR/MPC arithmetic.

## Construction and exactness

The common dyadic denominator and successive-power recurrence give a sufficient exactness guard. The determinant product is independently checked for sign and nonzero status. No determinant-based threshold is used as a surrogate rank or SVD accuracy certificate.

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

Input/source precision is the exact dyadic node/power construction. Arithmetic precision controls powers, SVD, and reference. Mathematical conditioning is driven by node spacing and exponent growth. More bits reduce arithmetic error but do not make a Vandermonde matrix well conditioned.

Input/source precision identifies the stored matrix and deliberate once-rounded variants. Arithmetic/work precision is the MPFR/MPC precision used by construction, SVD, and references. Mathematical conditioning belongs to the model and can remain severe at arbitrary precision. Raising mpbits reduces arithmetic error but does not restore a tail lost in the input or make a repeated basis unique. Ambient-precision and restoration tests protect operation ownership.

## Reading the output

Use value-wise relative error where $\sigma_i$ is nonzero, plus $r_{\mathrm{svd}}$ and factor orthogonality. A stable largest singular value says little about the small tail. The node and dimension fields are essential when comparing runs; changing $d$ changes the model.

A PASS line is scoped to this case and profile. Compare rows only when parameters and model identity match. If a rank, subspace, or exactness field is not claimed, do not infer it from a visually stable display.

## Common mistakes

Do not use native powers for the MP input, infer rank from determinant magnitude, form $V^{\mathsf T}V$ as the solver, or call a structured TN result a generic dense result.

For diagnosis, verify case ID and shape, then model hash/input precision, then reconstruction and orthogonality, then the case-specific value or subspace metric. Do not change parameters after a failure and report the changed input as this case.

## Parameter boundary and comparison protocol

The parameter in this page is part of the case identity, not a tuning knob. Record n, the dyadic exponents, the representation (raw, mixed, tall, wide, complex, repeated, or rank-deficient), and the source/model hash before comparing outputs. A reference generated from a neighboring case can be mathematically related and still be the wrong target. This is especially important for a close pair, where replacing a nonzero gap by zero changes the forward problem, and for a rank case, where replacing an exact zero by a tiny positive number changes the rank.

Use a bijective matching for values and a phase-aware or subspace-aware comparison for factors. The matching is performed in MP arithmetic and is a diagnostic, not a way to hide an unmatched value. If the output shape is rectangular, state which economy/full convention is being used. If a factor is not identifiable because of a repeated singular value or a null space, report the projector or range and do not manufacture an individual-vector error. These rules make the short runner reproducible and keep its PASS result scoped to the named model.
## Scope of the claim

This page explains one fixed SVD model and the precise object that the runner measures. Changing a dimension, dyadic exponent, scale, phase, gap, or zero entry changes the source matrix and requires a new case identity. That is especially important for repeated and rank-deficient examples: a zero gap is not a tiny gap, and an exact zero is not merely a small positive singular value.

The analytic spectrum or projector is an independent model check. It is not inserted into the measured factorization, and the public dense SVD is not silently replaced by a structured bidiagonal or totally-nonnegative algorithm. Reconstruction, unitarity, value-wise forward error, and subspace comparisons answer different questions. The runner records all of them with the input and arithmetic precision roles. Binary64 is permitted only at an explicitly declared presentation boundary; it is never an unreported numerical fallback.
## References

- [Plamen Koev, Accurate Eigenvalues and SVDs of Totally Nonnegative Matrices. SIAM Journal on Matrix Analysis and Applications 27(1) (2005), 1–23. DOI: 10.1137/S0895479803438225](https://doi.org/10.1137/S0895479803438225) — The structured-factor accuracy context; this page does not claim a dense SVD implementation of that algorithm.
- [GNU MPFR project, MPFR 4.2 manual, floating-point numbers and rounding](https://www.mpfr.org/mpfr-current/mpfr.html) — Correct-rounding and exponent-range terminology for dyadic input audits.

These sources establish external mathematical context. The selected dimensions, dyadic values, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated above.

## Project provenance

- Runnable case: [vandermonde.m](../../../../examples/tiered/svd-tier-a/vandermonde.m).
- Case manifest: [SVT cases.json](../../../../docs/codex/svt/cases.json).
- Certificate scope: [SVT VERIFICATION.md](../../../../docs/codex/svt/VERIFICATION.md) and [SVT SOURCES.md](../../../../docs/codex/svt/SOURCES.md).
- This page explains the model; the family runner and milestone logs remain the measurement authority.
