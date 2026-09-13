# Complex phase of the Hadamard-bidiagonal control (Tier A1)

## Quick idea

HAD_COMPLEX is a Tier A control. This is a complex API and conjugation control, not a new spectrum. It is small, deterministic, and intended to be read with its one-case Octave runner. Tier A identifies an advanced example; it does not claim that the public eig routine implements the cited paper's specialized algorithm.

## Mathematical problem

Demo only: $n=16$ and $s=128$. The phase diagonal repeats $1$, $i$, $-1$, $i$
and is applied by unitary similarity.

```math
Z=\operatorname{diag}(1,i,-1,-i,\ldots),\qquad
A_{\mathbb C}=ZAZ^{\mathsf H}.
```

$Z^{\mathsf H}Z=I$, so $A_{\mathbb C}$ and $A$ have the same eigenvalues;
right and left vectors transform with the corresponding conjugate phases.

## Why this problem is numerically difficult

This is a complex API and conjugation control, not a new spectrum. It catches a transpose in place of conjugate transpose and code that routes a real-only operation through an unrelated binary64 complex fallback. The underlying dense matrix remains nonnormal, while the phase changes the coordinate appearance of vectors.

The exact model, any transformed control, and measured solver output remain separate. A related matrix with a convenient analytic answer is never silently substituted for the matrix named by the case ID.

## What the Octave example computes

The matching [had_complex.m](../../../../examples/tiered/neig-tier-a/had_complex.m) selects only HAD_COMPLEX from the fixed manifest and calls the public `eig` interface. The matching `had_complex.m` runs the demo case through the public complex eig path, checks the unitary similarity, and compares its spectrum with the real control. It measures $A_{\mathbb C}V-VD$ and $A_{\mathbb C}^{\mathsf H}W-WD^{\mathsf H}$, then compares transformed subspaces after phase matching. It remains a separate complex input. The runner records the case ID, profile, dimensions, input identity, and operation precision, and keeps MP values until presentation.

## Construction and exactness

The constructor checks $Z^{\mathsf H}Z=I$, exact quarter-turn entries, and the similarity identity. The real model reference is reused only as a mathematical control; the complex `eig` call consumes $A_{\mathbb C}$. Exactness is checked before and after phase application.

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

The real source is exact dyadic and the phase is exact in MPC. Arithmetic precision controls complex products at the operation precision; mathematical conditioning is inherited from the nonnormal base. More bits improve residuals without changing the similarity.

Input/source precision is the precision and exactness of the stored model. Arithmetic/work precision is the MPFR/MPC precision selected for this operation. Mathematical conditioning is a property of the model. Raising mpbits addresses the second item only; it does not restore bits lost in a separately rounded input or alter a defective structure. Ambient-precision and restoration rows protect this distinction.

## Reading the output

Equal spectra are expected, while vector entries and phases can differ. A transpose-only left residual can look plausible for real data but is invalid here. Read the complex left residual and matching result together.

A PASS line is scoped to the declared case gates and profile. Compare only rows with the same parameters and model hash. If a certificate field is absent, do not infer it from a small residual or a stable display.

## Common mistakes

Do not use $A$ instead of $A_{\mathbb C}$, compare vectors without phase normalization, use a transpose-only left identity, or claim an optimized backend that was not validated.

For diagnosis, verify case ID and dimensions, then model hash and input precision, then residual, then the appropriate forward, cluster, or structural metric. Never change the fixture after observing a failure and report it as the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Siegfried M. Rump, Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix. SIAM Journal on Matrix Analysis and Applications 43(4) (2022), 1736–1754. DOI: 10.1137/21M1451440](https://doi.org/10.1137/21M1451440) — The all-spectrum and rigorous eigensystem context; these are independent dense controls.
- [Nicholas J. Higham, Accuracy and Stability of Numerical Algorithms, 2nd ed. SIAM (2002). DOI: 10.1137/1.9780898718027](https://doi.org/10.1137/1.9780898718027) — The backward/forward-error framework and companion/nonnormal conditioning language used here.

These references establish the external mathematical context. The selected dimensions, dyadic constants, runner, and acceptance thresholds are explicit project adaptations unless this page states otherwise.

## Project provenance

- Runnable case: [had_complex.m](../../../../examples/tiered/neig-tier-a/had_complex.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- This page explains the named model; the family runner and milestone logs remain the measurement authority.
