# Nilpotent shift plus rank-one perturbation (Tier A5)

## Quick idea

MKS is a Tier A control. The matrix combines a large defective zero part with a small nonzero-root problem. It is small, deterministic, and intended to be read with its one-case Octave runner. Tier A identifies an advanced example; it does not claim that the public eig routine implements the cited paper's specialized algorithm.

## Mathematical problem

Smoke: $n=12$, $m=3$, $\delta=1/8$, $\ell=4$. Demo: $n=32$, $m=3$,
$\delta=1/8$, $\ell=11$.

```math
A=N^m+\delta\mathbf{1}\mathbf{1}^{\mathsf T},
\qquad \det(zI-A)=z^{n-\ell}q(z),
\qquad q(z)=z^\ell-\delta\sum_{j=0}^{\ell-1}(n-mj)z^{\ell-1-j}.
```

The nonzero constant term of $q$ proves exact algebraic zero multiplicity
$n-\ell$.

## Why this problem is numerically difficult

The matrix combines a large defective zero part with a small nonzero-root problem. A rational formula with division by $z$ can be singular at the point the test needs, so the polynomial identity is the safe model. In the $m=3$ cases the zero part is defective: algebraic multiplicity and geometric multiplicity differ. Measured eig output must not be repaired by appending known zeros.

The exact model, any transformed control, and measured solver output remain separate. A related matrix with a convenient analytic answer is never silently substituted for the matrix named by the case ID.

## What the Octave example computes

The matching [mks.m](../../../../examples/tiered/neig-tier-a/mks.m) selects only MKS from the fixed manifest and calls the public eig interface. The matching mks.m constructs A, runs public eig, and compares nonzero roots with an independently built small companion for q at reference precision. It counts the full measured spectrum, reports the exact zero multiplicity, and checks invariant-subspace dimensions. Exact zeros are part of the reference record only; measured output is untouched. The runner records the case ID, profile, dimensions, input identity, and operation precision, and keeps MP values until presentation.

## Construction and exactness

The audit verifies $N^m$, the dyadic rank-one term, $q$ coefficients, and small-$n$ determinant identities. $q$ is solved independently at two MP precisions. A rank calculation distinguishes algebraic multiplicity from geometric nullspace dimension. No exact multiplicity is inferred from a disk count.

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

Input is exact dyadic. Arithmetic precision controls the dense construction, eig, and small q reference. Mathematical difficulty is dominated by the defective zero cluster and scale separation. More bits improve separation but do not make the zero block diagonalizable.

Input/source precision is the precision and exactness of the stored model. Arithmetic/work precision is the MPFR/MPC precision selected for this operation. Mathematical conditioning is a property of the model. Raising mpbits addresses the second item only; it does not restore bits lost in a separately rounded input or alter a defective structure. Ambient-precision and restoration rows protect this distinction.

## Reading the output

Read zero count, nonzero-root matching, and invariant-subspace fields separately. A small residual for a near-zero vector is not a proof of exact multiplicity. The reduced companion is a reference computation, not the dense algorithm. Merged roots are reported as a cluster.

A PASS line is scoped to the declared case gates and profile. Compare only rows with the same parameters and model hash. If a certificate field is absent, do not infer it from a small residual or a stable display.

## Common mistakes

Do not use a singular rational formula, append known zeros to measured output, claim zero is semisimple, use the reduced companion as the dense solve, or infer $n-\ell$ from a disk count alone.

For diagnosis, verify case ID and dimensions, then model hash and input precision, then residual, then the appropriate forward, cluster, or structural metric. Never change the fixture after observing a failure and report it as the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Saori Morimoto, Makoto Katori, and Tomoyuki Shirai, Eigenvalue and pseudospectrum processes generated by nonnormal Toeplitz matrices with rank 1 perturbations. International Journal of Mathematics for Industry 17(1) (2025), 2550013. DOI: 10.1142/S2661335225500133](https://doi.org/10.1142/S2661335225500133) — Model 1 motivates the nilpotent-shift plus rank-one determinant identity.
- [Siegfried M. Rump, Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix. SIAM Journal on Matrix Analysis and Applications 43(4) (2022), 1736–1754. DOI: 10.1137/21M1451440](https://doi.org/10.1137/21M1451440) — The all-spectrum and rigorous eigensystem context; these are independent dense controls.

These references establish the external mathematical context. The selected dimensions, dyadic constants, runner, and acceptance thresholds are explicit project adaptations unless this page states otherwise.

## Project provenance

- Runnable case: [mks.m](../../../../examples/tiered/neig-tier-a/mks.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- This page explains the named model; the family runner and milestone logs remain the measurement authority.
