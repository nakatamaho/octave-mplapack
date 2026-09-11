# Primary-source ledger and attribution boundaries

Checked: 2026-09-10. The title/authors/publication identifier below were matched
against publisher or author/institution pages. Issue years are distinguished from
online-first or preprint dates. No books are cited; ISBN checking is inapplicable.
No licensed paper PDFs or third-party implementation source is redistributed.

The finite verification methods in CERTIFICATES.md are original conservative
baselines for the cited **targets**. They are not implementations of all cited
algorithms or claims of their operation counts or sharpness. The OO generator is
explicitly derived from that paper's Theorem 1, with suite-specific fixed inputs.

## OO22 — actual generator source

Katsuhisa Ozaki; Takeshi Ogita. **Generation of test matrices with specified
eigenvalues using floating-point arithmetic.** Numerical Algorithms **90**,
241--262 (2022). Online publication: 17 September 2021.
DOI: **10.1007/s11075-021-01186-7**.

```text
https://link.springer.com/article/10.1007/s11075-021-01186-7
```

Publisher full HTML inspected: definitions and Theorem 1 for exact triple
products, the rounded adjusted standard form, and paired-block construction.
The implemented requested/realized distinction is essential. The selected X,Y,
53/128-bit models and parameter values are this suite's fixtures, not a claim to
reproduce a numbered paper experiment. GENERATOR-OO.md includes all needed formulas.

## R22 — all eigenvalues/eigenvectors and exact Jordan similarity

Siegfried M. Rump. **Verified Error Bounds for All Eigenvalues and Eigenvectors
of a Matrix.** SIAM Journal on Matrix Analysis and Applications **43**(4),
1736--1754 (2022). DOI: **10.1137/21M1451440**.

```text
https://epubs.siam.org/doi/10.1137/21M1451440
https://www.tuhh.de/ti3/paper/rump/Ru22a.pdf
```

Publisher metadata/abstract and author-manuscript parsed text inspected. The
integer unit-triangular similarity preserving true Jordan structure is the
source of SIM fixtures. V-S1 counts all roots and V-S2 targets invariant subspaces;
our Gershgorin/graph baselines do not reproduce Rump's complete algorithm. The
PDF screenshot tool failed during preparation; no numerical table values are
transcribed or claimed visually verified.

## R01 — multiple/near-multiple eigenvalues and subspaces

Siegfried M. Rump. **Computational error bounds for multiple or nearly multiple
eigenvalues.** Linear Algebra and its Applications **324**(1--3), 209--226 (2001).
DOI: **10.1016/S0024-3795(00)00279-2**.

```text
https://www.sciencedirect.com/science/article/pii/S0024379500002792
```

Publisher metadata/abstract matched. Motivates cluster/defective invariant-subspace
inclusion and the distinction from individual eigenvectors. The dyadic two-Jordan
fixture and this Riccati contraction baseline are independently specified here;
not a literal reproduction of the paper's floating-point examples or code.

## NPT13 — Toeplitz reference formulas and sensitivity

Silvia Noschese; Lionello Pasquini; Lothar Reichel. **Tridiagonal Toeplitz matrices:
properties and novel applications.** Numerical Linear Algebra with Applications
**20**(2), 302--326 (2013). Online-first: 2012.
DOI: **10.1002/nla.1811**.

```text
https://doi.org/10.1002/nla.1811
```

Publisher metadata matched. The Toeplitz eigenvalue/eigenvector formulas specialize
to the exact subdiagonal 1, diagonal 3, superdiagonal 2^-8 used here. The coefficient
choice and explicit symmetric control are suite-designed. CASES.md gives direct
identities sufficient for independent verification of their formulas.

## AMRVW18 — polynomial versus matrix backward error

Jared L. Aurentz; Thomas Mach; Leonardo Robol; Raf Vandebril; David S. Watkins.
**Fast and Backward Stable Computation of Roots of Polynomials, Part II: Backward
Error Analysis; Companion Matrix and Companion Pencil.** SIAM Journal on Matrix
Analysis and Applications **39**(3), 1245--1269 (2018).
DOI: **10.1137/17M1152802**.

```text
https://epubs.siam.org/doi/10.1137/17M1152802
```

Publisher metadata matched. Supports keeping polynomial-coefficient and matrix
backward errors distinct. No structured companion-QR/QZ algorithm from this paper
is implemented here. Our rootwise coefficient perturbation formula has its own
explicit complex/unconstrained-leading-coefficient convention.

## R06 — structured perturbations/pseudospectra

Siegfried M. Rump. **Eigenvalues, pseudospectrum and structured perturbations.**
Linear Algebra and its Applications **413**(2--3), 567--593 (2006).
DOI: **10.1016/j.laa.2005.06.009**.

```text
https://www.sciencedirect.com/science/article/pii/S0024379505003034
```

Publisher metadata/abstract matched. Interpretation source: a structured
perturbation class is not the same as unrestricted complex perturbations. Our
required Grcar pseudospectrum is the unstructured complex 2-norm set, not a
certified real-only or Toeplitz-preserving pseudospectrum.

