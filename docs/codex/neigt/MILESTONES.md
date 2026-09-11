# NEIGT00--NEIGT25: sequential implementation and evidence

One active milestone at a time. Preserve separable commits/changes and write its
root-level `neigtXX-report.md` after running its gate. Continue after PASS without
routine confirmation. Never claim a later gate passed because a previous report
or a Markdown specification exists. An implementation defect produces a minimal
reproducer; dependent milestones stop, independent safe work may be reported.

For each report record task/version, branch, starting and tested commit/dirty
state, paths changed, module resolution, commands, exit statuses, measured results,
coverage, proof obligations enforced, PASS/FAIL/BLOCKED, and limitations. Do not
rewrite earlier reports to hide failures. If a report already exists, preserve it
and use a dated/suffixed attempt with an index linking the history.

## NEIGT00 — repository, sources and real API audit

Read all applicable repository instructions, prior NEIG/SVD/SVT/NEIGV code and
reports, manifest/source package tools, documentation sources and numerical APIs.
Audit actual real/complex eig outputs and balance options, scalar precision/RN
contracts, QR, solves and SVD. Record actual module paths; separate a source-tree
wrapper from an installed-package test. Generalized eig and public Schur are
optional candidate/comparison paths, not prerequisites. Check all source ledger
DOIs against the provided metadata; access failures are recorded, not invented.

**Gate:** local essentials and existing focused tests pass; scope and exact reuse
plan recorded; no unauthorized dependency/API changes. Missing Octave/package or
unknown required rounding behavior is BLOCKED, never PASS.

## NEIGT01 — integration skeleton and manifest coverage

Add the additive facade, strict options, profile dispatch and selftest skeleton.
Allocate four different next-free example numbers and reconcile actual test paths.
Parse the two JSON manifests without lossy numeric conversion; dyadic parameters
are strings/exponents. Validate 20/21/8 cases and 120/168/64 row counts, and 26 V
jobs for each mandatory profile. A not-yet-implemented tier is NOT_IMPLEMENTED,
not silently skipped under `all`.

**Gate:** option/error/state/path/coverage tests pass; filtered scope_ok is distinct
from all-tier ok; existing entry points and reports remain intact.

## NEIGT02 — exact construction, freezing and widening

Implement deterministic Sylvester Hadamard, N, integer unit-triangular X/Y,
exact dyadic models, bit-length guards, immutable frozen inputs and exact widening.
Record generation/model/work roles separately. Implement independent exact-product
checks with sufficient guard precision, including bounds on intermediate partial
sums rather than only final entries. Native is a once-rounded model.

**Gate:** X*Y=Y*X=I, Hadamard orthogonality, real/complex widening value identity,
2^-1500 retention, below-guard classification, aliases and exception restoration.
No decimal round-trip widening or silently higher-precision work inputs.

## NEIGT03 — matching, metrics and reference engine

Implement MP minimum-bottleneck matching with exhaustive small checks and the
duplicate/missing-root traps. Add right/left residuals with correct conjugation,
condition status, ordinary cluster QR/projector diagnostics and reference roles.
Never mutate eig outputs. Log references and candidate work separately.

**Gate:** synthetic complex/real triples and deliberate wrong left conjugation
are detected; MP-only tiny distances and exhaustive assignments pass; zero-root
relative error and defective simple-root condition are not misreported.

## NEIGT04 — actual Ozaki--Ogita generator

Implement GENERATOR-OO.md completely, including phi/psi/ufp ratios, theorem
predicate, alpha/sigma, two-step rounding, paired real blocks and both exact
triple-product checks. Fix generation precision independently of eig precision.
Implement the 53-bit generator with audited public MP or native scalar RN as
specified; using native generation here is not an MP eig fallback.

**Gate:** all six smoke/demo generator fixtures have exact product checks,
requested/realized differences and frozen hashes. OO128_CLOSE realizes exactly
the 2^-80 first-pair gap while removing the 2^-120 requested increment. Both
balance-mode highest-work forward gates pass. Never swap in a generic generator.

## NEIGT05 — exact simple, repeated, defective and merged clusters

Implement all four SIM regimes through the same exact similarity. Test algebraic
multiplicities and representative nilpotent powers using guarded integer/dyadic
arithmetic. Separate success semantics by regime. Build independent model subspace
checks without allowing those bases into positive certificate candidate paths.

**Gate:** all SIM ordinary smoke/demo gates pass; an exact Jordan block is not
reported as diagonalizable; semisimple multiplicity is not labeled defect.

## NEIGT06 — Toeplitz and symmetric control

Implement the original and directly constructed symmetric matrices, stable MP
sine/cosine references, closed-form left/right vectors and analytic conditions.
Verify A*D=D*B by exact scaling. Test n=2 and several orders before full profiles.

**Gate:** spectrum, condition and original-coordinate residual gates pass in both
modes; condition(A), condition(D) and individual eigenvalue conditions remain
separate. No mandatory balancing-improvement claim.

