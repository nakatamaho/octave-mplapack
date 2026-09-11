# NEIGT: Tier S/A nonsymmetric eigenproblems and Tier V-S/V-A verification

Version: 1.0. Prepared: 2026-09-10.
Target repository: `nakatamaho/octave-mplapack`.
Octave package: `mplapack-interop`.
Executor: the user's selected ChatGPT Luna model, xhigh reasoning, in Codex.
Task namespace: **NEIGT00--NEIGT25**.

## 0. Deliver the implementation, not another plan

Implement every mandatory S, A, V-S, and V-A target in this bundle. Deliver runnable
Octave examples, tests, proof checkers, documentation, and real execution reports.
A specification file, a bibliography, a placeholder verifier, an optional adapter,
or agreement between high-precision computations is not implementation completion.

Read, in this order:

1. `AGENTS.md` and every applicable more-local repository instruction.
2. This file and `neigt/COVERAGE.md`.
3. `neigt/CASES.md`, `neigt/GENERATOR-OO.md`, and `neigt/cases.json`.
4. `neigt/NUMERICS.md`, `neigt/ARITHMETIC.md`, and `neigt/CERTIFICATES.md`.
5. `neigt/ACCEPTANCE.md`, `neigt/verification-jobs.json`, and `neigt/MILESTONES.md`.
6. `neigt/SOURCES.md` and `neigt/PREPARATION.md`.

Paths above are relative to `docs/codex/` except repository instructions.
The JSON manifests define coverage and parameters; the mathematical documents
define their meanings. A conflict is a specification defect to report with a
reproducer. Do not choose whichever interpretation makes a failing test pass.

### What Tier V means here

Implement the complete, explicitly proved **conservative baselines** specified in
CERTIFICATES.md. They address the verification targets of the cited papers, but
are not line-for-line implementations of Rump's, Miyajima's, or Frommer's complete
algorithms, nor claims of their sharpness or cubic complexity. Method IDs and
`paper_algorithm_reproduction=false` are mandatory for those baselines.

S1 is different: implement the actual error-free triple-product construction of
Ozaki--Ogita, Theorem 1, with the documented dyadic specializations and paired-block
rule. Do not replace it by an unrelated prescribed-eigenvalue generator and call
that an implementation of Ozaki--Ogita.

All six requested V targets are mandatory. In particular:
- V-A2 finite generalized pencils must work even when public `eig(A,B)` is absent,
  through the verified solve-reduction specified here, not unchecked `eig(B\A)`.
- V-A1 includes compatible eigenfactor boxes, a true Schur certificate on separated
  simple cases, and a **block** Schur certificate on a defective cluster.
- V-S3 uses verified singular-value point/cell tests; it is not Frommer's full
  shifted-resolvent/numerical-range algorithm or a continuous-operator certificate.

## 1. Scope and boundaries

### Required work

Tier S: Ozaki--Ogita exact generators; exact integer/dyadic similarities with
simple, semisimple, defective, and two-nearby-Jordan-block regimes; nonsymmetric
tridiagonal Toeplitz plus a symmetric control; Forsythe split/scaled/zero regimes.

Tier A: Hadamard-similar upper bidiagonal; both exact Frank orientations;
Wilkinson companion with polynomial-coefficient diagnostics; Grcar;
Morimoto--Katori--Shirai model 1; stochastic and positive nonsymmetric Perron
controls. Include the complex diagonal-unitary similarity in the demo.

Tier V-S: counted all-spectrum inclusion; invariant-subspace/cluster inclusion;
verified pseudospectrum points and cells.

Tier V-A: compatible eigen/Schur/block-Schur factor boxes; finite nonsymmetric
pencil eigenvalues and subspaces; Perron root and normalized positive vector,
including a nontrivial left stationary vector.

### No backend/API expansion

Use existing public `mp`, `mpbits`, arithmetic, indexing, comparison, elementary
functions, `eig`, `svd`, `qr`, and linear solves. Audit actual availability. All new
numerical helpers live under the example tree. Do not modify MPLAPACK, MPFR, MPC,
gmpfrxx, system BLAS/LAPACK, `src/`, installed `@mp` methods, dependency headers,
or compiler floating-point semantics. No new installed precision/rounding/interval
API, eigensolver, QZ/Schur binding, external numerical package, or native bridge.

