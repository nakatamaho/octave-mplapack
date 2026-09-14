# Wilkinson integer companion matrix (Tier A3)

## Quick idea

WILKINSON is a Tier A control. The roots are simple integers, but the coefficient vector contains large cancellation and the companion problem magnifies coefficient perturbations. It is small, deterministic, and intended to be read with its one-case Octave runner. Tier A identifies an advanced example; it does not claim that the public eig routine implements the cited paper's specialized algorithm.

## Mathematical problem

Smoke: $n=10$. Demo: $n=20$. The target polynomial has exact roots
$1,2,\ldots,n$.

```math
p_n(z)=\prod_{j=1}^{n}(z-j)=z^n+c_1z^{n-1}+\cdots+c_n.
```

The Frobenius companion has first row $-(c_1,\ldots,c_n)$ and ones on the
first subdiagonal. The complex coefficientwise indicator is

```math
\eta_{\mathrm{poly}}(z)=
\frac{\lvert p_n(z)\rvert}
{\displaystyle\sum_{j=0}^{n}\lvert c_j\rvert\lvert z\rvert^{n-j}},
\qquad c_0=1.
```

## Concrete smoke matrix

<!-- smoke-matrix: WILKINSON -->

```math
A_{\mathrm{smoke}} = \begin{bmatrix}
55 & -1320 & 18150 & -157773 & 902055 & -3416930 & 8409500 & -12753576 & 10628640 & -3628800 \\
1 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 1 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 1 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 1 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 1 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 1 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 1 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 1 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 1 & 0
\end{bmatrix}.
```

This is the full concrete smoke fixture for `WILKINSON`. The matching [`wilkinson.m`](../../../../examples/tiered/neig-tier-a/wilkinson.m) selects the same manifest case and hands this input to the public `eig` path; the displayed matrix is not solver output.

The entries are exact integers or dyadic rationals. If a common factor such as `2^{-q}` appears before the bracket, it multiplies every bracket entry and is part of the exact matrix, not a decimal approximation. Fixed-generation cases retain the declared generator precision in their model object; any separate exact widening and solver/work precision remain distinct recorded quantities.

The smoke configuration is the small, inspectable documentation and CI instance. Its matching demo is a separate manifest row that may change the dimension, parameter, or profile; it is not substituted for this input when interpreting the measured result. This separation keeps the source matrix, source precision, and solver output auditable.

## Why this problem is numerically difficult

The roots are simple integers, but the coefficient vector contains large cancellation and the companion problem magnifies coefficient perturbations. A matrix residual is a backward statement for $C$, whereas $\eta_{\mathrm{poly}}$ is a coefficientwise backward statement for $p_n$; neither is the root's forward error. The example catches unsafe coefficient construction from native poly.

The exact model, any transformed control, and measured solver output remain separate. A related matrix with a convenient analytic answer is never silently substituted for the matrix named by the case ID.

## What the Octave example computes

The matching [wilkinson.m](../../../../examples/tiered/neig-tier-a/wilkinson.m) selects only WILKINSON from the fixed manifest and calls the public eig interface. The matching wilkinson.m constructs coefficients by exact integer recurrence, forms $C$, runs public eig, and evaluates Horner $p(z)$ and its denominator in MP. It reports exact-root bottleneck, $r_{\mathrm{eig}}$, and $\eta_{\mathrm{poly}}$ for the exact model and any separately labelled native control. The matrix is never reconstructed from measured roots. The runner records the case ID, profile, dimensions, input identity, and operation precision, and keeps MP values until presentation.

## Construction and exactness

The generator records a conservative integer/intermediate guard and checks coefficients independently. Horner evaluation at known roots uses higher precision. A denominator-zero case is explicit. The companion first row and subdiagonal are checked entry by entry.

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

Source coefficients and companion entries are exact integers when the guard is met. Arithmetic precision controls coefficient generation, Horner evaluation, and eig. Mathematical root sensitivity is distinct from coefficient exactness. Native stress rounding is a different input.

Input/source precision is the precision and exactness of the stored model. Arithmetic/work precision is the MPFR/MPC precision selected for this operation. Mathematical conditioning is a property of the model. Raising mpbits addresses the second item only; it does not restore bits lost in a separately rounded input or alter a defective structure. Ambient-precision and restoration rows protect this distinction.

## Reading the output

A tiny $\eta_{\mathrm{poly}}$ says a nearby coefficient vector can explain $z$; it does not say $z$ is close to its intended integer. Compare $\eta_{\mathrm{poly}}$, $r_{\mathrm{eig}}$, and forward distance as three quantities. Exact roots belong only to the exact coefficient model.

A PASS line is scoped to the declared case gates and profile. Compare only rows with the same parameters and model hash. If a certificate field is absent, do not infer it from a small residual or a stable display.

## Common mistakes

Do not form coefficients with binary64 poly, call polynomial backward error a forward error, use poly(eig(C)) as an oracle, or claim a small residual proves all roots equal $1,\ldots,n$.

For diagnosis, verify case ID and dimensions, then model hash and input precision, then residual, then the appropriate forward, cluster, or structural metric. Never change the fixture after observing a failure and report it as the original case.

## Scope of the claim

This page is a worked mathematical explanation, not a promise about every matrix that happens to resemble this family. The named case ID fixes the construction, profile, precision roles, comparison convention, and status vocabulary. A reader who changes n, an exponent, an orientation, a phase, or a representation has created a new represented input and must record it as such. That discipline matters because a harmless-looking change can alter rank, multiplicity, cluster separation, exponent range, or the left/right conditioning.

The dense output is always interpreted in the coordinates of the named model. Analytic roots, transformed controls, and exact identities are used as independent checks. They are not spliced into measured output, and a high-precision reference is not treated as a formal proof unless the page names the additional proof. For nonsymmetric problems, keep right and left equations distinct and use conjugation for complex data. The family runner supplies counted coverage; this page supplies the meaning of one row.
## References

- [Jared L. Aurentz, Thomas Mach, Leonardo Robol, Raf Vandebril, and David S. Watkins, Fast and Backward Stable Computation of Roots of Polynomials, Part II. SIAM Journal on Matrix Analysis and Applications 39(3) (2018), 1245–1269. DOI: 10.1137/17M1152802](https://doi.org/10.1137/17M1152802) — Keeps polynomial coefficient backward error separate from dense eigenvalue forward error.
- [Nicholas J. Higham, Accuracy and Stability of Numerical Algorithms, 2nd ed. SIAM (2002). DOI: 10.1137/1.9780898718027](https://doi.org/10.1137/1.9780898718027) — The backward/forward-error framework and companion/nonnormal conditioning language used here.

These references establish the external mathematical context. The selected dimensions, dyadic constants, runner, and acceptance thresholds are explicit project adaptations unless this page states otherwise.

## Project provenance

- Runnable case: [wilkinson.m](../../../../examples/tiered/neig-tier-a/wilkinson.m).
- Case manifest: [NEIG cases.json](../../../../docs/codex/neigt/cases.json).
- Verification scope: [NEIG verification-jobs.json](../../../../docs/codex/neigt/verification-jobs.json) and [CERTIFICATES.md](../../../../docs/codex/neigt/CERTIFICATES.md).
- This page explains the named model; the family runner and milestone logs remain the measurement authority.
