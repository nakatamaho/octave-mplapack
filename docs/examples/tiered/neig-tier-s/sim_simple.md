# Dense similarity with a simple near-collision (Tier S2)

## Quick idea

SIM_SIMPLE isolates one mathematical reason a dense nonsymmetric eigensystem
can be misleading: for each matched root, read the eigen residual together
with its distance to the exact spectrum
$\{1,1+d,4,5,\ldots,n\}$. The case is intentionally small enough to inspect
and is paired with a deterministic runner. Its tier is a statement about
pedagogical difficulty and verification depth, not a claim that the public
eigensolver routine implements the cited paper's algorithm.

## Mathematical problem

Smoke: $n=8$ and gap $d=2^{-24}$. Demo: $n=16$ and gap $d=2^{-80}$. The
leading block is simple and diagonalizable.

Let $N$ be the first-superdiagonal shift, $L=I+N^{\mathsf T}$, $U=I+N$, $X=LU$, $Y=U^{-1}L^{-1}$, and

```math
J_{\mathrm{simple}}=
\begin{bmatrix}1&1\\0&1+d\end{bmatrix}\oplus\operatorname{diag}(4,5,\ldots,n),
\qquad d=2^{-a}.
```

The dense test matrix is

```math
A=YJ_{\mathrm{simple}}X,\qquad X A=J_{\mathrm{simple}}X,\quad A Y=YJ_{\mathrm{simple}}.
```

Its spectrum is simple, but the first two roots are only d apart and the leading block has a large off-diagonal relative to that gap.

## Why this problem is numerically difficult

The case is diagonalizable, so it is a legitimate individual-eigenpair experiment, but it is close to the defective limit. The coordinate columns of Y are not the eigenvectors of the leading triangular block: the second coordinate eigenvector must solve a 2-by-2 triangular equation. This distinction matters in a dense similarity because a visually plausible column can have a large residual. The small gap makes forward eigenvalue error sensitive even if a backward perturbation is small. It also creates a natural balance-control question without changing the exact model.

The matrix is never replaced by a different representation merely because a related control has a convenient spectrum. Exact model facts, generated-input facts, and measured solver output are kept in separate records.

## What the Octave example computes

The matching [sim_simple.m](../../../../examples/tiered/neig-tier-s/sim_simple.m) constructs the exact dyadic model through the finite triangular inverse, runs the public eig interface, and matches the two close roots bijectively. It checks the intertwining identities and the independently formed characteristic polynomial for the leading block. The selected gap and profile are read from cases.json; they are not altered to fit an observed answer.

The example reports the selected case ID, profile, dimensions, input/model identity, and measured rows. Run it from a loaded mplapack-interop package; the package's mp values remain MPFR/MPC values throughout the numerical path.

## Construction and exactness

The model is exact because X and Y are finite nilpotent series with dyadic/integer entries and the product guard is recorded. The checker independently confirms X A=JX and A Y=YJ, then checks the two-by-two characteristic factor (z-1)(z-1-d). It does not use the solver’s eigenvalues to construct J or to prove simplicity. The simple model is separate from SIM_REPEAT and SIM_JORDAN even when d is small.

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

Input/source precision is the exact dyadic construction; work precision is chosen by the smoke/demo profile, with higher reference rows. The arithmetic precision must be high enough to retain d and to evaluate the dense similarity. Mathematical conditioning worsens as a grows and as the leading block approaches a Jordan block. More mpbits reduces rounding in the computed solve but does not change the prescribed gap or turn the model into a repeated root.

Three precision roles must be distinguished. **Input/source precision** describes the stored model and any fixed generator rounding. **Arithmetic/work precision** is the one-operation MPFR/MPC precision used to construct, factor, and inspect that stored value. **Mathematical conditioning** describes sensitivity of the problem and is not repaired merely by printing more digits. The runner also tests low/high ambient defaults and restoration so an unrelated caller setting cannot silently choose the operation precision. No builtin binary64 complex fallback is part of this example.

## Reading the output

For each matched root, read the eigen residual and the distance to
$\{1,1+d,4,5,\ldots,n\}$. The eigensolver may return accurate backward
solutions whose forward root error is a visible fraction of $d$. The balance
row can have different componentwise behavior; a pass does not require
balancing to improve every row. The eigenvectors are only comparable up to
independent scaling, and left vectors use the adjoint equation.

A PASS line means the declared case-level gates passed; it does not erase the limitations stated above. Compare rows only within the same model identity and profile. If an exactness, coverage, cluster, or precision-contract field is missing, the honest status is incomplete rather than inferred from a pretty display.

## Common mistakes

Do not call the matrix defective, claim that Y(:,2) is automatically an eigenvector, merge the two roots merely because their disks overlap at low precision, or treat balance as a required improvement. Do not use a disk count to infer exact multiplicity.

A useful debugging sequence is: verify the case ID and parameters; verify the serialized input/model hash; inspect the input precision and ambient precision; inspect the residual; then inspect the conditioning-appropriate forward or subspace metric. Do not change parameters after seeing a failure and call the changed run the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Siegfried M. Rump, “Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix.” *SIAM Journal on Matrix Analysis and Applications* 43(4) (2022), 1736–1754. DOI: [10.1137/21M1451440](https://doi.org/10.1137/21M1451440)](https://doi.org/10.1137/21M1451440) — The all-spectrum and Jordan-similarity setting motivates the counted spectrum and subspace warnings; this example remains an independent dense-eigensolver demonstration.
- [Siegfried M. Rump, “Computational error bounds for multiple or nearly multiple eigenvalues.” *Linear Algebra and its Applications* 324(1–3) (2001), 209–226. DOI: [10.1016/S0024-3795(00)00279-2](https://doi.org/10.1016/S0024-3795(00)00279-2)](https://doi.org/10.1016/S0024-3795(00)00279-2) — It is the external reference for treating clusters and defective invariant subspaces rather than individual vectors.

The references motivate the mathematical phenomenon and attribution boundary. The fixed dimensions, dyadic parameters, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated otherwise.

## Project provenance

- Runnable case: [sim_simple.m](../../../../examples/tiered/neig-tier-s/sim_simple.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification jobs and conservative certificate scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
