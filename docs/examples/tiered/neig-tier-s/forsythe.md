# Forsythe cyclic perturbation of a Jordan block (Tier S4)

## Quick idea

FORSYTHE isolates one mathematical reason a dense nonsymmetric eigensystem can be misleading: Inspect the scaled circle error, not ordinary relative error near lambda=1. The case is intentionally small enough to inspect and is paired with a deterministic runner. Its tier is a statement about pedagogical difficulty and verification depth, not a claim that the public eig routine implements the cited paper's algorithm.

## Mathematical problem

Smoke: n=8, a=4, r=2^-a and epsilon=r^n. Demo: n=16, a=12. The original matrix has a tiny lower-left corner.

Let $N$ be the first-superdiagonal shift, $r=2^{-a}$, and $\varepsilon=r^n$. The original matrix is

```math
F=I+N+\varepsilon e_ne_1^{\mathsf T}.
```

Writing $P=N+e_ne_1^{\mathsf T}$, the exact scaled control is $F_{\mathrm{scaled}}=I+rP$, and with $D=\operatorname{diag}(1,r,\ldots,r^{n-1})$,

```math
FD=D F_{\mathrm{scaled}}.
```

The roots are the circle

```math
\lambda_k=1+r\exp(2\pi i k/n),\qquad k=0,\ldots,n-1.
```

## Why this problem is numerically difficult

The perturbation closes a nilpotent chain with a value as small as r^n. In native arithmetic the corner can be lost while the superdiagonal remains visible, turning a simple-root cyclic matrix into the zero-limit Jordan block. In the exact model the roots are distinct, but their eigenvectors inherit strong scaling from the original coordinates. The scaled control is normal and has the same roots, so it provides a representation control rather than a replacement for the original test.

The matrix is never replaced by a different representation merely because a related control has a convenient spectrum. Exact model facts, generated-input facts, and measured solver output are kept in separate records.

## What the Octave example computes

The matching [forsythe.m](../../../../examples/tiered/neig-tier-s/forsythe.m) constructs F directly, constructs the scaled control separately, evaluates the unit-circle roots in MP, and runs public eig on the original matrix. It sets exact real endpoints such as the k=0 root where appropriate and matches (lambda-1)/r against the unit-circle reference. Native underflow, if encountered only in stress, is logged as an altered input.

The example reports the selected case ID, profile, dimensions, input/model identity, and measured rows. Run it from a loaded mplapack-interop package; the package's mp values remain MPFR/MPC values throughout the numerical path.

## Construction and exactness

The model audit checks the cyclic identity F D=D F_scaled, P^n=I, the characteristic relation (lambda-1)^n=r^n, and the dyadic corner. It does not infer the roots from measured eig output. The circle reference is evaluated at MP precision and is not an interval proof for transcendental values; exact endpoints are inserted explicitly.

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

Input/source precision includes epsilon=r^n; work precision must retain the corner and the circle displacement. Mathematical sensitivity is governed by the near-Jordan limit and coordinate scaling. More bits can preserve epsilon and resolve the circle, but it cannot retroactively repair a native F whose corner underflowed. The exact model and any changed native model are never conflated.

Three precision roles must be distinguished. **Input/source precision** describes the stored model and any fixed generator rounding. **Arithmetic/work precision** is the one-operation MPFR/MPC precision used to construct, factor, and inspect that stored value. **Mathematical conditioning** describes sensitivity of the problem and is not repaired merely by printing more digits. The runner also tests low/high ambient defaults and restoration so an unrelated caller setting cannot silently choose the operation precision. No builtin binary64 complex fallback is part of this example.

## Reading the output

Inspect the scaled circle error, not ordinary relative error near lambda=1. A measured result close to 1 can have a large relative error if the small displacement is lost, so the normalized circle coordinate is informative. Compare original and scaled residuals separately. The eig residual can remain small for the wrong limiting matrix when epsilon has disappeared.

A PASS line means the declared case-level gates passed; it does not erase the limitations stated above. Compare rows only within the same model identity and profile. If an exactness, coverage, cluster, or precision-contract field is missing, the honest status is incomplete rather than inferred from a pretty display.

## Common mistakes

Do not compare lambda directly with 1 using only relative error, call the original F normal, use the scaled control as the original input, or treat an underflowed native corner as an MP failure. Do not apply a simple-root claim to FORSYTHE_ZERO.

A useful debugging sequence is: verify the case ID and parameters; verify the serialized input/model hash; inspect the input precision and ambient precision; inspect the residual; then inspect the conditioning-appropriate forward or subspace metric. Do not change parameters after seeing a failure and call the changed run the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Siegfried M. Rump, “Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix.” *SIAM Journal on Matrix Analysis and Applications* 43(4) (2022), 1736–1754. DOI: [10.1137/21M1451440](https://doi.org/10.1137/21M1451440)](https://doi.org/10.1137/21M1451440) — The all-spectrum and Jordan-similarity setting motivates the counted spectrum and subspace warnings; this example remains an independent dense-eigensolver demonstration.
- [Nicholas J. Higham, *Accuracy and Stability of Numerical Algorithms*, 2nd ed. SIAM (2002). DOI: [10.1137/1.9780898718027](https://doi.org/10.1137/1.9780898718027)](https://doi.org/10.1137/1.9780898718027) — The general backward/forward-error vocabulary and nonnormal sensitivity interpretation used here.

The references motivate the mathematical phenomenon and attribution boundary. The fixed dimensions, dyadic parameters, acceptance thresholds, and executable implementation are project-specific adaptations unless explicitly stated otherwise.

## Project provenance

- Runnable case: [forsythe.m](../../../../examples/tiered/neig-tier-s/forsythe.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification jobs and conservative certificate scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- The detailed page explains the model; the family runner remains the measurement authority.
