# SVT00--SVT19: implementation milestones

One milestone at a time. Before advancing, run its gate and write
`svtXX-report.md` at the repository root. Each report records branch, starting and
validated code state, changed paths, actual command lines, environment/module
resolution, observed metrics, PASS/FAIL/BLOCKED, and limitations. Do not report a
future commit hash or claim execution from a preparation script.

A scientific or arithmetic-contract failure blocks dependent claims. Independent
S/A work can proceed when only a V prerequisite is unavailable, but the full task
cannot be PASS. No routine confirmation is required after a passed gate.

## SVT00 -- local audit and non-destructive integration map

Read AGENTS.md, local instructions, earlier NEIG/SVD docs, implemented examples,
SVD/eig/solve tests, precision semantics, package builder, manual sources, example
QA, and actual loaded modules. Probe public real/complex economy/full/one-output
SVD. Audit the scalar RN/sqrt/range contract and exact widening from local source.

Create a reuse/path map for existing constructors and metrics. Allocate three
unoccupied example numbers. Record missing capabilities without adding APIs.

Gate: focused existing tests pass; executable/module paths and public API contracts
are documented; reuse plan preserves old behavior. A missing Octave/backend is
BLOCKED, not PASS. An unproven scalar contract is a V-specific blocker.

## SVT01 -- facade, manifest, precision, and output safety

Implement validated entry points, tier/profile dispatch skeleton, precision cleanup,
exact widening, and no-overwrite output-directory handling. Parse/validate the
normative manifest or generate an equivalent internal manifest with an equality test.
No all-case result may be marked complete before every case exists.

Gate: invalid options, injected errors, ambient precision below/above input,
alias preservation, filters, new-directory safety, and path restoration tests pass.
Verify smoke=20 cases/120 rows and demo=23 cases/184 rows before adding solvers.

## SVT02 -- exact construction utilities and identity metadata

Implement Sylvester H/G, exact power-of-two/scaling helpers, integer recurrence
support, ceil-log2 guards, known projectors, and input/model identity metadata.
Use dense MP matrices, not matrices of scalar wrapper cells.

Gate: exact orthogonality, signed phase identity, common-denominator construction
bounds, below-guard rejection, and sufficient-precision equality tests pass.
No native floating construction of a supposedly exact irrational/rational fixture.

## SVT03 -- measured runner and provisional reference/metric engine

Connect one-output and economy solves, frozen-input references, model references,
MP reevaluation, errors, residuals, orthogonality, timings and statuses. Use a few
small synthetic fixtures before enabling the literature families. References are
explicitly `consistent_reference` until certified later.

Gate: dimension/type/order/finite checks, complex V rather than VT conventions,
zero-reference handling, below-resolution classification, residual perturbation
and timing separation tests pass. No hidden double norm/comparison path.

## SVT04 -- Tier S1: three NRO block variants

Implement two-, three-, and graded-level block matrices, stable analytic spectra,
reciprocal pairing, exact inverse construction checks, and native equality checks.
Run all S1 smoke/demo precisions and modes. Preserve repeated groups.

Gate: exact model/native identity where promised; analytic forward gates and common
residual gates pass at highest precision; all actual measured rows recorded.
No forced low-precision failure. Test that the unstable subtraction formula is not
used for the small reference singular values.

## SVT05 -- Tier S2: Jacobi--Stirling

Implement z=1 recurrence, indexing, exactness budget and leading 5-by-5 fixture.
Run smoke/demo; record exact input vs any native rounding without inferring
spectral preservation from integer-looking values.

Gate: constructor/unit-triangular checks and provisional high-precision accuracy
gates pass; source attribution does not claim a structured HRA solver was ported.

## SVT06 -- Tier S3: Lah

Implement unsigned Lah recurrence and fixtures; add integer budget and native
input accounting. Run smoke/demo; preserve the unit diagonal/rank proof.

Gate: recurrence and closed-form checks on small exact integers, high-precision
accuracy, residuals, and precise input identity tests pass.

## SVT07 -- Tier S4: symmetric/nonsymmetric DD pair

Implement the two paths, stable symmetric reference, exact minimum tau, nonsymmetric
reference, and deliberate tau loss in native and 128-bit demo construction.
Prove/test rank n-1 of the tau=0 represented matrix by leading minors/row sums.

Gate: exact-model high-precision targets pass; rounded-input rows are neither
silently skipped nor judged against tau as if their input still contained it.
Do not label the nonsymmetric minimum singular value tau.

## SVT08 -- Tier A1: Pascal pair

Implement exact lower/symmetric Pascal and prove/test P=Q*Q'. Run both versions
with references and input metadata. Check the cross-family squared-spectrum
identity at sufficient precision, without introducing a general normal-equations
SVD path.

Gate: exact fixtures, symmetry, positivity/rank proofs, provisional accuracy and
existing regressions pass. Correct the source wording: the Pascal paper is not
claimed to contain the exact SVD table used by this suite.

## SVT09 -- Tier A2/A3: Vandermonde and graded bidiagonal pair

Implement dyadic nodes and powers, raw/mixed bidiagonal matrices and exactness
proofs. Run required sizes and modes. Keep specialized bidiagonal comparator
availability informational; do not install or bind a new driver.