Example-local **candidate preparation** by QR and contour solves is explicitly
allowed for verification. It must never replace or relabel the measured `eig`
results. This is not authorization to implement another production eigensolver.

If the arithmetic contract cannot be proved from the local implementation, Tier V
is BLOCKED and the whole task cannot PASS. Independent S/A work may be completed
and reported honestly. Unsupported singular-B pencils and non-identifiable
individual vectors are deliberate domain boundaries, not excuses to skip the
mandatory nonsingular-B or cluster jobs.

No Python, SymPy, MATLAB, INTLAB, symbolic package, Internet, or plotting backend
may be required to run the delivered Octave suite. Optional preparation Python
in this bundle is not an Octave acceptance test. Do not copy proprietary INTLAB
code, GNU Octave gallery implementations, or paper pseudocode verbatim. Implement
mathematics independently and retain attribution. No paper PDFs are redistributed.

### Preserve previous work

NEIG, SVD, SVT, and any NEIGV files may or may not be implemented. Inspect actual
code and reports; a prior specification is not evidence of implementation or PASS.
Preserve public example entry points and all existing reports. Reuse suitable
constructors, matching, exact-widening, and SVT verification through a small facade
or a regression-tested internal extraction. Do not duplicate incompatible versions
or refactor unrelated code. This bundle is standalone when prior code is absent.

All new code, comments, diagnostics, help, reports, and repository documentation
must be English. Follow the repository license/style. Keep changes separable by
milestone. Suggested branch: `topic/neig-tier-sav-examples`, only if safe locally.
Do not reset/clean a dirty tree, switch away from uncommitted work, rewrite history,
force-push, push, merge, tag, publish, or replace a production installation.

## 2. Suggested implementation layout

Allocate four **different**, next-free example numbers; do not renumber old ones.
Reconcile actual test/documentation directory conventions in NEIGT00.

```text
examples/NN_neig_tier_s.m
examples/NN_neig_tier_a.m
examples/NN_neig_verified_vs.m
examples/NN_neig_verified_va.m
examples/neig_tiers/mp_neig_tiers.m
examples/neig_tiers/mp_neig_verify_examples.m
examples/neig_tiers/mp_neig_tiers_selftest.m
examples/neig_tiers/mp_neig_certificate_replay.m
examples/neig_tiers/private/net_*.m
test/test_neig_tiers.m
test/test_neig_verification.m
docs/neig-tiers.md
docs/neig-verification.md
neigt00-report.md ... neigt25-report.md
```

The facade is an example-tree interface, not a new installed package API.

```octave
pkg load mplapack-interop
addpath (fullfile (pwd (), "examples", "neig_tiers"));
r = mp_neig_tiers ("smoke");
assert (r.ok);
r = mp_neig_tiers ("demo", struct ("tier", "all", ...
  "output_dir", fullfile (pwd (), "artifacts", "neigt-demo-001"), ...
  "plot", false));
assert (r.ok);
v = mp_neig_verify_examples ("smoke");
assert (v.scope_ok);
mp_neig_tiers_selftest ();
```

Profiles: `smoke` (default), `demo`, `stress` (explicit opt-in).
Options: `tier=all|S|A|V-S|V-A|V`, `output_dir=""`, `plot=false`.
Reject unknown options. A filtered run has `scope_ok` and coverage metadata; it
cannot claim all-task completion. The all-tier `ok` includes mandatory V jobs.
Stress has exploratory coverage, not the smoke/demo accuracy contract.

Numbered examples locate helper paths relative to `mfilename("fullpath")` and
restore any path/precision changes on return and exceptions. Reusable functions
must not call process-wide `exit`. Test wrappers must return nonzero process status
on failure, not merely print FAIL.

## 3. Local API and environment audit

