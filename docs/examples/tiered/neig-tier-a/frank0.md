# Frank matrix, orientation 0 (Tier A2)

## Quick idea

FRANK0 is a Tier A control. Frank matrices are integer and structured, but small positive eigenvalues and reciprocal pairing make relative accuracy important. It is small, deterministic, and intended to be read with its one-case Octave runner. Tier A identifies an advanced example; it does not claim that the public eig routine implements the cited paper's specialized algorithm.

## Mathematical problem

Smoke: $n=8$. Demo: $n=24$. The matrix is an exact integer upper-Hessenberg
Frank orientation.

```math
(F_0)_{ij}=
\begin{cases}
n+1-\max(i,j), & j\ge i-1,\\
0, & j<i-1.
\end{cases}
```

An independent symmetric Jacobi reference has off-diagonal entries
$\sqrt{j}$. Its eigenvalue $z$ is mapped stably to $f(z)$ by

```math
f(z)=
\begin{cases}
\left(\frac{z+\sqrt{z^2+4}}{2}\right)^2, & z\ge0,\\
\left(\frac{2}{\sqrt{z^2+4}-z}\right)^2, & z<0.
\end{cases}
```

## Why this problem is numerically difficult

Frank matrices are integer and structured, but small positive eigenvalues and reciprocal pairing make relative accuracy important. The orientation convention is part of the case: a reflected gallery matrix with a different flag is not silently substituted. The Jacobi map provides an independent reference and a cancellation-safe formula for the small branch.

The exact model, any transformed control, and measured solver output remain separate. A related matrix with a convenient analytic answer is never silently substituted for the matrix named by the case ID.

## What the Octave example computes

The matching [frank0.m](../../../../examples/tiered/neig-tier-a/frank0.m) selects only FRANK0 from the fixed manifest and calls the public `eig` interface. The matching `frank0.m` builds $F_0$ from the explicit index rule, runs public `eig`, and compares sorted roots with the MP Jacobi-derived reference. It checks positivity, reciprocal pairing, the odd-order central root when applicable, and absolute and relative bottlenecks. FRANK1 is a separate orientation control, not a second arbitrary spectrum. The runner records the case ID, profile, dimensions, input identity, and operation precision, and keeps MP values until presentation.

## Construction and exactness

The constructor checks the integer Hessenberg pattern. The Jacobi reference uses MP square roots and the branch-stable map above. Small characteristic polynomials are checked by an independent recurrence for $n=2$ through $5$. The reference is never formed from measured roots.

Exactness means that declared integer/dyadic identities and their bit guards have been checked independently. Agreement between two MP runs is useful evidence but is not an exactness proof.

## Diagnostics

For $A\in\mathbb{C}^{n\times n}$, right vectors $V$, output $D$, and left
vectors $W$, use

```math
r_{\mathrm{eig}} = \frac{\lVert A V - V D\rVert_F}{\lVert A\rVert_F\lVert V\rVert_F},
\qquad r_{\mathrm{left}} = \frac{\lVert A^{\mathsf H} W - W D^{\mathsf H}\rVert_F}{\lVert A\rVert_F\lVert W\rVert_F}.
```

For a selected cluster $J$, use the block residual $A V_J-V_JD_J$ and compare
ranges or projectors; never turn a repeated or defective cluster into an
individual-vector claim.

Also inspect the case-specific forward reference, the normwise backward indicator, and any positivity, polynomial, similarity, or pseudospectrum diagnostic. A residual alone does not establish forward accuracy of every eigenvalue or vector component.

## Backward error versus forward error

The eigen residual measures the equation defect and can support a backward-error interpretation after normalization. Forward eigenvalue error additionally depends on spectral separation and left/right eigenvector conditioning. For repeated or defective objects, the forward target is an invariant subspace or block relation. For a polynomial companion, coefficientwise backward error is a different perturbation model. The report keeps these meanings distinct.

## What arbitrary precision changes

The source is exact integer MP data. Arithmetic precision controls the dense eigensolver and Jacobi reference; mathematical conditioning of small paired roots remains. Raising precision helps only if the exact integer model is preserved.

Input/source precision is the precision and exactness of the stored model. Arithmetic/work precision is the MPFR/MPC precision selected for this operation. Mathematical conditioning is a property of the model. Raising mpbits addresses the second item only; it does not restore bits lost in a separately rounded input or alter a defective structure. Ambient-precision and restoration rows protect this distinction.

## Reading the output

Use relative error for small nonzero roots and absolute error near zero. Reciprocal pairing is a structural check, not an eigenvector certificate. A small $r_{\mathrm{eig}}$ can coexist with a large relative error in a small root. Compare orientation labels before comparing rows.

A PASS line is scoped to the declared case gates and profile. Compare only rows with the same parameters and model hash. If a certificate field is absent, do not infer it from a small residual or a stable display.

## Common mistakes

Do not use a different Frank orientation, use only absolute error, calculate the reference from `eig(F_0)`, evaluate the small branch by cancellation, or infer pairing from a display-only sorted list.

For diagnosis, verify case ID and dimensions, then model hash and input precision, then residual, then the appropriate forward, cluster, or structural metric. Never change the fixture after observing a failure and report it as the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Nicholas J. Higham, Accuracy and Stability of Numerical Algorithms, 2nd ed. SIAM (2002). DOI: 10.1137/1.9780898718027](https://doi.org/10.1137/1.9780898718027) — The backward/forward-error framework and companion/nonnormal conditioning language used here.
- [Siegfried M. Rump, Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix. SIAM Journal on Matrix Analysis and Applications 43(4) (2022), 1736–1754. DOI: 10.1137/21M1451440](https://doi.org/10.1137/21M1451440) — The all-spectrum and rigorous eigensystem context; these are independent dense controls.

These references establish the external mathematical context. The selected dimensions, dyadic constants, runner, and acceptance thresholds are explicit project adaptations unless this page states otherwise.

## Project provenance

- Runnable case: [frank0.m](../../../../examples/tiered/neig-tier-a/frank0.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- This page explains the named model; the family runner and milestone logs remain the measurement authority.
