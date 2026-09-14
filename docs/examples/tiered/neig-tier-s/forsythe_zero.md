# Forsythe zero-limit Jordan block (Tier S4)

## Quick idea

FORSYTHE_ZERO isolates one mathematical reason a dense nonsymmetric eigensystem can be misleading: A small $r_{\mathrm{eig}}$ for a returned diagonal $D$ is not a diagonalizability result. The case is intentionally small enough to inspect and is paired with a deterministic runner. Its tier is a statement about pedagogical difficulty and verification depth, not a claim that the public eig routine implements the cited paper's algorithm.

## Mathematical problem

Smoke: $n=8$, $a=4$ metadata retained. Demo: $n=16$, $a=12$ metadata
retained. The lower-left perturbation is exactly $\varepsilon=0$.

The zero-limit case is the genuine Jordan matrix

```math
F_0=I+N,\qquad N_{i,i+1}=1,\qquad N^n=0,\quad N^{n-1}\ne0.
```

Its only eigenvalue is 1 with algebraic multiplicity n and geometric multiplicity 1. The shifted nilpotent part has exact order n:

```math
(F_0-I)^n=0,\qquad (F_0-I)^{n-1}\ne0.
```

## Why this problem is numerically difficult

This is not a failed version of the nonzero Forsythe test. It is a deliberate boundary case where no full eigenbasis exists and all individual eigenvectors are maximally nonunique in the defective sense. The right success condition is an invariant block or a generalized chain, not n independent vectors. Keeping this case separate prevents a certificate framework from silently converting an exact Jordan block into a diagonal matrix because a numerical eig call printed repeated roots.

The matrix is never replaced by a different representation merely because a related control has a convenient spectrum. Exact model facts, generated-input facts, and measured solver output are kept in separate records.

## What the Octave example computes

The matching [forsythe_zero.m](../../../../examples/tiered/neig-tier-s/forsythe_zero.m) runs public eig as a measured diagnostic, verifies the exact nilpotent order, and checks the full-space invariant relation. It records that individual simple-root and eigenvector-forward-error gates are not applicable. The all-spectrum count is n, but the geometric dimension is one.

The example reports the selected case ID, profile, dimensions, input/model identity, and measured rows. Run it from a loaded mplapack-interop package; the package's mp values remain MPFR/MPC values throughout the numerical path.

## Construction and exactness

The exact constructor uses only I and N. Independent checks evaluate powers of F_0-I, the rank of the first nilpotent power, and the characteristic polynomial (z-1)^n. The whole-space projector I is a trivial identity and is not accepted as a nontrivial cluster certificate. A genuine block relation is required if a V-style invariant-subspace test is run.

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

The source matrix is exact at every reasonable MP precision; the mathematical defectiveness is exact and precision-independent. Raising arithmetic precision improves residual evaluation and generalized-chain diagnostics but cannot create n eigenvectors. This case is therefore a test of semantic honesty as much as arithmetic accuracy.

Three precision roles must be distinguished. **Input/source precision** describes the stored model and any fixed generator rounding. **Arithmetic/work precision** is the one-operation MPFR/MPC precision used to construct, factor, and inspect that stored value. **Mathematical conditioning** describes sensitivity of the problem and is not repaired merely by printing more digits. The runner also tests low/high ambient defaults and restoration so an unrelated caller setting cannot silently choose the operation precision. No builtin binary64 complex fallback is part of this example.

## Reading the output

A small $r_{\mathrm{eig}}$ for a returned diagonal $D$ is not a diagonalizability result. Read the algebraic count, geometric dimension, nilpotency order, and block residual. If native or low-precision output splits the repeated root, that is expected numerical representation behavior. No individual-vector matching target is reported.

A PASS line means the declared case-level gates passed; it does not erase the limitations stated above. Compare rows only within the same model identity and profile. If an exactness, coverage, cluster, or precision-contract field is missing, the honest status is incomplete rather than inferred from a pretty display.

## Common mistakes

Never claim the Jordan block is diagonalizable, never use a scalar root condition number, never infer multiplicity from a disk count, and never substitute the normal scaled control. Do not mark a full-space identity projector as the required nontrivial cluster certificate.

A useful debugging sequence is: verify the case ID and parameters; verify the serialized input/model hash; inspect the input precision and ambient precision; inspect the residual; then inspect the conditioning-appropriate forward or subspace metric. Do not change parameters after seeing a failure and call the changed run the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Siegfried M. Rump, “Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix.” *SIAM Journal on Matrix Analysis and Applications* 43(4) (2022), 1736–1754. DOI: [10.1137/21M1451440](https://doi.org/10.1137/21M1451440)](https://doi.org/10.1137/21M1451440) — The all-spectrum and Jordan-similarity setting motivates the counted spectrum and subspace warnings; this example remains an independent dense-eigensolver demonstration.
- [Siegfried M. Rump, “Computational error bounds for multiple or nearly multiple eigenvalues.” *Linear Algebra and its Applications* 324(1–3) (2001), 209–226. DOI: [10.1016/S0024-3795(00)00279-2](https://doi.org/10.1016/S0024-3795(00)00279-2)](https://doi.org/10.1016/S0024-3795(00)00279-2) — It is the external reference for treating clusters and defective invariant subspaces rather than individual vectors.

The references motivate the mathematical phenomenon and attribution boundary. The fixed dimensions, dyadic parameters, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated otherwise.

## Project provenance

- Runnable case: [forsythe_zero.m](../../../../examples/tiered/neig-tier-s/forsythe_zero.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification jobs and conservative certificate scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
