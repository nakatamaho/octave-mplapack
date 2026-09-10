# SVT source ledger and attribution limits

Checked during preparation on 2026-09-10. This ledger distinguishes publisher
metadata/abstracts, inspected mathematical content, and original suite derivations.
DOIs below were matched to title, authors, and publication metadata through primary
publisher or author-institution records. No book is required or cited, so there is
no unverified ISBN dependency. Official software documentation has no paper DOI.
No licensed article PDFs, third-party numerical source, or font files are bundled.

The prepared examples use independently written mathematical constructions. Their
particular dimensions, powers of two, and acceptance targets are suite choices,
not claimed reproductions of published numerical tables. The selected Tier V
baselines are **not ports of the three paper algorithms**. Full derivations of
these narrower baselines are in VERIFICATION.md.

## [NRO11] Integer matrices with controlled singular-value distributions

Tetsuo Nishi, Siegfried M. Rump, and Shin'ichi Oishi.
**On the generation of very ill-conditioned integer matrices.**
*Nonlinear Theory and Its Applications, IEICE* **2**(2), 226--245 (2011).
DOI: **10.1587/nolta.2.226**.

Primary records:

```text
https://www.jstage.jst.go.jp/article/nolta/2/2/2_2_226/_article
https://www.jstage.jst.go.jp/article/nolta/2/2/2_2_226/_pdf/-char/en
```

Checked: matching publisher metadata; public article text in Sections 4 and 5.
The displayed matrix/inverse in equation (82) was also checked in a page image.
The other construction formulas were read from the article text; this is not a
claim that every equation/table in the paper was visually inspected.

Section 5 supplies the block family `[I,B;0,I]`. Its stable singular-value formula
in CASES.md follows by orthogonal reduction to 2-by-2 blocks; choosing B=H*diag(w)
is this suite's deterministic specialization. Section 4 supplies the bounded-integer
companion-like construction using Horner coefficients. CASES.md specifies the
chosen alternating k sequence and reproduces a small exact identity from (82)
for a construction check, not an entire published experiment.

No claim is made that arbitrary prescribed real spectra can all be realized by
bounded integer matrices. Integer inputs are exact only within their stated
significand/range bounds.

## [JS14] Jacobi--Stirling

Jorge Delgado and Juan Manuel Peña.
**Fast and accurate algorithms for Jacobi--Stirling matrices.**
*Applied Mathematics and Computation* **236**, 253--259 (2014).
DOI: **10.1016/j.amc.2014.03.047**.

```text
https://www.sciencedirect.com/science/article/abs/pii/S0096300314004093
https://doi.org/10.1016/j.amc.2014.03.047
```

Checked: publisher title/DOI/abstract and the bibliographic record reproduced in
primary follow-up articles by the same research group. The volume is 236, not
235. The paper explicitly addresses singular values and inverses to high relative
accuracy. The suite uses the integer second-kind recurrence at z=1, not copied
algorithm code. Its numerical reference is independently certified by the SVT
checker; no unimplemented structured factor algorithm is advertised as an oracle.

Terminology caution: triangular matrices have zero minors. Use totally nonnegative
for nonnegative minors, or explain the article's convention; do not claim every
minor is strictly positive.

## [LAH19] Lah matrices in the Laguerre paper

Jorge Delgado, Héctor Orera, and Juan Manuel Peña.
**Accurate computations with Laguerre matrices.**
*Numerical Linear Algebra with Applications* **26**(1), e2217 (2019).
DOI: **10.1002/nla.2217**.

```text
https://onlinelibrary.wiley.com/doi/10.1002/nla.2217
```

Checked: publisher authors/title/DOI, volume/issue/article number, and summary.
The first-online date is 2018-10-05; the issue/citation year is 2019. The summary
explicitly includes Lah bidiagonal factorizations and high-relative-accuracy
singular values. CASES.md uses the exact integer Lah recurrence/closed form.
This preparation does not claim a full transcription of the paper's algorithm.

## [DD11] Diagonally dominant representations

Froilán M. Dopico and Plamen Koev.
**Perturbation theory for the LDU factorization and accurate computations for
 diagonally dominant matrices.**
*Numerische Mathematik* **119**, 337--371 (2011).
DOI: **10.1007/s00211-011-0382-3**.

```text
https://link.springer.com/article/10.1007/s00211-011-0382-3
```

Checked: publisher metadata and abstract. Its accurate-factorization theory is
about carefully represented diagonally dominant data. It is not a guarantee for
arbitrary dense `svd(A)` after losing the small DD part during materialization.
The symmetric shifted path and biased nonsymmetric path are suite-derived members
of this class. Only the symmetric member has the stated elementary singular-value
formula. A constant row sum is an eigenvalue statement, not a singular-value oracle.

## [PAS13] Pascal

Pedro Alonso, Jorge Delgado, Rafael Gallego, and Juan Manuel Peña.
**Conditioning and accurate computations with Pascal matrices.**
*Journal of Computational and Applied Mathematics* **252**, 21--26 (2013).
DOI: **10.1016/j.cam.2011.12.007**.

