# Diagonally scaled nonsymmetric tridiagonal Toeplitz matrix (Tier S3)

## Quick idea

TOEPLITZ isolates one mathematical reason a dense nonsymmetric eigensystem can be misleading: Use the sorted eigenvalue bottleneck and the explicit left/right condition estimates. The case is intentionally small enough to inspect and is paired with a deterministic runner. Its tier is a statement about pedagogical difficulty and verification depth, not a claim that the public eig routine implements the cited paper's algorithm.

## Mathematical problem

Smoke: n=16, b=4. Demo: n=32, b=4. The original coordinates have subdiagonal 1 and superdiagonal 2^-2b.

Let

```math
A=\operatorname{tridiag}(1,3,2^{-2b}),\qquad
B=\operatorname{tridiag}(2^{-b},3,2^{-b}),\qquad
D=\operatorname{diag}(2^{b(j-1)})_{j=1}^n.
```

The exact identities are

```math
AD=DB,\qquad D^{-1}AD=B.
```

The eigenvalues are

```math
\lambda_k=3+2^{1-b}\cos\!\left(\frac{k\pi}{n+1}\right),\quad k=1,\ldots,n.
```

Right and left eigenvectors scale oppositely:
$v_{jk}=2^{b(j-1)}\sin(j\theta_k)$ and
$w_{jk}=2^{-b(j-1)}\sin(j\theta_k)$, with $\theta_k=k\pi/(n+1)$.

## Why this problem is numerically difficult

The symmetric-looking spectrum hides a severe coordinate scaling. B is symmetric, but A is not; the two matrices are similar rather than unitarily equivalent. The condition of the diagonal similarity D grows like 2^{b(n-1)}, while that number is not itself the condition number of every individual eigenvalue. Individual left/right overlaps determine eigenvalue sensitivity. This is a useful test of whether a dense eigensolver and its diagnostics preserve the original coordinates instead of silently solving the symmetric control.

The matrix is never replaced by a different representation merely because a related control has a convenient spectrum. Exact model facts, generated-input facts, and measured solver output are kept in separate records.

## What the Octave example computes

The matching [toeplitz.m](../../../../examples/tiered/neig-tier-s/toeplitz.m) builds A and B directly, verifies AD=DB, solves A with public eig, and compares against the MP trigonometric reference and the independently solved symmetric B. It evaluates pi, sine, cosine, vector norms, and overlaps in MP. The output labels original and symmetric representations separately and does not use a numerically computed inverse for D.

The example reports the selected case ID, profile, dimensions, input/model identity, and measured rows. Run it from a loaded mplapack-interop package; the package's mp values remain MPFR/MPC values throughout the numerical path.

## Construction and exactness

The exactness audit checks each dyadic entry, the similarity identity, the analytic eigenvalue formula at reference precision, and the closed-form left/right vector relations. The overlap w^H v is evaluated before normalization; for the real formula it is (n+1)/2. The symmetric control is an independent coordinate calculation, not a proof that the original A has symmetric eigenvectors.

The construction audit is intentionally independent of eig: it checks algebraic identities, dyadic serialization, and declared generation guards before using a solver result. A cross-precision match is useful evidence, but it is not an exactness proof.

## Diagnostics

For a computed $A\in\mathbb{C}^{n\times n}$, right vectors $V$, diagonal or block output $D$, and left vectors $W$, the primary residuals are

```math
r_{\mathrm{eig}}=
\frac{\lVert AV-VD\rVert_F}{\lVert A\rVert_F\lVert V\rVert_F},
\qquad
r_{\mathrm{left}}=
\frac{\lVert A^{\mathsf H}W-WD^{\mathsf H}\rVert_F}
{\lVert A\rVert_F\lVert W\rVert_F}.
```

For a selected cluster $J$, use $A V_J-V_JD_J$ and a range/projector or principal-angle comparison; do not turn a repeated or defective cluster into an individual-vector claim.

Also inspect the normwise backward indicator against the correct input, the forward bottleneck against the exact/realized reference, and the left/right or subspace diagnostic appropriate to this case. Keep MP values until the final display. A residual is not a certificate that every eigenvalue digit is forward correct.

## Backward error versus forward error

The residual (r_{\mathrm{eig}}) measures how nearly the returned factors satisfy an eigen-equation. It can be interpreted as a small backward perturbation of the matrix under suitable normalization, but the corresponding forward eigenvalue error is multiplied by eigenvalue and eigenvector conditioning. In a cluster, the forward object is an invariant subspace. In a defective case, a full diagonalizing basis does not exist. The report therefore never promotes a small residual to a universal accuracy claim.

## What arbitrary precision changes

The source matrix is exact dyadic at the stated n,b. Arithmetic precision controls A, B, analytic references, and the solve. Mathematical conditioning is dominated by the left/right scale separation and grows with n and b. Increasing bits makes the original-coordinate computation more trustworthy; it does not convert A into B or reduce the true sensitivity.

Three precision roles must be distinguished. **Input/source precision** describes the stored model and any fixed generator rounding. **Arithmetic/work precision** is the one-operation MPFR/MPC precision used to construct, factor, and inspect that stored value. **Mathematical conditioning** describes sensitivity of the problem and is not repaired merely by printing more digits. The runner also tests low/high ambient defaults and restoration so an unrelated caller setting cannot silently choose the operation precision. No builtin binary64 complex fallback is part of this example.

## Reading the output

Use the sorted eigenvalue bottleneck and the explicit left/right condition estimates. A small residual against A is a backward statement; it does not erase the scaling sensitivity. Compare original-coordinate vectors only after phase/sign normalization and recognize that the eigensolver may order equal-looking values differently. The balance and nobalance rows are diagnostic controls, not promises of improvement.

A PASS line means the declared case-level gates passed; it does not erase the limitations stated above. Compare rows only within the same model identity and profile. If an exactness, coverage, cluster, or precision-contract field is missing, the honest status is incomplete rather than inferred from a pretty display.

## Common mistakes

Do not call A symmetric, report 2^{b(n-1)} as every eigenvalue’s condition number, construct A as a rounded inverse similarity, use native pi/sin/cos constants, or compare A’s vectors directly with B’s vectors.

A useful debugging sequence is: verify the case ID and parameters; verify the serialized input/model hash; inspect the input precision and ambient precision; inspect the residual; then inspect the conditioning-appropriate forward or subspace metric. Do not change parameters after seeing a failure and call the changed run the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Silvia Noschese, Lionello Pasquini, and Lothar Reichel, “Tridiagonal Toeplitz matrices: properties and novel applications.” *Numerical Linear Algebra with Applications* 20(2) (2013), 302–326. DOI: [10.1002/nla.1811](https://doi.org/10.1002/nla.1811)](https://doi.org/10.1002/nla.1811) — The closed-form eigenvalues and eigenvectors explain the symmetric control and the diagonal-scaling sensitivity.
- [Siegfried M. Rump, “Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix.” *SIAM Journal on Matrix Analysis and Applications* 43(4) (2022), 1736–1754. DOI: [10.1137/21M1451440](https://doi.org/10.1137/21M1451440)](https://doi.org/10.1137/21M1451440) — The all-spectrum and Jordan-similarity setting motivates the counted spectrum and subspace warnings; this example remains an independent dense-eigensolver demonstration.

The references motivate the mathematical phenomenon and attribution boundary. The fixed dimensions, dyadic parameters, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated otherwise.

## Project provenance

- Runnable case: [toeplitz.m](../../../../examples/tiered/neig-tier-s/toeplitz.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification jobs and conservative certificate scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
