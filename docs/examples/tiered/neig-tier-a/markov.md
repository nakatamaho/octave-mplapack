# Dyadic irreducible Markov matrix (Tier A6)

## Quick idea

MARKOV is a Tier A control. The Perron root is known, but the stationary vector is a nontrivial left eigenvector. It is small, deterministic, and intended to be read with its one-case Octave runner. Tier A identifies an advanced example; it does not claim that the public eig routine implements the cited paper's specialized algorithm.

## Mathematical problem

Smoke: $n=8$ and $\varepsilon=2^{-24}$. Demo: $n=16$ and
$\varepsilon=2^{-80}$. The matrix is row-stochastic with a nonuniform
stationary left vector.

$$
\begin{gathered}
h=n/2,\qquad
C\in\mathbb{R}^{h\times h},\quad
C_{i,i+1}=1\ (1\leq i<h),\quad C_{h,1}=1,\\
Q=\operatorname{blockdiag}\left(\frac{3}{4}I_h+\frac{1}{4}C,
\frac{7}{8}I_h+\frac{1}{8}C\right),\\
r_i=2^{-i}\ (1\leq i<n),\qquad r_n=2^{-(n-1)},
\qquad \mathbf{1}^{\mathsf T}r=1,\\
P=(1-\varepsilon)Q+\varepsilon\mathbf{1}r^{\mathsf T},
\qquad \varepsilon=2^{-e},\qquad P\mathbf{1}=\mathbf{1}.
\end{gathered}
$$

The vector $r$ is the teleportation target, not generally the stationary
vector. The stationary row is

$$
\pi^{\mathsf T}=\varepsilon r^{\mathsf T}
\left[I-(1-\varepsilon)Q\right]^{-1},
\qquad \pi^{\mathsf T}P=\pi^{\mathsf T},
\qquad \pi^{\mathsf T}\mathbf{1}=1.
$$

Thus the right Perron vector of $P$ is $\mathbf{1}$, whereas its left
stationary vector is the nonuniform $\pi$.

## Why this problem is numerically difficult

The Perron root is known, but the stationary vector is a nontrivial left eigenvector. Rank-one dyadic mixing makes the chain irreducible while preserving an exact model. A row-sum check tests only the right vector and can miss a broken left convention. Non-Perron roots are outside the Perron certificate.

The exact model, any transformed control, and measured solver output remain separate. A related matrix with a convenient analytic answer is never silently substituted for the matrix named by the case ID.

## What the Octave example computes

The matching [markov.m](../../../../examples/tiered/neig-tier-a/markov.m) selects
only MARKOV from the fixed manifest and calls the public eig interface. The
underlying `net_markov_model` constructs $C$, $Q$, $r$, and $P$ in MP. The
reference path evaluates the formula for $\pi$ and also solves the normalized
linear system obtained from $P^{\mathsf T}\pi=\pi$. The runner compares those
two independently prepared stationary rows, checks row sums, and keeps the
teleportation target $r$ separate from the stationary vector $\pi$. It also
runs the V-A3 Perron checker on $P$ and $P^{\mathsf T}$. The output separates
root, right vector, left vector, normalization, and non-Perron diagnostics.
The runner records the case ID, profile, dimensions, input identity, and
operation precision, and keeps MP values until presentation.

## Construction and exactness

The audit verifies nonnegative dyadic entries, $P\mathbf{1}=\mathbf{1}$, the
rank-one formula, and the irreducibility assumptions. It checks both the
analytic formula and the independent normalized solve for $\pi$, including
$\pi^{\mathsf T}P=\pi^{\mathsf T}$ and $\pi^{\mathsf T}\mathbf{1}=1$. The
stationary vector has a declared normalization and is not supplied to the
eigensolver as its answer.

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

The source is exact dyadic and includes epsilon. Arithmetic precision controls positivity, eig, and normalization. Mathematical conditioning depends on mixing and Perron separation. More bits preserve a small mixing term but do not prove a spectral gap.

Input/source precision is the precision and exactness of the stored model. Arithmetic/work precision is the MPFR/MPC precision selected for this operation. Mathematical conditioning is a property of the model. Raising mpbits addresses the second item only; it does not restore bits lost in a separately rounded input or alter a defective structure. Ambient-precision and restoration rows protect this distinction.

## Reading the output

A valid Perron result requires a positive root enclosure, both vector residuals, and a contraction or Collatz–Wielandt uniqueness check. Row-stochasticity alone is insufficient. The second eigenvalue and a mixing-time theorem are not claimed.

A PASS line is scoped to the declared case gates and profile. Compare only rows with the same parameters and model hash. If a certificate field is absent, do not infer it from a small residual or a stable display.

## Common mistakes

Do not call the stationary vector uniform, verify only P*1=1, claim the Perron test certifies all eigenvalues, or use a rounded native stochastic matrix as the exact model.

For diagnosis, verify case ID and dimensions, then model hash and input precision, then residual, then the appropriate forward, cluster, or structural metric. Never change the fixture after observing a failure and report it as the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Shinya Miyajima, Fast verification for the Perron pair of an irreducible nonnegative matrix. Electronic Journal of Linear Algebra 37 (2021), 402–415. DOI: 10.13001/ela.2021.5181](https://doi.org/10.13001/ela.2021.5181) — The positive Perron root/vector target; the checker here is an independent conservative baseline.
- [Siegfried M. Rump, Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix. SIAM Journal on Matrix Analysis and Applications 43(4) (2022), 1736–1754. DOI: 10.1137/21M1451440](https://doi.org/10.1137/21M1451440) — The all-spectrum and rigorous eigensystem context; these are independent dense controls.

These references establish the external mathematical context. The selected dimensions, dyadic constants, runner, and acceptance thresholds are explicit project adaptations unless this page states otherwise.

## Project provenance

- Runnable case: [markov.m](../../../../examples/tiered/neig-tier-a/markov.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- This page explains the named model; the family runner and milestone logs remain the measurement authority.