```text
https://doi.org/10.1016/j.cam.2011.12.007
```

Checked: publisher record and available text/summary. The DOI contains 2011 but
this is a 2013 journal issue. The paper's explicitly described applications include
eigenvalues, inverses, and systems. Do not pretend it supplies a reproduced SVD
benchmark table. SVD use here also relies on the TN framework [TN05] and on the
suite's independent exact binomial construction/certified reference.

## [TN05] High relative accuracy from totally nonnegative factors

Plamen Koev.
**Accurate Eigenvalues and SVDs of Totally Nonnegative Matrices.**
*SIAM Journal on Matrix Analysis and Applications* **27**(1), 1--23 (2005).
DOI: **10.1137/S0895479803438225**.

```text
https://epubs.siam.org/doi/10.1137/S0895479803438225
```

Checked: publisher title/author/DOI, issue metadata, and abstract. Use the 2005
issue year, not a later webpage/online timestamp. The accuracy statement is
conditional on accurately supplied bidiagonal-factor data. The suite chooses
dyadic Vandermonde nodes and includes Pascal/combinatorial families, but does not
claim dense reconstruction plus generic SVD inherits the structured guarantee.
TNTool is neither bundled nor a required runtime dependency.

## [RL23] Tier V1 target: all singular pairs and clusters

Siegfried M. Rump and Marko Lange.
**Fast computation of error bounds for all eigenpairs of a Hermitian and all
 singular pairs of a rectangular matrix with emphasis on eigen- and singular
 value clusters.**
*Journal of Computational and Applied Mathematics* **434**, 115332 (2023).
DOI: **10.1016/j.cam.2023.115332**.

```text
https://www.sciencedirect.com/science/article/pii/S0377042723002765
https://tore.tuhh.de/entities/publication/3757f148-23ee-4e71-a0cb-3a661c4dfef8
```

Checked: publisher/author-institution title, authors, volume, article number,
DOI and abstract. The paper addresses singular vectors/subspaces and individual
values, including clusters/multiplicities and interval inputs. Its complete
algorithm was not transcribed in this preparation.

SVT supplies the narrower, explicitly derived polar/Weyl value inclusion and
signed-dilation projector bound for point matrices. It does not claim the paper's
interval-input coverage, operation counts, sharpness, or full algorithm reproduction.

## [RO24] Tier V2 target: compatible factor enclosures

Siegfried M. Rump and Takeshi Ogita.
**Verified Error Bounds for Matrix Decompositions.**
*SIAM Journal on Matrix Analysis and Applications* **45**(4), 2155--2183 (2024).
DOI: **10.1137/24M165096X**.

```text
https://epubs.siam.org/doi/10.1137/24M165096X
https://tore.tuhh.de/entities/publication/1dabce2f-756a-45e2-9864-be6f35145a89
```

Checked: matching publisher and author-institution metadata and abstract. First
online 2024-11-11. The paper addresses rigorous entrywise factor bounds and uses
accurate dot products and preconditioning. Its full methods have not been
transcribed here.

SVT V2 instead provides conservative norm-derived entrywise boxes in the positive,
simple, separated setting, with a common phase for each left/right vector pair.
Repeated individual vectors are deliberately unsupported; V1 handles their
subspaces. This is a baseline for the same class of output claim, not the RO24
algorithm or its claimed accuracy/performance.

## [R11] Tier V3 target: spectral and inverse norms

Siegfried M. Rump.
**Verified bounds for singular values, in particular for the spectral norm of a
 matrix and its inverse.**
*BIT Numerical Mathematics* **51**(2), 367--384 (2011).
DOI: **10.1007/s10543-010-0294-0**.

```text
https://link.springer.com/article/10.1007/s10543-010-0294-0
https://tore.tuhh.de/entities/publication/20883cce-df79-4410-b84a-328eee23797c
```

Checked: publisher title/author/DOI/volume/pages and abstract. The first-online
date is 2010-11-11; the issue date is June 2011. The paper presents several norm
verification approaches. SVT's elementary approximate-inverse/Neumann certificate
is derived in VERIFICATION.md; it is not advertised as a port of all those methods.

## [WED72] Background for subspace perturbation

Per-Åke Wedin.
**Perturbation bounds in connection with singular value decomposition.**
*BIT* **12**, 99--111 (1972).
DOI: **10.1007/BF01932678**.

```text
https://link.springer.com/article/10.1007/BF01932678
```

Checked: publisher author/title/DOI/volume/pages/year. Supports the distinction
between individual vectors and separated subspaces. The constants and signed-
dilation proof used by SVT are stated independently in VERIFICATION.md; no implicit
appeal to an untranscribed theorem is needed for their finite-arithmetic checker.

## [LAU61] Historical provenance and current matrix convention

Peter Läuchli.
**Jordan-Elimination und Ausgleichung nach kleinsten Quadraten.**
*Numerische Mathematik* **3**, 226--240 (1961).
DOI: **10.1007/BF01386022**.

