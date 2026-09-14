# Two nearby defective clusters under one dense similarity (Tier S2)

## Quick idea

SIM_TWO_JORDAN isolates one mathematical reason a dense nonsymmetric eigensystem can be misleading: Read the bottleneck matching, cluster counts, and block residuals as separate fields. The case is intentionally small enough to inspect and is paired with a deterministic runner. Its tier is a statement about pedagogical difficulty and verification depth, not a claim that the public eig routine implements the cited paper's algorithm.

## Mathematical problem

Smoke: $n=8$ and $d=2^{-12}$. Demo: $n=16$ and $d=2^{-40}$. The leading
blocks are $J_2(1)$ and $J_2(1+d)$.

Set

```math
J_{\mathrm{two}}=
\begin{bmatrix}1&1\\0&1\end{bmatrix}
\oplus
\begin{bmatrix}1+d&1\\0&1+d\end{bmatrix}
\oplus\mathrm{diag}(4,5,\ldots,n-1),
\qquad d=2^{-a},
```

and $A=YJ_{\mathrm{two}}X$ with the exact inverse pair $X=LU$, $Y=U^{-1}L^{-1}$. The two clusters each have algebraic multiplicity 2 and geometric multiplicity 1; their union has dimension four.

## Concrete smoke matrix

<!-- smoke-matrix: SIM_TWO_JORDAN -->

```math
A_{\mathrm{smoke}} = 2^{-12} \begin{bmatrix}
36864 & 65542 & 57351 & 98300 & 73723 & -8192 & 8192 & -8192 \\
-28672 & -53254 & -53255 & -98300 & -73723 & 8192 & -8192 & 8192 \\
24576 & 49158 & 53255 & 98300 & 73723 & -8192 & 8192 & -8192 \\
-20480 & -40965 & -40965 & -86011 & -69627 & 8192 & -8192 & 8192 \\
16384 & 32772 & 32772 & 81916 & 69628 & -8192 & 8192 & -8192 \\
-12288 & -24579 & -24579 & -61437 & -36861 & 24576 & -8192 & 8192 \\
8192 & 16386 & 16386 & 40958 & 24574 & 0 & 28672 & -8192 \\
-4096 & -8193 & -8193 & -20479 & -12287 & 0 & 0 & 32768
\end{bmatrix}.
```

This is the full concrete smoke fixture for `SIM_TWO_JORDAN`. The matching [`sim_two_jordan.m`](../../../../examples/tiered/neig-tier-s/sim_two_jordan.m) selects the same manifest case and hands this input to the public `eig` path; the displayed matrix is not solver output.

The entries are exact integers or dyadic rationals. If a common factor such as `2^{-q}` appears before the bracket, it multiplies every bracket entry and is part of the exact matrix, not a decimal approximation. Fixed-generation cases retain the declared generator precision in their model object; any separate exact widening and solver/work precision remain distinct recorded quantities.

The smoke configuration is the small, inspectable documentation and CI instance. Its matching demo is a separate manifest row that may change the dimension, parameter, or profile; it is not substituted for this input when interpreting the measured result. This separation keeps the source matrix, source precision, and solver output auditable.

## Why this problem is numerically difficult

This case makes cluster selection itself part of the problem. At high enough precision the two defective blocks are separated, but a lower-precision inclusion region can merge them. A simple-root solver diagnostic is invalid inside either block, while a four-dimensional invariant-subspace statement is valid for the union. The dense similarity also means that the coordinate block basis is not orthogonal, so a naive Euclidean comparison can overstate or understate the actual subspace error.

The matrix is never replaced by a different representation merely because a related control has a convenient spectrum. Exact model facts, generated-input facts, and measured solver output are kept in separate records.

## What the Octave example computes