## NEIGT07 — Forsythe extension and zero limit

Reuse the existing definition if compatible. Add nonzero original/scaled and zero
limit in the same family. Test odd/even circle references in unit tests, exact
r/epsilon and the diagonal-similarity identity. Constructor-only stress conversion
must identify epsilon underflow at n=32,a=40 as a changed native model.

**Gate:** nonzero circle gates and zero-limit defective gate pass; no nonexistent
full eigenbasis is demanded; repeated circles are matched bijectively.

## NEIGT08 — reuse Hadamard and Frank without semantic drift

Connect HAD_BIDIAG, both explicit Frank orientations and the independent
Hermite-Jacobi reference. Check small characteristic recurrences and reflected
transpose identity. Retain existing examples and their commands. Prepare, but do
not yet require, the complex Hadamard wrapper for NEIGT22.

**Gate:** existing regressions plus new matching/precision/condition gates pass.
Gallery may be a comparator, not copied implementation or unexamined oracle.

## NEIGT09 — Wilkinson and polynomial backward error

Implement exact guarded coefficient recurrence, small coefficient fixtures and
Horner zero checks at sufficient guard precision. Native is a single rounding of
the exact model. Implement rootwise complex coefficientwise backward error under
the explicit non-monic perturbation convention in CASES.md.

**Gate:** coefficient/source spectrum invariants and smoke/demo gates pass;
model/frozen input errors and polynomial/matrix backward errors are separate.
Do not call ordinary eig a companion-QR implementation from the cited paper.

## NEIGT10 — Grcar and MKS model 1

Reuse Grcar integers. Implement MKS's nilpotent shift plus rank-one matrix and
reduced polynomial, exact determinant identity tests and rational polynomial gcd.
Retain exact zero multiplicity separately from numerical zero disks. Use an
independently solved smaller companion for nonzero reference roots.

**Gate:** zero/nonzero decomposition, exact small determinant checks, square-free
mandatory reduced polynomials, both-mode ordinary gates pass. The nonzero roots
must not be confused with rounding-induced apparent roots near zero.

## NEIGT11 — stochastic and positive Perron models

Implement the two lazy cyclic blocks, nonuniform teleportation vector, positive
stochastic model and nonunitary positive similarity. Derive and test the spectrum,
nontrivial stationary solve, exact row sums and positivity at model precision.
Preserve the difference between rounded native and exact stochastic matrices.

**Gate:** known spectrum, stationary equations, model gap and standard ordinary
gates pass. Do not substitute r for the stationary vector or call every small-gap
matrix strongly nonnormal without measured evidence.

## NEIGT12 — complete ordinary profiles and preliminary reporting

Run all core smoke/demo rows, including the complex demo control. Implement raw
hash binding, numerical reference status, environment and provisional reports.
No `all` PASS is allowed while mandatory verification is not implemented. A
`numerics_only_complete` field may honestly record successful S/A coverage.

**Gate:** 120 smoke and 168 demo rows present; every fixed numerical/generation
gate passes; missing/failed rows cannot disappear from a summary.

## NEIGT13 — audited outward arithmetic and exact serialization

Implement ARITHMETIC.md or reuse an equivalent actually audited SVT implementation
through a tested example-local facade. Confirm real RN primitive/range semantics
from source, not only numerical probes. Implement rectangles, explicit interval
products/norms, verified inverse residual, exact dyadic encoding/decoding and
proof-witness schema. No global rounding setter or installed interval API.

**Gate:** exact rational corner/adversarial tests, complex conjugation, range and
zero-witness tests, serialization round-trip and restart replay pass. Document
every assumption and its source/code enforcement. Unproved arithmetic is BLOCKED.

## NEIGT14 — V-S1 all-spectrum counts

Implement verified similarity residual, Gershgorin disks, overlap supergraph and
homotopy counting. Distinguish valid broad coverage from singleton usefulness.
Never count approximate eigenvalues without proving the basis nonsingular.

**Gate:** VS1-01..08 pass on raw highest-work nobalance candidates; all n roots are
covered exactly once, first OO close pair remains separated, all negative counting
and inverse tests pass. Higher-precision rescue data cannot replace those jobs.

## NEIGT15 — bounded candidate preparation and invariant graph

Implement selected-cluster candidate QR, contour solves, bounded candidate Newton
correction and alternative complement strategy. Implement the Riccati graph
contraction with the nonconjugating Kronecker transpose and quadratic bound.
Measure every auxiliary operation separately; roots/model basis are not trusted.

**Gate:** exact synthetic graph checks and computed SIM_REPEAT/SIM_JORDAN jobs
prove nontrivial invariant bases; deliberately wrong complex transpose, singular
preconditioner and failed contraction do not produce certificates.

## NEIGT16 — cluster identification, nilpotent power and projectors