## MKS25 — Toeplitz plus rank-one perturbation

Saori Morimoto; Makoto Katori; Tomoyuki Shirai. **Eigenvalue and pseudospectrum
processes generated by nonnormal Toeplitz matrices with rank 1 perturbations.**
International Journal of Mathematics for Industry **17**(1), 2550013 (2025).
DOI: **10.1142/S2661335225500133**. Preprint: arXiv:2401.08129, first submitted 2024.

```text
https://doi.org/10.1142/S2661335225500133
https://arxiv.org/html/2401.08129v6
https://kyushu-u.elsevierpure.com/en/publications/eigenvalue-and-pseudospectrum-processes-generated-by-nonnormal-to/
```

Author full HTML and institution publication record checked. Model 1 and its
reduced nonzero-root polynomial are used; model 2 and the full stochastic/process
study are not. The exact determinant identity is independently tested in the
preparation script. The suite's n,m,delta choices are stated separately.

## F21 — related pseudospectrum enclosure target

Andreas Frommer; Birgit Jacob; **Lukas Vorberg**; Christian Wyss; Ian Zwaan.
**Pseudospectrum Enclosures by Discretization.** Integral Equations and Operator
Theory **93**, article **9** (2021). Published 1 February 2021.
DOI: **10.1007/s00020-020-02621-5**.

```text
https://link.springer.com/article/10.1007/s00020-020-02621-5
```

Publisher full HTML and metadata checked. The paper uses numerical ranges of
shifted inverses and treats discretized operators. Our finite-matrix singular-value
point/cell certifier is **not** that algorithm. It uses the closed pseudospectrum;
the paper's open-set convention must not be silently substituted. No PDE/operator
or entire-boundary convergence claim is made by the examples.

## RO24 — compatible matrix decomposition enclosures

Siegfried M. Rump; Takeshi Ogita. **Verified Error Bounds for Matrix Decompositions.**
SIAM Journal on Matrix Analysis and Applications **45**(4), 2155--2183 (2024).
DOI: **10.1137/24M165096X**.

```text
https://epubs.siam.org/doi/10.1137/24M165096X
```

Publisher metadata/abstract matched; eigendecomposition and Schur decomposition
are among the targets. V-A1 here combines graph eigenfactor existence with
interval evaluation of exact QR. It is a conservative independently proved
baseline, not the paper's detailed algorithm or entrywise-optimal bounds.

## M14 — generalized eigenvalues and invariant subspaces

Shinya Miyajima. **Fast Enclosure for All Eigenvalues and Invariant Subspaces in
Generalized Eigenvalue Problems.** SIAM Journal on Matrix Analysis and Applications
**35**(3), 1205--1225 (2014). DOI: **10.1137/140953150**.

```text
https://epubs.siam.org/doi/10.1137/140953150
```

Publisher metadata/abstract matched. Our verified B^-1 A reduction addresses
finite nonsymmetric pencils with proved nonsingular B and accounts for reduction
error. It does not implement general singular-B pencils, infinite eigenvalues,
or all of this paper's methods. Those domain limits do not make the required
nonsingular-B tests optional.

## M21 — Perron pair

Shinya Miyajima. **Fast verification for the Perron pair of an irreducible
nonnegative matrix.** Electronic Journal of Linear Algebra **37**, 402--415 (2021).
Published 31 May 2021. DOI: **10.13001/ela.2021.5181**.

```text
https://journals.uwyo.edu/index.php/ela/article/view/5181
```

Journal metadata matched. Our Collatz--Wielandt plus normalized eigenpair
contraction proves the same type of positive root/vector target, but is not a
reproduction of the paper's specialized M-matrix-based method. It does not by
itself certify the second eigenvalue or a mixing time.

## MPFR and repository contracts

Official GNU MPFR manual: correctly rounded scalar operations and exponent/range
semantics. The web manual version is not assumed to be the installed version.

```text
https://www.mpfr.org/mpfr-current/mpfr.html
```

Target repository sources attempted during preparation:

```text
https://github.com/nakatamaho/octave-mplapack
https://raw.githubusercontent.com/nakatamaho/octave-mplapack/main/docs/eig.md
https://raw.githubusercontent.com/nakatamaho/octave-mplapack/main/docs/precision-semantics.md
```

Those current repository fetches failed in this turn. Prior supplied NEIG/SVT
specifications were read, but they are not proof of current code. The executor
must audit the actual checkout and loaded package before relying on any API or
rounding guarantee. No guessed current version/commit is embedded in this bundle.

## Cross-reference policy

Each constructor records the source ID and whether it is a paper formula,
specialization, or original control. Each verifier records its own method ID,
source-inspired target and `paper_algorithm_reproduction=false`. Known algebraic
model facts, high-precision consistency and certified inclusion are different
metadata fields. Do not call the neighboring Hermitian/SVD verification theory a
general nonsymmetric eigenvalue verifier. No new literature claim is accepted
from a guessed DOI or from an uninspected citation chain.
