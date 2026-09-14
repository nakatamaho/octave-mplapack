# Dense similarity with a genuine 2-by-2 Jordan block (Tier S2)

## Quick idea

SIM_JORDAN isolates one mathematical reason a dense nonsymmetric eigensystem can be misleading: A small $r_{\mathrm{eig}}$ for two columns does not mean those columns form a diagonalization. The case is intentionally small enough to inspect and is paired with a deterministic runner. Its tier is a statement about pedagogical difficulty and verification depth, not a claim that the public eig routine implements the cited paper's algorithm.

## Mathematical problem

Smoke: $n=8$ and demo: $n=16$. The leading block is $J_2(1)$, with
algebraic multiplicity 2 and geometric multiplicity 1.

Define

```math
J_{\mathrm{Jordan}}=
\begin{bmatrix}1&1\\0&1\end{bmatrix}\oplus\mathrm{diag}(4,5,\ldots,n),
\qquad A=YJ_{\mathrm{Jordan}}X,\qquad X=LU,\;Y=U^{-1}L^{-1}.
```

The root 1 has algebraic multiplicity two but only one independent eigenvector. The nontrivial generalized relation is $J_{\mathrm{Jordan}}e_2=e_2+e_1$, which becomes

```math
A(Y e_2)=Y e_2+Y e_1.
```

## Concrete smoke matrix

<!-- smoke-matrix: SIM_JORDAN -->

```math
A_{\mathrm{smoke}} = \begin{bmatrix}
9 & 34 & 24 & -2 & 2 & -2 & 2 & -2 \\
-7 & -31 & -23 & 2 & -2 & 2 & -2 & 2 \\
6 & 30 & 23 & -2 & 2 & -2 & 2 & -2 \\
-5 & -25 & -15 & 6 & -2 & 2 & -2 & 2 \\
4 & 20 & 12 & 0 & 7 & -2 & 2 & -2 \\
-3 & -15 & -9 & 0 & 0 & 8 & -2 & 2 \\
2 & 10 & 6 & 0 & 0 & 0 & 9 & -2 \\
-1 & -5 & -3 & 0 & 0 & 0 & 0 & 10
\end{bmatrix}.
```

This is the full concrete smoke fixture for `SIM_JORDAN`. The matching [`sim_jordan.m`](../../../../examples/tiered/neig-tier-s/sim_jordan.m) selects the same manifest case and hands this input to the public `eig` path; the displayed matrix is not solver output.

The entries are exact integers or dyadic rationals. If a common factor such as `2^{-q}` appears before the bracket, it multiplies every bracket entry and is part of the exact matrix, not a decimal approximation. Fixed-generation cases retain the declared generator precision in their model object; any separate exact widening and solver/work precision remain distinct recorded quantities.

The smoke configuration is the small, inspectable documentation and CI instance. Its matching demo is a separate manifest row that may change the dimension, parameter, or profile; it is not substituted for this input when interpreting the measured result. This separation keeps the source matrix, source precision, and solver output auditable.

## Why this problem is numerically difficult

The Jordan block is the explicit counterexample to the idea that a full eigenbasis always exists. Near a defective matrix, computed eigenvalues can split and computed vectors can become extremely sensitive; at the exact model, requiring two independent eigenvectors is mathematically impossible. The correct numerical object is the invariant two-dimensional subspace and, when requested, a block Schur factor. The example is also a guard against calling a nontrivial projector certificate a proof of diagonalizability.

The matrix is never replaced by a different representation merely because a related control has a convenient spectrum. Exact model facts, generated-input facts, and measured solver output are kept in separate records.

## What the Octave example computes

The matching [sim_jordan.m](../../../../examples/tiered/neig-tier-s/sim_jordan.m) runs eig(A) only as an ordinary measured output, while the case metadata records that no full diagonalizing basis target applies. It checks the root count, the dimension of the target invariant subspace, the nilpotency order of the shifted block, and the residual of the selected invariant basis. If a Schur-style diagnostic is present, the leading two-by-two block is interpreted as one block, not as two certified simple roots.

The example reports the selected case ID, profile, dimensions, input/model identity, and measured rows. Run it from a loaded mplapack-interop package; the package's mp values remain MPFR/MPC values throughout the numerical path.

## Construction and exactness

The exact checks are $XY=YX=I$, $XA=JX$, $AY=YJ$, $(J-I)^2=0$ on the leading block, and $(J-I)\ne0$. A characteristic polynomial check confirms $(z-1)^2$, but that check alone does not establish the geometric multiplicity; the rank of $J-I$ supplies the latter. The dense certificate does not pretend to certify a Jordan chain from a rounded eig output.

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

The input model is exact dyadic; work precision controls the measured dense solve. Mathematical defectiveness remains at every precision. More bits can make the invariant-subspace and generalized-vector residual smaller, but no number of bits creates a second exact eigenvector. The distinction between arithmetic error and nonexistence of a full eigenbasis is the point of the case.

Three precision roles must be distinguished. **Input/source precision** describes the stored model and any fixed generator rounding. **Arithmetic/work precision** is the one-operation MPFR/MPC precision used to construct, factor, and inspect that stored value. **Mathematical conditioning** describes sensitivity of the problem and is not repaired merely by printing more digits. The runner also tests low/high ambient defaults and restoration so an unrelated caller setting cannot silently choose the operation precision. No builtin binary64 complex fallback is part of this example.

## Reading the output

A small $r_{\mathrm{eig}}$ for two columns does not mean those columns form a diagonalization. The relevant output is a block residual $A V_J-V_JT_J$, where $T_J$ is allowed to be a nontrivial $2$-by-$2$ triangular/block factor, and a rank/subspace check. A solver may split the repeated root in its scalar $D$ output; that is a diagnostic of representation sensitivity, not a change in the exact model.

A PASS line means the declared case-level gates passed; it does not erase the limitations stated above. Compare rows only within the same model identity and profile. If an exactness, coverage, cluster, or precision-contract field is missing, the honest status is incomplete rather than inferred from a pretty display.

## Common mistakes

Never claim the Jordan block is diagonalizable, never certify two independent eigenvectors merely because two scalar roots were returned, and never use a disk count as an exact multiplicity proof. Do not replace the block with diag(1,1).

A useful debugging sequence is: verify the case ID and parameters; verify the serialized input/model hash; inspect the input precision and ambient precision; inspect the residual; then inspect the conditioning-appropriate forward or subspace metric. Do not change parameters after seeing a failure and call the changed run the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Siegfried M. Rump, “Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix.” *SIAM Journal on Matrix Analysis and Applications* 43(4) (2022), 1736–1754. DOI: [10.1137/21M1451440](https://doi.org/10.1137/21M1451440)](https://doi.org/10.1137/21M1451440) — The all-spectrum and Jordan-similarity setting motivates the counted spectrum and subspace warnings; this example remains an independent dense-eigensolver demonstration.
- [Siegfried M. Rump, “Computational error bounds for multiple or nearly multiple eigenvalues.” *Linear Algebra and its Applications* 324(1–3) (2001), 209–226. DOI: [10.1016/S0024-3795(00)00279-2](https://doi.org/10.1016/S0024-3795(00)00279-2)](https://doi.org/10.1016/S0024-3795(00)00279-2) — It is the external reference for treating clusters and defective invariant subspaces rather than individual vectors.

The references motivate the mathematical phenomenon and attribution boundary. The fixed dimensions, dyadic parameters, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated otherwise.

## Project provenance

- Runnable case: [sim_jordan.m](../../../../examples/tiered/neig-tier-s/sim_jordan.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification jobs and conservative certificate scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