Gate: exactness guards, raw/mixed model spectrum agreement, high-precision recovery,
and type/precision tests pass. No generic dense HRA guarantee is invented.

## SVT10 -- Tier A4/A5: reuse/extend Lauchli and Hadamard controls

Reuse proven existing code where practical. Add tall/wide Lauchli, geometric,
close/repeated, rank-four/rank-five cases and exact projectors. Add the explicitly
named normal-equations negative control outside the reference/timed path.

Gate: all cases meet provisional high-precision targets; repeated-column rotation
leaves group tests unchanged; ideal rank is not forced on rounded native inputs.
Full/economy shape and extra structural null-direction tests pass.

## SVT11 -- Tier A6: bounded-integer NRO companion-like family

Implement the deterministic k/nu construction, Horner certificate, entry bound and
published equation-(82) fixture/inverse. Run the small and hard cases.

Gate: exact unimodularity proof checks and exact inverse fixture pass; native input
is unchanged; provisional spectrum/residual gates pass. A merely small approximate
determinant is not accepted as the determinant proof.

## SVT12 -- private outward arithmetic, proof audit, exact serialization

Implement V0.1--V0.3 and V4 from VERIFICATION.md. Bind audited correctly rounded
primitives to conservative outward endpoint/rectangle operations and matrix/norm
bounds. Implement exact dyadic encoding/decoding and replay inputs.

Gate: every arithmetic precondition has a checked code path; rational corner
and cancellation tests pass; invalid-domain/range tests fail closed; exact endpoint
serialization round-trips. Complete a written proof-to-code audit. No ordinary
GEMM plus final epsilon inflation, external interval dependency, or new rounding API.

## SVT13 -- V1 all-singular-value enclosures and certified references

Implement the polar/Weyl checker without computing polar factors. It must consume
actual stored approximate factors and target input. Add broad/narrow status handling.
Certify the reference solves and replace provisional final error claims by valid
bounds from those enclosures. Keep numerical consistency data for comparison.

Gate: known-spectrum tests are enclosed, malformed factors fail closed, all required
highest-precision S/A spectrum certificates meet their width targets. Recheck every
S/A recovery target with certified references. Do not omit a hard family.

## SVT14 -- V1 cluster projectors

Implement signed dilation separation with all complementary +/- values and
structural zeros, and raw-factor projector radii. Do not divide by an internal
cluster gap. Handle the empty-complement full-space branch explicitly.

Gate: close/repeated Hadamard and tall/wide Lauchli group certificates meet targets;
rotation/permutation tests pass; an exterior-gap collapse is INCONCLUSIVE.
Known exact projectors corroborate the rigorous bounds.

## SVT15 -- V2 compatible simple-factor boxes

Implement positive simple-singular-value boxes and common-phase semantics. Return
unsupported individual identification at multiplicity while preserving V1 results.
Add real/complex rectangular tests and nontrivial geometric/graded NRO tests.

Gate: required simple-factor radius targets pass; common phase invariance holds;
single-sided phase corruption is detected; no unique repeated-vector claim.
Reports explicitly state that these are conservative norm-derived entrywise boxes,
not a full implementation of the Rump--Ogita componentwise algorithm.

## SVT16 -- V3 norms, inverse residual, and sigma_min bound

Implement norm intervals and Neumann inverse verification using public solve outputs.
Record inverse work precision separately. Use verified norm bounds for X.
Add good/bad inverse and singular/rectangular negative controls.

Gate: all required invertible cases certify r<1 and positive sigma_min lower bound;
the published exact inverse fixture agrees; no singular/bad input gets false PASS.
A failed sufficient condition is not labeled proof of singularity.

## SVT17 -- complex/range controls and complete measurement output

Enable all 23 demo cases, including phased tall Lauchli and NRO scales +/-600.
Run every smoke/demo row and V job. Write versioned TSV/JSON/report/environment
artifacts, canonical hashes, full target/factor snapshots, and checker replay.
Add optional plots with only presentation-boundary conversions.

Gate: exactly 120 smoke and 184 demo measured SVD rows; references/V jobs counted
separately; all fixed numerical/certificate targets pass; wrong/missing rows fail
coverage. Headless plot=false is tested. No overwritten prior artifacts.

## SVT18 -- examples, documentation, and regression integration

Add the three allocated top-level examples. Each has a small reproducible default
and clear pointers to full demo output. Integrate tests into the existing runner;
do not replace or bypass prior NEIG/SVD coverage. Update the authoritative manual
source and regenerate derived Markdown using the actual local tools.

Gate: focused tests, existing relevant regressions, document generation checks, and
all documentation examples pass. Source ledger correctly distinguishes paper
formulas, suite adaptations, HRA interpretation, and implemented verifier baselines.

## SVT19 -- isolated package QA and final evidence

Build using the existing source-package process. Inspect archive contents for
examples/helpers/tests/docs. Run from an extracted source/example tree with an
isolated installed package, not accidentally through checkout paths. Show `which`
evidence. Do not overwrite production installations or publish.

Gate: clean-package smoke, demo and all mandatory V checks pass; existing tests and
examples remain green; no unauthorized API/backend/dependency changes. Complete
20-milestone table, row counts, numerical results, source identities, actual commands,
and NOT_RUN list (stress/OS/graphics as applicable). Final `results.ok` must agree
with process exit status and reported coverage. No missing execution labeled PASS.
