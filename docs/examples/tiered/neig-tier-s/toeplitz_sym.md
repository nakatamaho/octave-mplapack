# Symmetric Toeplitz control (Tier S3)

## Quick idea

TOEPLITZ_SYM isolates one mathematical reason a dense nonsymmetric eigensystem can be misleading: Expect a small eigen residual and an orthogonality residual in the symmetric run, but do not compare signs entrywise. The case is intentionally small enough to inspect and is paired with a deterministic runner. Its tier is a statement about pedagogical difficulty and verification depth, not a claim that the public eig routine implements the cited paper's algorithm.

## Mathematical problem

Smoke: $n=16$, $b=4$. Demo: $n=32$, $b=4$. This is $B$ itself, with both
off-diagonals equal to $2^{-b}$.

The control matrix is

```math
B=\mathrm{tridiag}(2^{-b},3,2^{-b}).
```

For $\theta_k=k\pi/(n+1)$, the exact real eigenpairs are

```math
\lambda_k=3+2^{1-b}\cos(\theta_k),\qquad
q_{jk}=\sqrt{\frac{2}{n+1}}\sin(j\theta_k).
```

The dense nonsymmetric case satisfies $A=D B D^{-1}$ in the corresponding orientation, so B is the same spectrum in a symmetric coordinate system.

## Why this problem is numerically difficult

This control isolates the effect of representation. The matrix is real symmetric, so its eigenvectors can be chosen orthonormal and its eigenvalue sensitivity is governed by separated spectral gaps rather than the nonorthogonal left/right scaling in A. Comparing it with A is meaningful only when the two inputs are generated separately and their coordinate labels are preserved. It is not a shortcut that licenses replacing the original Toeplitz test with a symmetric eig call.

The matrix is never replaced by a different representation merely because a related control has a convenient spectrum. Exact model facts, generated-input facts, and measured solver output are kept in separate records.

## What the Octave example computes

The matching [toeplitz_sym.m](../../../../examples/tiered/neig-tier-s/toeplitz_sym.m) solves B through the public eig path, computes the analytic spectrum in MP, and checks orthogonality of the returned eigenvectors. It records the symmetric representation as a control beside, not in place of, TOEPLITZ. The exact dimensions and b are fixed by the manifest.

The example reports the selected case ID, profile, dimensions, input/model identity, and measured rows. Run it from a loaded mplapack-interop package; the package's mp values remain MPFR/MPC values throughout the numerical path.

## Construction and exactness

Dyadic off-diagonal and diagonal entries are checked directly. The reference formula follows from the sine recurrence and is evaluated at MP precision; no native trigonometric constants enter the model. The normalized sine matrix is orthogonal up to the explicitly computed MP error. A repeated or nearly equal output vector basis would still be interpreted as a subspace if parameters are changed.

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

The residual ($r_{\mathrm{eig}}$) measures how nearly the returned factors satisfy an eigen-equation. It can be interpreted as a small backward perturbation of the matrix under suitable normalization, but the corresponding forward eigenvalue error is multiplied by eigenvalue and eigenvector conditioning. In a cluster, the forward object is an invariant subspace. In a defective case, a full diagonalizing basis does not exist. The report therefore never promotes a small residual to a universal accuracy claim.

## What arbitrary precision changes

The source precision is exact dyadic for B; arithmetic precision controls the eigensolver and MP sine reference. The comparison is sensitive to any accidental native conversion of pi or sine. Higher precision should improve both residual and reference evaluation without changing B.

Three precision roles must be distinguished. **Input/source precision** describes the stored model and any fixed generator rounding. **Arithmetic/work precision** is the one-operation MPFR/MPC precision used to construct, factor, and inspect that stored value. **Mathematical conditioning** describes sensitivity of the problem and is not repaired merely by printing more digits. The runner also tests low/high ambient defaults and restoration so an unrelated caller setting cannot silently choose the operation precision. No builtin binary64 complex fallback is part of this example.

## Reading the output

Expect a small eigen residual and an orthogonality residual in the symmetric run, but do not compare signs entrywise. The difference between B’s clean eigenvectors and A’s scaled vectors is the intended observation. Compare absolute and relative eigenvalue error against the analytic reference, while remembering that a residual is a backward error indicator rather than a complete forward certificate.

A PASS line means the declared case-level gates passed; it does not erase the limitations stated above. Compare rows only within the same model identity and profile. If an exactness, coverage, cluster, or precision-contract field is missing, the honest status is incomplete rather than inferred from a pretty display.

## Common mistakes

Do not identify B with A, use D’s condition as B’s eigenvalue condition, use binary64 sine values as the MP reference, or require exact signs/phases from eig.

A useful debugging sequence is: verify the case ID and parameters; verify the serialized input/model hash; inspect the input precision and ambient precision; inspect the residual; then inspect the conditioning-appropriate forward or subspace metric. Do not change parameters after seeing a failure and call the changed run the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Silvia Noschese, Lionello Pasquini, and Lothar Reichel, “Tridiagonal Toeplitz matrices: properties and novel applications.” *Numerical Linear Algebra with Applications* 20(2) (2013), 302–326. DOI: [10.1002/nla.1811](https://doi.org/10.1002/nla.1811)](https://doi.org/10.1002/nla.1811) — The closed-form eigenvalues and eigenvectors explain the symmetric control and the diagonal-scaling sensitivity.
- [Siegfried M. Rump, “Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix.” *SIAM Journal on Matrix Analysis and Applications* 43(4) (2022), 1736–1754. DOI: [10.1137/21M1451440](https://doi.org/10.1137/21M1451440)](https://doi.org/10.1137/21M1451440) — The all-spectrum and Jordan-similarity setting motivates the counted spectrum and subspace warnings; this example remains an independent dense-eigensolver demonstration.

The references motivate the mathematical phenomenon and attribution boundary. The fixed dimensions, dyadic parameters, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated otherwise.

## Project provenance

- Runnable case: [toeplitz_sym.m](../../../../examples/tiered/neig-tier-s/toeplitz_sym.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification jobs and conservative certificate scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
