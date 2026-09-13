# Grcar nonnormal band matrix (Tier A4)

## Quick idea

GRCAR is a Tier A control. Grcar shows that an eigenvalue list does not describe a nonnormal matrix. It is small, deterministic, and intended to be read with its one-case Octave runner. Tier A identifies an advanced example; it does not claim that the public eig routine implements the cited paper's specialized algorithm.

## Mathematical problem

Smoke: n=12 and upper bandwidth 3. Demo: n=24 and upper bandwidth 3. Entries are exactly 0, +1, or -1.

$$
Gij = 1  if 0 <= j-i <= 3;    Gij = -1 if i-j=1;    Gij=0 otherwise.
$$
The unstructured complex 2-norm pseudospectrum is Lambda_epsilon(G) = {z : sigma_min(z I - G) <= epsilon}.

## Why this problem is numerically difficult

Grcar shows that an eigenvalue list does not describe a nonnormal matrix. Small perturbations can move eigenvalues far from the computed spectrum, and an individual residual does not certify a pseudospectral boundary. The exact ±1 input is easy to audit, but there is no claimed analytic spectrum; the reference uses independent MP eig and shifted singular-value probes.

The exact model, any transformed control, and measured solver output remain separate. A related matrix with a convenient analytic answer is never silently substituted for the matrix named by the case ID.

## What the Octave example computes

The matching [grcar.m](../../../../examples/tiered/neig-tier-a/grcar.m) selects only GRCAR from the fixed manifest and calls the public eig interface. The matching grcar.m builds the exact band pattern, measures eig at selected precisions, and probes complex shifts through the public singular-value path. It reports r_eig, shift singular values, and an explicit closed-set inside/outside convention. Optional plots are presentation only and never a certificate. The runner records the case ID, profile, dimensions, input identity, and operation precision, and keeps MP values until presentation.

## Construction and exactness

The constructor checks every index rule and nonzero count. A verified point or positive-area cell is accepted only when an outward-safe bound supports its classification. Two MP reference runs are independent measurements, not an analytic oracle. A binary64 contour plot is not a proof.

Exactness means that declared integer/dyadic identities and their bit guards have been checked independently. Agreement between two MP runs is useful evidence but is not an exactness proof.

## Diagnostics

For A in C^(n x n), right vectors V, output D, and left vectors W, use
$$
r_{\mathrm{eig}} = ||A V - V D||_F / (||A||_F ||V||_F),
\qquad r_{\mathrm{left}} = ||A^H W - W D^H||_F / (||A||_F ||W||_F).
$$
For a selected cluster J, use the block residual A V_J - V_J D_J and compare ranges or projectors; never turn a repeated or defective cluster into an individual-vector claim.

Also inspect the case-specific forward reference, the normwise backward indicator, and any positivity, polynomial, similarity, or pseudospectrum diagnostic. A residual alone does not establish forward accuracy of every eigenvalue or vector component.

## Backward error versus forward error

The eigen residual measures the equation defect and can support a backward-error interpretation after normalization. Forward eigenvalue error additionally depends on spectral separation and left/right eigenvector conditioning. For repeated or defective objects, the forward target is an invariant subspace or block relation. For a polynomial companion, coefficientwise backward error is a different perturbation model. The report keeps these meanings distinct.

## What arbitrary precision changes

The input is exact 0/±1 data. Arithmetic precision controls eig, shifted solves/SVD, and outward diagnostic widths. Mathematical nonnormal sensitivity remains after arithmetic error is reduced. More bits narrow a verified bound but do not shrink the true pseudospectrum.

Input/source precision is the precision and exactness of the stored model. Arithmetic/work precision is the MPFR/MPC precision selected for this operation. Mathematical conditioning is a property of the model. Raising mpbits addresses the second item only; it does not restore bits lost in a separately rounded input or alter a defective structure. Ambient-precision and restoration rows protect this distinction.

## Reading the output

A point with small sigma_min(z I-G) is near the closed pseudospectrum; it is not necessarily an eigenvalue. Read eigen residuals and shift singular values separately. Precision-dependent contours can reflect arithmetic or unresolved boundary geometry. No balancing improvement is required.

A PASS line is scoped to the declared case gates and profile. Compare only rows with the same parameters and model hash. If a certificate field is absent, do not infer it from a small residual or a stable display.

## Common mistakes

Do not claim an analytic spectrum, equate a residual contour with a proof, call a structured metric the unstructured pseudospectrum, or use plotting samples as measured MP output.

For diagnosis, verify case ID and dimensions, then model hash and input precision, then residual, then the appropriate forward, cluster, or structural metric. Never change the fixture after observing a failure and report it as the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Siegfried M. Rump, Eigenvalues, pseudospectrum and structured perturbations. Linear Algebra and its Applications 413(2–3) (2006), 567–593. DOI: 10.1016/j.laa.2005.06.009](https://doi.org/10.1016/j.laa.2005.06.009) — Separates unrestricted and structured perturbations.
- [Siegfried M. Rump, Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix. SIAM Journal on Matrix Analysis and Applications 43(4) (2022), 1736–1754. DOI: 10.1137/21M1451440](https://doi.org/10.1137/21M1451440) — The all-spectrum and rigorous eigensystem context; these are independent dense controls.

These references establish the external mathematical context. The selected dimensions, dyadic constants, runner, and acceptance thresholds are explicit project adaptations unless this page states otherwise.

## Project provenance

- Runnable case: [grcar.m](../../../../examples/tiered/neig-tier-a/grcar.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- This page explains the named model; the family runner and milestone logs remain the measurement authority.
