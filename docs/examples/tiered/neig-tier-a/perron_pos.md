# Positive diagonally similar Perron matrix (Tier A6)

## Quick idea

PERRON_POS is a Tier A control. Positivity is preserved while a nonunitary diagonal similarity creates a large coordinate dynamic range. It is small, deterministic, and intended to be read with its one-case Octave runner. Tier A identifies an advanced example; it does not claim that the public eig routine implements the cited paper's specialized algorithm.

## Mathematical problem

Smoke: $n=8$, $\varepsilon=2^{-24}$, and scale $\alpha=3/2$. Demo: $n=16$,
$\varepsilon=2^{-80}$, and $\alpha=3/2$.

$$
\alpha=\frac{3}{2},\qquad
D=\operatorname{diag}(1,2,\ldots,2^{n-1}),\qquad
A=\alpha D P D^{-1}.
$$

Here $P$ is the MARKOV model from the companion page. It satisfies
$P\mathbf{1}=\mathbf{1}$, but its stationary row is $\pi^{\mathsf T}$, not
the teleportation target $r^{\mathsf T}$. Therefore

$$
v=D\mathbf{1},\qquad
w=D^{-1}\pi,\qquad
Av=\alpha v,\qquad
w^{\mathsf T}A=\alpha w^{\mathsf T},\qquad
\rho(A)=\alpha.
$$

Both $v$ and $w$ are positive. The runner normalizes $v$ to have unit sum
and then scales $w$ so that $w^{\mathsf T}v=1$. The vectors $r$ and $\pi$ are
deliberately distinct objects: $r$ defines teleportation, while $\pi$ is the
left stationary vector computed from the Markov equation.

## Why this problem is numerically difficult

Positivity is preserved while a nonunitary diagonal similarity creates a large coordinate dynamic range. A solver can satisfy a small residual with a poorly normalized vector, and checking only the right equation misses the nontrivial left vector. The scale 3/2 also distinguishes this matrix from the stochastic model.

The exact model, any transformed control, and measured solver output remain separate. A related matrix with a convenient analytic answer is never silently substituted for the matrix named by the case ID.

## What the Octave example computes

The matching [perron_pos.m](../../../../examples/tiered/neig-tier-a/perron_pos.m)
selects only PERRON_POS from the fixed manifest and calls the public eig
interface. The underlying model builds the MARKOV matrix $P$ and the similar
matrix $A$ directly in MP, verifies the diagonal-similarity identity, and
runs `eig` on $A$. The independent reference uses $v=D\mathbf{1}$ and
$w=D^{-1}\pi$, where $\pi$ comes from the companion Markov stationary solve;
it does not use $r$ as a surrogate. V-A3 checks the appropriate transpose/
adjoint orientation. The runner records the case ID, profile, dimensions,
input identity, and operation precision, and keeps MP values until
presentation.

## Construction and exactness

The audit checks dyadic $D$ and $D^{-1}$ scaling, positivity, the transformed
Perron equations, the stationary equation for $\pi$, and the normalization
overlap. It never uses a measured vector to construct the reference. MP
evaluation is retained because native normalization can obscure
scale-separated components.

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

The source is exact dyadic apart from rational 3/2, with range set by D. Arithmetic precision controls dense construction and Perron verification. Mathematical conditioning comes from diagonal similarity and mixing; more bits preserve components but do not remove sensitivity.

Input/source precision is the precision and exactness of the stored model. Arithmetic/work precision is the MPFR/MPC precision selected for this operation. Mathematical conditioning is a property of the model. Raising mpbits addresses the second item only; it does not restore bits lost in a separately rounded input or alter a defective structure. Ambient-precision and restoration rows protect this distinction.

## Reading the output

Read root error, right residual, left residual, positivity margin, and contraction fields together. A positive matrix need not have a well-conditioned eigenvector pair in these coordinates. A small r_eig does not prove that the Perron vector has all correct digits.

A PASS line is scoped to the declared case gates and profile. Compare only rows with the same parameters and model hash. If a certificate field is absent, do not infer it from a small residual or a stable display.

## Common mistakes

Do not assume the left vector is uniform, drop D from the equations, claim A is stochastic, verify only the Perron root, or call positivity alone a certificate.

For diagnosis, verify case ID and dimensions, then model hash and input precision, then residual, then the appropriate forward, cluster, or structural metric. Never change the fixture after observing a failure and report it as the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Shinya Miyajima, Fast verification for the Perron pair of an irreducible nonnegative matrix. Electronic Journal of Linear Algebra 37 (2021), 402–415. DOI: 10.13001/ela.2021.5181](https://doi.org/10.13001/ela.2021.5181) — The positive Perron root/vector target; the checker here is an independent conservative baseline.
- [Siegfried M. Rump, Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix. SIAM Journal on Matrix Analysis and Applications 43(4) (2022), 1736–1754. DOI: 10.1137/21M1451440](https://doi.org/10.1137/21M1451440) — The all-spectrum and rigorous eigensystem context; these are independent dense controls.

These references establish the external mathematical context. The selected dimensions, dyadic constants, runner, and acceptance thresholds are explicit project adaptations unless this page states otherwise.

## Project provenance

- Runnable case: [perron_pos.m](../../../../examples/tiered/neig-tier-a/perron_pos.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- This page explains the named model; the family runner and milestone logs remain the measurement authority.