Complete exact root counting/separation of M and D2, centered-power spectral disks
and raw-basis orthogonal-projector bound. Finish merged two-Jordan and MKS-zero
jobs with computed candidates, not generator columns.

**Gate:** all VS2-01..04 pass their widths/projectors, including merged-group
physical-spread allowance; graph existence alone is not claimed as an isolated
cluster. Invalid separation and full-space triviality traps pass.

## NEIGT17 — V-S3 verified pseudospectrum points and cells

Reuse the actual audited SVT polar/Weyl checker or implement the included bounded
baseline. Bind exact expression zI-A, candidate SVD and proof residual. Add closed
point classification and the 1-Lipschitz cell extension.

**Gate:** VS3-01..04 achieve their prescribed inside/outside states, positive-area
cells are genuinely covered, straddling and boundary cases remain inconclusive
when warranted. A grid does not become a global boundary proof.

## NEIGT18 — V-A1 compatible eigenfactor boxes

Run k=1 graph proofs for all simple roots, assemble compatible E and Lambda,
verify interval E nonsingularity and enclose dual W=(E^-1)'. Record gauges and
simultaneous-existence proof rather than independently normalized columns.

**Gate:** real/complex VA1 simple eigenfactor portions pass; wrong phases,
permutations and repeated-root individual claims do not yield false factors.

## NEIGT19 — V-A1 true Schur and defective block Schur

Implement interval evaluation of exact QR with strictly positive normalization
bounds. Simple E yields genuine triangular Schur T; defective Y1 completion yields
only block-upper-triangular T. Lower zeros need an algebraic invariance proof.

**Gate:** complete VA1-01..03 pass, including true complex-coordinate Schur and
nontrivial defective block Schur. No scalar triangular/diagonal label for an
unreduced defective block, and no normalizing interval across zero.

## NEIGT20 — V-A2 finite generalized pencils

Implement proved B nonsingularity and the reduction enclosure for B^-1 A, then
feed the rectangle into the same spectrum/graph checkers. Map left vectors back
and evaluate original-pencil residuals. Direct generalized eig is optional only.
For the defective job, counted graph blocks and the proved regular finite pencil
provide all-root coverage without requiring a full eigenvector basis.

**Gate:** VA2-01..03 pass, with original A/B hashes, all finite root counts and
nontrivial defective subspace. Singular B and bad inverse tests fail closed.
No missing public eig(A,B) excuse for skipping the verified reduction.

## NEIGT21 — V-A3 Perron root and vector

Implement positive-graph irreducibility, Collatz--Wielandt and normalized positive
pair contraction. Process original/transposed stochastic and positive-similarity
matrices. A root-only interval does not satisfy the vector requirement.

**Gate:** VA3-01..04 pass widths, positivity and normalization; negative entries,
reducibility, nonpositive boxes and bad Jacobian inverses cannot be certified.
Perron-only evidence is not used to certify the second eigenvalue.

## NEIGT22 — all tiers integrated and proof audit

Run all core rows and all 26 V jobs per profile in one invocation. Include the
complex Hadamard control, frozen-native exploratory certificates and all negative
proof tests. Review every certificate function against its theorem/preconditions,
recording code locations, not merely a green test count.

**Gate:** complete S/A/V coverage, strict scope_ok/ok semantics, no missing
precondition, no hidden native fallback. Stress remains opt-in/NOT_RUN.

## NEIGT23 — output, independent replay and presentation

Finalize TSV, exact serialized inputs/certificates, schema/version/hash binding,
new-directory-only output, restart replay and report formatting. Replay must not
call eig or reconstruct a different ideal matrix. Optional plotting must convert
only at the display boundary, using MP log10 of positive error before double.

**Gate:** round-trip/replay/tampering/output-conflict tests pass; plot=false is
headless; graphics failure cannot invalidate numerical state or proof metadata.
Test plots only when an actual backend is available and report NOT_RUN otherwise.

## NEIGT24 — tests, documentation and source-package integration

Integrate four numbered examples and focused tests into actual existing runners.
Update authoritative manual sources and regenerate derived docs with repository
commands. Preserve all old numerical/regression paths. Build source package and
inspect contents for helper directories, manifests, tests and required docs.

**Gate:** existing relevant NEIG/SVT regressions, new tests, documentation example
runner, format/tree/doc checks and source-package content checks pass. No API or
backend inventory changes apart from documented example listings.

## NEIGT25 — isolated clean-package QA and final report

Use an owned temporary install prefix and extracted source/example tree. Show
`which` evidence that neither mp nor helpers resolve from the developer checkout
by accident. Run complete smoke/demo and all verification jobs there; preserve
failure logs. Do not overwrite a production prefix or publish a release.

**Gate:** all required clean-package tests pass, exactly 26 milestone statuses are
reported with actual tested revisions, and final task ok agrees with coverage and
proof results. Include measured table, commands, changed paths, certificates and
honest limitations. Unexecuted environments/tests are NOT_RUN, never PASS.