```text
https://link.springer.com/article/10.1007/BF01386022
https://math.nist.gov/MatrixMarket/deli/Lauchli/information.html
```

The DOI/title/author/pages were matched in the preceding SVD source ledger and
primary bibliographic references; the current NIST definition confirms the modern
matrix convention. The analytic spectrum in CASES.md follows directly from
`L'*L=11'+mu^2*I`. The powers of two and the complex/tall/wide controls are suite
choices, not historical experiments reproduced from the 1961 article.

## [MPFR] Correct rounding, interpreted with a local binding audit

GNU MPFR manual, version 4.2.2 as displayed during preparation, floating-point
numbers and rounding modes.

```text
https://www.mpfr.org/mpfr-current/mpfr.html
```

Checked: correctly rounded operations behave as if computed exactly and then
rounded; represented inputs are treated as exact; nearest rounding has the stated
half-ulp error bound. This establishes an MPFR primitive contract, not proof that
a particular `mp` binding selects that mode. SVT00/SVT12 must inspect local source
and test ranges/precision. Never infer a library-wide contract from sample results.

## [LAPACK-LASQ1] Bidiagonal relative-accuracy comparator

Netlib LAPACK, DLASQ1 documentation.

```text
https://www.netlib.org/lapack/explore-html/d5/dce/group__lasq1_ga5a8c1474ef61ff7c59c17412ae456ca6.html
```

Checked: high relative accuracy in the absence of denormalization, underflow, and
overflow. Bidiagonal-array input is not equivalent to a dense SVD API. No new
LASQ1 binding is requested. An already available comparator may be logged only
with its arithmetic range and limitations.

## [REPO] Earlier public API snapshot and mandatory local re-audit

```text
https://github.com/nakatamaho/octave-mplapack
https://raw.githubusercontent.com/nakatamaho/octave-mplapack/main/docs/svd.md
https://raw.githubusercontent.com/nakatamaho/octave-mplapack/main/inst/@mp/svd.m
https://raw.githubusercontent.com/nakatamaho/octave-mplapack/main/docs/precision-semantics.md
```

The provided earlier SVD specification/source ledger described these interfaces.
Attempts to refresh the repository during this revision failed. Consequently this
bundle does NOT claim to have verified the current public or local source. SVT00
must record the actual checkout, supported methods, native module paths, rounding
modes, precision ownership, test commands, manual source, and package QA process.

## Source-to-implementation map

| Spec area | Source or direct derivation | Required qualification |
|---|---|---|
| S1/A6 integer generators | NRO11 Sections 5/4; exact identities | Deterministic suite parameter choices |
| S2 integer recurrence | JS14 family; exact recurrence checks | No invented structured oracle |
| S3 integer recurrence | LAH19 family; exact closed-form check | Issue year 2019, online 2018 |
| S4 DD path pair | DD11 class; direct construction | Only symmetric version has analytic singular values |
| A1 Pascal | PAS13 + TN05; binomial identity | Do not invent PAS13 SVD tables |
| A2 Vandermonde | TN05; dyadic node specialization | Guard significand budget for powers |
| A3 bidiagonal pair | LAPACK-LASQ1; orthogonal invariance | No transfer of an HRA guarantee to a dense solve |
| A4 Lauchli | LAU61/NIST; direct Gram identity | Normal equations are a negative control |
| A5 known spectrum | Orthogonal invariance, exact dyadic construction | Original fixtures, not named published tests |
| V1/V2/V3 targets | RL23 / RO24 / R11 | Baselines, not full paper reproductions |
| Certified primitive arithmetic | MPFR + explicit outward-padding proof | Source audit, range checks, no final-only padding |
| Exact endpoint persistence | Dyadic encoding derivation | Decimal display is not an outward certificate |

## SVT implementation ledger

The executable suite is an independently written adaptation of the families
and claim classes above. The selected matrix dimensions, dyadic scalings,
complex phases, global-scale controls, reference precisions, acceptance
targets, and exact replay representation are suite choices. They are not
reproduced published tables or a claim that the source papers' structured
solvers have been ported.

The implemented Tier V baselines are deliberately narrower than the motivating
papers: `svt_polar_weyl_v1` encloses singular values from the actual stored
factors; `svt_dilation_projector_v1` encloses separated positive cluster
projectors; `svt_dilation_factor_boxes_v1` gives conservative compatible
norm-derived boxes for simple pairs; and `svt_neumann_inverse_v1` verifies a
public solve output through an outward residual and a Neumann bound. These
methods do not claim interval-input coverage, full componentwise algorithms,
or the performance guarantees of the cited work.

The certificate implementation uses only the existing public `mp`, `mpbits`,
dense arithmetic, `svd`, and solve operations. MPFR/MPC values remain at one
operation precision; exact dyadic serialization is used for replay, while
binary64 conversion is limited to optional presentation plots. The verifier is
example-local and no public API, backend, rounding setter, dependency, or
installed header was added for SVT.
