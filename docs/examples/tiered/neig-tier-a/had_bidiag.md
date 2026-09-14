# Hadamard-similar upper bidiagonal matrix (Tier A1)

## Quick idea

HAD_BIDIAG is a Tier A control. The spectrum is well separated while the eigenvectors are not. It is small, deterministic, and intended to be read with its one-case Octave runner. Tier A identifies an advanced example; it does not claim that the public eig routine implements the cited paper's specialized algorithm.

## Mathematical problem

Smoke: $n=8$ and $s=16$. Demo: $n=16$ and $s=128$. $n$ is a power of two
and $H$ is the Sylvester Hadamard matrix.

```math
T=\mathrm{diag}(1,2,\ldots,n)+sN,\qquad
A=\frac{1}{n}HTH^{\mathsf T},\qquad HH^{\mathsf T}=nI.
```

The orthogonal similarity preserves the exact eigenvalues $1,2,\ldots,n$.
For root $k$, the triangular reference vectors use

```math
v_i=\frac{s^{k-i}}{(k-i)!}\quad (i\le k),\qquad
w_i=\frac{(-s)^{i-k}}{(i-k)!}\quad (i\ge k).
```

The corresponding left/right condition reference is

```math
\kappa_k=
\left[\sum_{j=0}^{k-1}\frac{s^{2j}}{(j!)^2}\right]^{1/2}
\left[\sum_{j=0}^{n-k}\frac{s^{2j}}{(j!)^2}\right]^{1/2}.
```

## Why this problem is numerically difficult

The spectrum is well separated while the eigenvectors are not. A dense orthogonal similarity hides the triangular structure, so the eigensolver must work in dense coordinates. Factorial recurrences create large and small components at once, and the left/right overlap determines individual eigenvalue sensitivity. Exact integer and dyadic entries make the input auditable, but an integer spectrum does not make every computed digit forward accurate.

The exact model, any transformed control, and measured solver output remain separate. A related matrix with a convenient analytic answer is never silently substituted for the matrix named by the case ID.

## What the Octave example computes

The matching [had_bidiag.m](../../../../examples/tiered/neig-tier-a/had_bidiag.m) selects only HAD_BIDIAG from the fixed manifest and calls the public eig interface. The matching had_bidiag.m selects only HAD_BIDIAG from the frozen manifest, constructs $T$ and $A$ directly, checks Hadamard orthogonality, and calls the public eig path on $A$. It compares measured roots with $1:n$, reports residuals and matched forward error, and evaluates the condition reference $\kappa_k$ shown above. It never solves $T$ instead of $A$. The runner records the case ID, profile, dimensions, input identity, and operation precision, and keeps MP values until presentation.

## Construction and exactness

The audit checks $HH^{\mathsf T}=nI$, both dense product stages, the dyadic bit guard, and the exact spectrum independently. Factorial terms are evaluated by MP multiplicative recurrences rather than native factorials. Vector comparisons use normalization and sign matching. Agreement between two MP runs is corroborating evidence, not an exactness proof.

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

The source model is exact at the stated n and s. Arithmetic precision controls the dense products and eig call, while mathematical conditioning is reflected by the factorial norm products and grows with s. More bits reduce arithmetic error but do not make a sensitive eigenvalue insensitive. Input precision and work precision are recorded separately.

Input/source precision is the precision and exactness of the stored model. Arithmetic/work precision is the MPFR/MPC precision selected for this operation. Mathematical conditioning is a property of the model. Raising mpbits addresses the second item only; it does not restore bits lost in a separately rounded input or alter a defective structure. Ambient-precision and restoration rows protect this distinction.

## Reading the output

The integer-root bottleneck is a forward diagnostic; $r_{\mathrm{eig}}$ is an eigen-equation diagnostic. A small residual with a larger root error is consistent with a large $\kappa_k$. The Hadamard transform is an orthogonal similarity, not the two-sided equivalence used by SVD cases.

A PASS line is scoped to the declared case gates and profile. Compare only rows with the same parameters and model hash. If a certificate field is absent, do not infer it from a small residual or a stable display.

## Common mistakes

Do not replace $A$ with $T$, compute factorials in binary64, call $\kappa_k$ a measured error, or infer good eigenvectors from separated eigenvalues. Do not confuse eigenvalue similarity with singular-value mixing.

For diagnosis, verify case ID and dimensions, then model hash and input precision, then residual, then the appropriate forward, cluster, or structural metric. Never change the fixture after observing a failure and report it as the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Siegfried M. Rump, Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix. SIAM Journal on Matrix Analysis and Applications 43(4) (2022), 1736–1754. DOI: 10.1137/21M1451440](https://doi.org/10.1137/21M1451440) — The all-spectrum and rigorous eigensystem context; these are independent dense controls.
- [Nicholas J. Higham, Accuracy and Stability of Numerical Algorithms, 2nd ed. SIAM (2002). DOI: 10.1137/1.9780898718027](https://doi.org/10.1137/1.9780898718027) — The backward/forward-error framework and companion/nonnormal conditioning language used here.

These references establish the external mathematical context. The selected dimensions, dyadic constants, runner, and acceptance thresholds are explicit project adaptations unless this page states otherwise.

## Project provenance

- Runnable case: [had_bidiag.m](../../../../examples/tiered/neig-tier-a/had_bidiag.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- This page explains the named model; the family runner and milestone logs remain the measurement authority.