The matching [sim_two_jordan.m](../../../../examples/tiered/neig-tier-s/sim_two_jordan.m) runs separate two-root clusters and the merged four-root cluster using the fixed gap from the manifest. It checks each block’s generalized relation, the combined invariant range, and all-spectrum coverage. The reported classification says whether the working precision resolved the internal gap; it does not retune d or turn a merged numerical enclosure into an exact multiplicity assertion.

The example reports the selected case ID, profile, dimensions, input/model identity, and measured rows. Run it from a loaded mplapack-interop package; the package's mp values remain MPFR/MPC values throughout the numerical path.

## Construction and exactness

The model proof checks the similarity identities, the two characteristic factors $(z-1)^2$ and $(z-1-d)^2$, the rank-one nilpotent part of each Jordan block, and the direct-sum dimensions. The invariant basis is formed from the relevant columns of $Y$, and the oblique commuting projector for a union of full coordinate blocks is kept distinct from an orthogonal range projector. Exact dyadic construction is checked independently from the eig output.

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

Source precision is the exact dyadic model; the gap is d; arithmetic precision varies by profile. The conditioning has two layers: defectiveness within each cluster and the separation between clusters. More bits can resolve the gap and improve subspace bounds but cannot make either Jordan block semisimple. The ambient-precision wall verifies that these conclusions are not caused by a leaked global default.

Three precision roles must be distinguished. **Input/source precision** describes the stored model and any fixed generator rounding. **Arithmetic/work precision** is the one-operation MPFR/MPC precision used to construct, factor, and inspect that stored value. **Mathematical conditioning** describes sensitivity of the problem and is not repaired merely by printing more digits. The runner also tests low/high ambient defaults and restoration so an unrelated caller setting cannot silently choose the operation precision. No builtin binary64 complex fallback is part of this example.

## Reading the output

Read the bottleneck matching, cluster counts, and block residuals as separate fields. If the two clusters merge numerically, the correct statement is a certificate for the union, not “the roots have multiplicity four.” If they separate, each two-dimensional invariant space is still defective and must not be reduced to two individual eigenvector claims. $r_{\mathrm{eig}}$ is reported for the full matrix and for selected blocks.

A PASS line means the declared case-level gates passed; it does not erase the limitations stated above. Compare rows only within the same model identity and profile. If an exactness, coverage, cluster, or precision-contract field is missing, the honest status is incomplete rather than inferred from a pretty display.

## Common mistakes

Do not count a merged disk as a proof of algebraic multiplicity four, do not treat the block bases as orthogonal, do not demand individual eigenvectors inside a Jordan block, and do not silently replace d by a larger gap when a run is slow.

A useful debugging sequence is: verify the case ID and parameters; verify the serialized input/model hash; inspect the input precision and ambient precision; inspect the residual; then inspect the conditioning-appropriate forward or subspace metric. Do not change parameters after seeing a failure and call the changed run the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Siegfried M. Rump, “Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix.” *SIAM Journal on Matrix Analysis and Applications* 43(4) (2022), 1736–1754. DOI: [10.1137/21M1451440](https://doi.org/10.1137/21M1451440)](https://doi.org/10.1137/21M1451440) — The all-spectrum and Jordan-similarity setting motivates the counted spectrum and subspace warnings; this example remains an independent dense-eigensolver demonstration.
- [Siegfried M. Rump, “Computational error bounds for multiple or nearly multiple eigenvalues.” *Linear Algebra and its Applications* 324(1–3) (2001), 209–226. DOI: [10.1016/S0024-3795(00)00279-2](https://doi.org/10.1016/S0024-3795(00)00279-2)](https://doi.org/10.1016/S0024-3795(00)00279-2) — It is the external reference for treating clusters and defective invariant subspaces rather than individual vectors.

The references motivate the mathematical phenomenon and attribution boundary. The fixed dimensions, dyadic parameters, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated otherwise.

## Project provenance

- Runnable case: [sim_two_jordan.m](../../../../examples/tiered/neig-tier-s/sim_two_jordan.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification jobs and conservative certificate scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
