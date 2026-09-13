# Dense similarity with a semisimple repeated root (Tier S2)

## Quick idea

SIM_REPEAT isolates one mathematical reason a dense nonsymmetric eigensystem can be misleading: Read the root count and the subspace metric together. The case is intentionally small enough to inspect and is paired with a deterministic runner. Its tier is a statement about pedagogical difficulty and verification depth, not a claim that the public eig routine implements the cited paper's algorithm.

## Mathematical problem

Smoke: n=8 and demo: n=16. The leading block is I_2, so lambda=1 has algebraic and geometric multiplicity 2.

With the same exact triangular inverse pair $X=LU$ and $Y=X^{-1}$ used by the neighboring similarity cases, set
$$
J_{\mathrm{repeat}}=I_2\oplus\operatorname{diag}(4,5,\ldots,n),\qquad
A=YJ_{\mathrm{repeat}}X.
$$
The eigenvalue 1 has algebraic multiplicity two and geometric multiplicity two. Its invariant right subspace is $\mathcal{R}(Y_{:,1:2})$, while the corresponding left subspace is represented by the columns of $X^{\mathsf T}$ selected by the same coordinates.

## Why this problem is numerically difficult

A repeated eigenvalue does not identify two individual eigenvectors. Any nonsingular change of basis inside the two-dimensional eigenspace is equally valid, so entrywise comparison with the model columns would reject correct results. The dense similarity hides the repeated subspace and gives the eigensolver freedom to return a different basis. The difficult numerical claim is therefore a cluster or subspace statement. A residual for a single computed vector is necessary but cannot certify that the whole two-dimensional eigenspace has been captured.

The matrix is never replaced by a different representation merely because a related control has a convenient spectrum. Exact model facts, generated-input facts, and measured solver output are kept in separate records.

## What the Octave example computes

The matching [sim_repeat.m](../../../../examples/tiered/neig-tier-s/sim_repeat.m) runs the public eig call and compares the matched lambda=1 cluster as a two-dimensional invariant subspace. It records the algebraic/geometric model multiplicities, projector or basis-angle diagnostics, and the ordinary all-spectrum residual. It also runs the neighboring distinct and Jordan fixtures so that the report cannot silently reinterpret a repeated case as either simple or defective.

The example reports the selected case ID, profile, dimensions, input/model identity, and measured rows. Run it from a loaded mplapack-interop package; the package's mp values remain MPFR/MPC values throughout the numerical path.

## Construction and exactness

Exact verification checks XY=YX=I, the intertwining equations, the characteristic polynomial (z-1)^2 product from 4 through n, and the rank of the model eigenspace. The nontrivial cluster certificate uses the range of the selected Y columns; the oblique spectral projector Y(:,1:2)X(1:2,:) is recorded separately from an orthogonal projector. The proof does not rely on two high-precision runs agreeing.

The construction audit is intentionally independent of eig: it checks algebraic identities, dyadic serialization, and declared generation guards before using a solver result. A cross-precision match is useful evidence, but it is not an exactness proof.

## Diagnostics

For a computed $A\in\mathbb{C}^{n\times n}$, right vectors $V$, diagonal or block output $D$, and left vectors $W$, the primary residuals are
$$
r_{\mathrm{eig}}=
\frac{\lVert AV-VD\rVert_F}{\lVert A\rVert_F\lVert V\rVert_F},
\qquad
r_{\mathrm{left}}=
\frac{\lVert A^{\mathsf H}W-WD^{\mathsf H}\rVert_F}
{\lVert A\rVert_F\lVert W\rVert_F}.
$$
For a selected cluster $J$, use $A V_J-V_JD_J$ and a range/projector or principal-angle comparison; do not turn a repeated or defective cluster into an individual-vector claim.

Also inspect the normwise backward indicator against the correct input, the forward bottleneck against the exact/realized reference, and the left/right or subspace diagnostic appropriate to this case. Keep MP values until the final display. A residual is not a certificate that every eigenvalue digit is forward correct.

## Backward error versus forward error

The residual (r_{\mathrm{eig}}) measures how nearly the returned factors satisfy an eigen-equation. It can be interpreted as a small backward perturbation of the matrix under suitable normalization, but the corresponding forward eigenvalue error is multiplied by eigenvalue and eigenvector conditioning. In a cluster, the forward object is an invariant subspace. In a defective case, a full diagonalizing basis does not exist. The report therefore never promotes a small residual to a universal accuracy claim.

## What arbitrary precision changes

The model is exact at the construction precision; later MP work/reference precision controls the dense eig and subspace products. Mathematical multiplicity is exact and does not become simple when mpbits increases. Higher precision should reduce residuals and stabilize the cluster representation, but it cannot select a unique basis. Ambient precision tests verify that operation precision comes from the stored inputs rather than a caller’s unrelated default.

Three precision roles must be distinguished. **Input/source precision** describes the stored model and any fixed generator rounding. **Arithmetic/work precision** is the one-operation MPFR/MPC precision used to construct, factor, and inspect that stored value. **Mathematical conditioning** describes sensitivity of the problem and is not repaired merely by printing more digits. The runner also tests low/high ambient defaults and restoration so an unrelated caller setting cannot silently choose the operation precision. No builtin binary64 complex fallback is part of this example.

## Reading the output

Read the root count and the subspace metric together. A correct result may list two nearly identical lambda values with two arbitrary vectors. The meaningful residual is r_eig for the block A V_J-V_JD_J, plus a principal-angle or projector comparison for the entire range. There is no unique first and second eigenvector at lambda=1, and no forward error for an individual basis direction is canonical.

A PASS line means the declared case-level gates passed; it does not erase the limitations stated above. Compare rows only within the same model identity and profile. If an exactness, coverage, cluster, or precision-contract field is missing, the honest status is incomplete rather than inferred from a pretty display.

## Common mistakes

Do not match individual vectors by entry, claim a repeated root is defective, use an isolated-simple-root bound, or call the oblique spectral projector an orthogonal projector. Do not infer multiplicity solely from a numerical disk count.

A useful debugging sequence is: verify the case ID and parameters; verify the serialized input/model hash; inspect the input precision and ambient precision; inspect the residual; then inspect the conditioning-appropriate forward or subspace metric. Do not change parameters after seeing a failure and call the changed run the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Siegfried M. Rump, “Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix.” *SIAM Journal on Matrix Analysis and Applications* 43(4) (2022), 1736–1754. DOI: [10.1137/21M1451440](https://doi.org/10.1137/21M1451440)](https://doi.org/10.1137/21M1451440) — The all-spectrum and Jordan-similarity setting motivates the counted spectrum and subspace warnings; this example remains an independent dense-eigensolver demonstration.
- [Siegfried M. Rump, “Computational error bounds for multiple or nearly multiple eigenvalues.” *Linear Algebra and its Applications* 324(1–3) (2001), 209–226. DOI: [10.1016/S0024-3795(00)00279-2](https://doi.org/10.1016/S0024-3795(00)00279-2)](https://doi.org/10.1016/S0024-3795(00)00279-2) — It is the external reference for treating clusters and defective invariant subspaces rather than individual vectors.

The references motivate the mathematical phenomenon and attribution boundary. The fixed dimensions, dyadic parameters, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated otherwise.

## Project provenance

- Runnable case: [sim_repeat.m](../../../../examples/tiered/neig-tier-s/sim_repeat.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification jobs and conservative certificate scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
