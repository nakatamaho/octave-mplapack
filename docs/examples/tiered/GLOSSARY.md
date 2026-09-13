# Tiered NEIG/SVD glossary

This glossary fixes the vocabulary used by the 44 one-case pages and their counted runners. A diagnostic is not promoted to a stronger claim than the equation or proof it actually checks.

## Arithmetic and model terms

**Input/source precision** is the precision with which the stored matrix or generator output was formed. For a fixed Ozaki–Ogita case, it includes the generation precision and the realized standard form. For a once-rounded lower-work model, it includes the fact that the rounded matrix is the measured input.

**Work/arithmetic precision** is the MPFR/MPC precision selected for the current operation. It controls construction, products, eig, SVD, references, and diagnostics according to the operation contract. It is not a replacement for source precision.

**Mathematical conditioning** is sensitivity of the exact problem to perturbations. Raising arithmetic precision can reduce rounding error while leaving a large condition number, a small singular gap, or a defective Jordan structure unchanged.

**Dyadic** means a rational number of the form $z/2^k$, with integer z and exponent k. A dyadic is exactly representable when the available significand and exponent range are sufficient. Decimal-looking output is not an exactness proof.

**Realized model** is the exact matrix that the generator or once-rounding rule actually stores. A requested parameter, a realized parameter, a dense product, and a solver output must not be collapsed into one label.

## Eigenproblem terms

For $A\in\mathbb{C}^{n\times n}$, a right eigenpair satisfies $A v=\lambda v$. A left eigenvector is represented as a column satisfying $A^{\mathsf H}w=\overline{\lambda}w$. With $V,D,W$, the measured equations are
$$
A V=V D,\qquad A^{\mathsf H}W=W D^{\mathsf H}.
$$

**Eigen residual** is the normalized equation defect
$$
r_{\mathrm{eig}}=
\frac{\lVert A V-V D\rVert_F}
{\lVert A\rVert_F\lVert V\rVert_F}.
$$
It is a backward-style diagnostic. It does not by itself bound forward eigenvalue error.

**Backward error** asks how much the input must be perturbed for the computed output to satisfy the stated relation. **Forward error** asks how far the computed output is from the mathematical output of the stored input. A small backward error can yield a large forward error for an ill-conditioned problem.

**Nonnormal** means $A^{\mathsf H}A\ne AA^{\mathsf H}$. Nonnormal eigenvectors need not be orthogonal; left/right overlaps can make eigenvalues very sensitive even when they are separated.

**Simple eigenvalue** has algebraic multiplicity one. An isolated-simple-root diagnostic is not valid for a repeated cluster or a defective block.

**Algebraic multiplicity** is the multiplicity in the characteristic polynomial. **Geometric multiplicity** is the dimension of the nullspace of $A-\lambda I$. A Jordan block of size two has algebraic multiplicity two and geometric multiplicity one.

**Semisimple repeated eigenvalue** has equal algebraic and geometric multiplicities. Individual eigenvectors within the repeated eigenspace are not canonical.

**Invariant subspace** is a range $\mathcal R(V_J)$ satisfying $A\mathcal R(V_J)\subseteq\mathcal R(V_J)$. For a cluster, the block residual $A V_J-V_JD_J$ and a range/projector comparison are meaningful even when individual roots or vectors are not.

**Spectral projector** can mean an orthogonal projector onto a numerical range or an oblique algebraic projector such as $Y_{:,J}X_{J,:}$. These are different objects and must be labelled separately.

**Pseudospectrum** at level $\varepsilon$ for the unstructured 2-norm is
$$
\Lambda_\varepsilon(A)=
\{z\in\mathbb C:\sigma_{\min}(zI-A)\le\varepsilon\}.
$$
A pseudospectral point is not necessarily an eigenvalue. A plotted contour is not a verified enclosure unless outward bounds and a declared inside/outside convention support it.

**Balancing** is a representation transformation intended to reduce scale disparities. It is a solver control, not a guaranteed improvement for every eigenvalue or vector. Balance and nobalance rows must retain the same input identity.

## SVD terms

For $A\in\mathbb{C}^{m\times n}$, an SVD is
$$
A=U\Sigma V^{\mathsf H}.
$$
The reconstruction and factor orthogonality diagnostics are
$$
r_{\mathrm{svd}}=
\frac{\lVert A-U\Sigma V^{\mathsf H}\rVert_F}{\lVert A\rVert_F},
\qquad
r_U=\lVert U^{\mathsf H}U-I\rVert_F,\qquad
r_V=\lVert V^{\mathsf H}V-I\rVert_F.
$$

**Singular-value forward error** compares a returned $\widehat\sigma_i$ with the mathematical singular value $\sigma_i(A)$ of the stored A. It is different from reconstruction error.

**Singular gap** is the distance between a target singular value or cluster and the rest of the spectrum. A small gap makes individual singular vectors sensitive.

**Repeated singular group** is a set of equal singular values. Individual columns of U or V can be rotated by any unitary basis change inside the group. Compare projectors or ranges.

**Rank-deficient model** has exact zero singular values by construction or proof. Thresholding a measured small value is not an exact rank proof. **Near-rank** means a small positive singular value next to exact or effectively small zeros; it requires an explicit scale and gap statement.

**Two-sided unitary equivalence** $A=Q B R^{\mathsf H}$, with Q and R unitary, preserves singular values but not eigenvalues in general. It must not be confused with similarity $A=Q B Q^{-1}$.

## Verification and reference terms

**Analytic reference** is a formula evaluated independently at declared MP precision. It is not automatically an outward interval certificate.

**Exactness check** proves a finite algebraic identity from integer/dyadic numerators, denominators, and a sufficient bit/range guard. Two agreeing floating computations are not enough.

**Certified inclusion** is a statement supported by outward-safe bounds that enclose a mathematical object. A residual, a cross-precision match, or an empty adapter is not a certificate.

**Bijection/matching** pairs computed values with reference values one-to-one in MP arithmetic. It must preserve all-spectrum counts and expose unmatched or merged values.

**Model-specific oracle** is an independently proved fact about a named construction, such as a determinant identity, exact rank, or known spectrum. It cannot be generalized to an arbitrary matrix or inserted into measured solver output.

## References and boundaries

- [Siegfried M. Rump, Verified Error Bounds for All Eigenvalues and Eigenvectors of a Matrix (2022), DOI 10.1137/21M1451440](https://doi.org/10.1137/21M1451440) — eigenvalue, eigenvector, cluster, and Jordan-structure context.
- [Per-Åke Wedin, Perturbation bounds in connection with singular value decomposition (1972), DOI 10.1007/BF01932678](https://doi.org/10.1007/BF01932678) — singular-vector and subspace perturbation context.
- [GNU MPFR manual](https://www.mpfr.org/mpfr-current/mpfr.html) — correctly rounded scalar and exponent-range terminology.

The project implements conservative, example-local checks described in the associated NEIG and SVT verification documents. The glossary does not claim full reproduction of the cited papers' algorithms.