The supplied historical specifications described real/complex three-output
`[V,D,W]=eig(A, mode)` with `mode="balance"|"nobalance"`, maximum-operand precision
arithmetic, identity construction `mp(existing_mp)`, and one-/three-output SVD.
These are **historical expectations**, not a verified current GitHub snapshot.
The preparation browser could not retrieve the target repository this turn.

Read local source and run isolated probes for:
- `mpbits` state, per-object work precision, scalar extraction, exact widening;
- real/complex eig, left-vector convention, both modes, aliases and input immutability;
- real/complex QR and solves, public Schur and generalized eig if present;
- SVD values and three-output economy form, returned V versus VT;
- scalar add/subtract/multiply/divide/sqrt/abs/comparisons and their actual rounding;
- MP transcendental functions for nonrigorous analytic reference evaluation;
- manual source/generation, example runner, source-package and clean-install tools.

Record `which`/module paths, actual package/dependency versions where available,
commit/dirty state, OS, architecture, commands, and existing focused-test results.
Unknown version data stays unknown. No speculative build command or dependency
upgrade. Missing supported essentials or a binding defect gets a minimal reproducer.

## 4. Non-negotiable numerical meanings

1. Keep requested standard form, realized exact model, frozen solver input, computed
   outputs, auxiliary candidates, and certificate targets distinct and hashed.
2. Generation precision is not eig work precision. Fix each OO model once at the
   manifest's generation precision and reuse it for all work precisions.
3. Do not widen by decimal round-trip, rebuild ideal data over rounded data, solve
   again at higher precision under an old label, or silently change work precision.
4. A genuine Jordan block has no full eigenvector basis. Use subspaces/block Schur;
   do not require diagonalization or compute a finite "true" simple-root condition.
5. Orthogonal projectors onto invariant subspaces are not generally `V_J*W_J'`.
   That expression is a spectral projector only under the requisite dual-basis
   normalization; distinguish orthogonal and oblique projectors explicitly.
6. Compare spectra by MP one-to-one **minimum-bottleneck** matching. Never real-part
   sorting or independent nearest-neighbor matches that reuse a reference root.
7. Balance/nobalance apply to ordinary eig runs. General diagonal similarity changes
   coordinates and pseudospectra; a certificate always names the original target.
8. Approximate or high-relative-accuracy results are not verified inclusions.
   Every certified inequality must use the proved arithmetic layer.
9. A Gershgorin group with k counted roots does not prove those roots are equal.
   Exact multiplicity from generator algebra and counted numerical inclusion are
   separate claims. A certified zero-containing disk does not prove a zero root.
10. No forced binary64 failure, required imaginary-root count, automatic-balancing
    improvement, monotonically decreasing errors, or forged execution evidence.

## 5. Output and completion

With a new output directory write:

```text
summary.tsv
eigenvalues.tsv
verification.tsv
environment.json
coverage.json
report.md
inputs/                 # exact dyadic serialized targets and generator metadata
certificates/           # proof witnesses, exact endpoints, method IDs and hashes
plots/                  # only when requested; never part of the proof
```

Use schema `neigt-v1`. Decimal fields are approximate displays at a recorded
precision; exact certificate data use ARITHMETIC.md's binary encoding. Preserve
raw solver order and output hashes. Distinguish solver status, model exactness,
reference status, certificate validity, certificate usefulness, and coverage.
Missing rows are not successful skips. Refuse to overwrite prior results.

Every milestone has a focused test, a report, and PASS/FAIL/BLOCKED. Continue after
PASS without routine confirmation. Stop dependent work on a genuine blocker;
finish independent safe work where useful. No silent threshold weakening or
parameter editing. A mathematical/specification defect must be demonstrated.

Final acceptance requires all 120 smoke and 168 demo measured ordinary eig rows,
all 26 declared verification jobs per profile, the extra jobs' documented solves,
adversarial/replay tests, existing regressions, and isolated clean-package QA.
References/candidate preparation/certification are separately counted and timed.
Report stress and plotting as NOT_RUN unless actually executed.

Finish with actual changed paths, exact commands, measured S/A and V results,
all 26 milestone states, the clean-install evidence, and honest limitations.
