# Scaled normal Forsythe control (Tier S4)

## Quick idea

FORSYTHE_SCALED isolates one mathematical reason a dense nonsymmetric eigensystem can be misleading: The primary diagnostics are $r_{\mathrm{eig}}$, the unitary eigenvector residual, and the normalized circle bottleneck. The case is intentionally small enough to inspect and is paired with a deterministic runner. Its tier is a statement about pedagogical difficulty and verification depth, not a claim that the public eig routine implements the cited paper's algorithm.

## Mathematical problem

Smoke: $n=8$, $a=4$, $r=2^{-a}$. Demo: $n=16$, $a=12$. The matrix is
$I+rP$, where $P$ is the cyclic permutation.

Let $P$ be the cyclic permutation matrix with $P_{i,i+1}=1$ and $P_{n,1}=1$. The control is

```math
F_{\mathrm{scaled}}=I+rP,\qquad r=2^{-a},\qquad P^{\mathsf H}P=I.
```

Because $P$ is unitary, its eigenvalues are $\zeta_k=\exp(2\pi i k/n)$ and

```math
\lambda_k=1+r\zeta_k.
```

This matrix is unitarily diagonalizable and is related to the original Forsythe form by $FD=DF_{\mathrm{scaled}}$.

## Concrete smoke matrix

<!-- smoke-matrix: FORSYTHE_SCALED -->

```math
A_{\mathrm{smoke}} = \begin{bmatrix}
1 & 2^{-4} & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 1 & 2^{-4} & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 1 & 2^{-4} & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 1 & 2^{-4} & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 1 & 2^{-4} & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 1 & 2^{-4} & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 1 & 2^{-4} \\
2^{-4} & 0 & 0 & 0 & 0 & 0 & 0 & 1
\end{bmatrix}.
```

This is the full concrete smoke fixture for `FORSYTHE_SCALED`. The matching [`forsythe_scaled.m`](../../../../examples/tiered/neig-tier-s/forsythe_scaled.m) selects the same manifest case and hands this input to the public `eig` path; the displayed matrix is not solver output.

The entries are exact integers or dyadic rationals. If a common factor such as `2^{-q}` appears before the bracket, it multiplies every bracket entry and is part of the exact matrix, not a decimal approximation. Fixed-generation cases retain the declared generator precision in their model object; any separate exact widening and solver/work precision remain distinct recorded quantities.

The smoke configuration is the small, inspectable documentation and CI instance. Its matching demo is a separate manifest row that may change the dimension, parameter, or profile; it is not substituted for this input when interpreting the measured result. This separation keeps the source matrix, source precision, and solver output auditable.

## Why this problem is numerically difficult

This is the normal-coordinate control for the tiny cyclic perturbation. It asks whether the eigensolver can preserve a small but exactly representable displacement when no nonunitary diagonal scaling is present. The result should be interpreted with the original FORSYTHE case: equal spectra do not imply equal eigenvector conditioning or equal pseudospectra in the original coordinates. The control also makes the unit-circle matching metric transparent.

The matrix is never replaced by a different representation merely because a related control has a convenient spectrum. Exact model facts, generated-input facts, and measured solver output are kept in separate records.

## What the Octave example computes

The matching [forsythe_scaled.m](../../../../examples/tiered/neig-tier-s/forsythe_scaled.m) builds $P$ directly, forms $I+rP$ in MP, and measures the dense eig result. It compares normalized coordinates $(\lambda-1)/r$ with the MP roots of unity and checks the unitary similarity/control identities. It does not form $P$ through a generic exponential or through a binary64 complex fallback.

The example reports the selected case ID, profile, dimensions, input/model identity, and measured rows. Run it from a loaded mplapack-interop package; the package's mp values remain MPFR/MPC values throughout the numerical path.

## Construction and exactness

The constructor verifies $P$'s permutation entries, $P^n=I$, and $P^{\mathsf H}P=I$. The dyadic scale $r$ is exact within the selected input precision; complex roots of unity are analytic MP references, with real endpoints fixed explicitly. The identity with FORSYTHE is checked independently from measured eigenvalues.

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

The input is an exact dyadic normal control; arithmetic precision controls r, complex products, and root-of-unity evaluation. Mathematical conditioning is much milder than for the original Forsythe representation. More bits preserve the displacement from 1 and improve the normalized circle comparison; they do not change the scale r.

Three precision roles must be distinguished. **Input/source precision** describes the stored model and any fixed generator rounding. **Arithmetic/work precision** is the one-operation MPFR/MPC precision used to construct, factor, and inspect that stored value. **Mathematical conditioning** describes sensitivity of the problem and is not repaired merely by printing more digits. The runner also tests low/high ambient defaults and restoration so an unrelated caller setting cannot silently choose the operation precision. No builtin binary64 complex fallback is part of this example.

## Reading the output

The primary diagnostics are $r_{\mathrm{eig}}$, the unitary eigenvector residual, and the normalized circle bottleneck. Since the matrix is normal, a small residual has a more direct forward interpretation than in the original scaled coordinates, but it still does not certify every displayed digit. Signs, phases, and column order remain arbitrary.

A PASS line means the declared case-level gates passed; it does not erase the limitations stated above. Compare rows only within the same model identity and profile. If an exactness, coverage, cluster, or precision-contract field is missing, the honest status is incomplete rather than inferred from a pretty display.

## Common mistakes

Do not claim this control proves the original matrix is well conditioned, compare unnormalized $\lambda$ with a relative tolerance around 1, or use native roots of unity as the MP reference. Do not hide the diagonal scaling relationship.

A useful debugging sequence is: verify the case ID and parameters; verify the serialized input/model hash; inspect the input precision and ambient precision; inspect the residual; then inspect the conditioning-appropriate forward or subspace metric. Do not change parameters after seeing a failure and call the changed run the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Siegfried M. Rump, “Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix.” *SIAM Journal on Matrix Analysis and Applications* 43(4) (2022), 1736–1754. DOI: [10.1137/21M1451440](https://doi.org/10.1137/21M1451440)](https://doi.org/10.1137/21M1451440) — The all-spectrum and Jordan-similarity setting motivates the counted spectrum and subspace warnings; this example remains an independent dense-eigensolver demonstration.
- [Nicholas J. Higham, *Accuracy and Stability of Numerical Algorithms*, 2nd ed. SIAM (2002). DOI: [10.1137/1.9780898718027](https://doi.org/10.1137/1.9780898718027)](https://doi.org/10.1137/1.9780898718027) — The general backward/forward-error vocabulary and nonnormal sensitivity interpretation used here.

The references motivate the mathematical phenomenon and attribution boundary. The fixed dimensions, dyadic parameters, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated otherwise.

## Project provenance

- Runnable case: [forsythe_scaled.m](../../../../examples/tiered/neig-tier-s/forsythe_scaled.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification jobs and conservative certificate scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
