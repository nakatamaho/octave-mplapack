# Frank matrix, reflected orientation (Tier A2)

## Quick idea

FRANK1 is a Tier A control. It is easy to turn two orientation IDs into aliases by using a library constructor with an unexamined flag. It is small, deterministic, and intended to be read with its one-case Octave runner. Tier A identifies an advanced example; it does not claim that the public eig routine implements the cited paper's specialized algorithm.

## Mathematical problem

Smoke: n=8. Demo: n=24. The matrix is F1 = R F0^T R, with R the reversal permutation.

$$
F1 = R F0^T R,    R^2 = I.
$$
Transpose and permutation similarity preserve the characteristic polynomial, so F1 and F0 have the same eigenvalues while their coordinate vectors and left/right roles differ.

## Why this problem is numerically difficult

It is easy to turn two orientation IDs into aliases by using a library constructor with an unexamined flag. The explicit reflection tests the convention and the dense path. Transposition exchanges right and left eigenvectors and reversal changes their coordinates; an equal spectrum does not imply equal eigenvectors or equal conditioning.

The exact model, any transformed control, and measured solver output remain separate. A related matrix with a convenient analytic answer is never silently substituted for the matrix named by the case ID.

## What the Octave example computes

The matching [frank1.m](../../../../examples/tiered/neig-tier-a/frank1.m) selects only FRANK1 from the fixed manifest and calls the public eig interface. The matching frank1.m constructs F0, R, and F1 in MP, verifies the exact relation, and calls eig on F1. It uses the independent Jacobi reference from FRANK0, but measures F1 residuals and left/right diagnostics independently. It does not reuse F0's measured vectors as an answer. The runner records the case ID, profile, dimensions, input identity, and operation precision, and keeps MP values until presentation.

## Construction and exactness

The exact check verifies R^2 = I, the reflected-transpose identity, the integer Hessenberg pattern, and small characteristic-polynomial identities. Any vector correspondence is tested through the correct transpose/reversal relation only after normalization.

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

Input values are exact integers. Work precision controls F1 construction, eig, and the independent reference. Mathematical sensitivity of the small roots remains even though there are no tiny source entries. More bits separate orientation effects from arithmetic noise.

Input/source precision is the precision and exactness of the stored model. Arithmetic/work precision is the MPFR/MPC precision selected for this operation. Mathematical conditioning is a property of the model. Raising mpbits addresses the second item only; it does not restore bits lost in a separately rounded input or alter a defective structure. Ambient-precision and restoration rows protect this distinction.

## Reading the output

Equal spectra are expected; equal vector entries are not. The left residual uses the adjoint equation A^H W - W D^H. Relative error remains important for small roots. This is a controlled transformation experiment, not evidence that orientation is numerically irrelevant.

A PASS line is scoped to the declared case gates and profile. Compare only rows with the same parameters and model hash. If a certificate field is absent, do not infer it from a small residual or a stable display.

## Common mistakes

Do not compare F1 and F0 without the R/F transpose identity, use a transpose-only left residual, or claim that same eigenvalues imply same right eigenvectors.

For diagnosis, verify case ID and dimensions, then model hash and input precision, then residual, then the appropriate forward, cluster, or structural metric. Never change the fixture after observing a failure and report it as the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Nicholas J. Higham, Accuracy and Stability of Numerical Algorithms, 2nd ed. SIAM (2002). DOI: 10.1137/1.9780898718027](https://doi.org/10.1137/1.9780898718027) — The backward/forward-error framework and companion/nonnormal conditioning language used here.
- [Siegfried M. Rump, Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix. SIAM Journal on Matrix Analysis and Applications 43(4) (2022), 1736–1754. DOI: 10.1137/21M1451440](https://doi.org/10.1137/21M1451440) — The all-spectrum and rigorous eigensystem context; these are independent dense controls.

These references establish the external mathematical context. The selected dimensions, dyadic constants, runner, and acceptance thresholds are explicit project adaptations unless this page states otherwise.

## Project provenance

- Runnable case: [frank1.m](../../../../examples/tiered/neig-tier-a/frank1.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- This page explains the named model; the family runner and milestone logs remain the measurement authority.
