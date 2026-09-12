# SVT: Tier S, Tier A, and Tier V SVD examples for mplapack-interop

## 0. Execution contract

Target repository: `nakatamaho/octave-mplapack`.
Octave package: `mplapack-interop`.
Executor: the user's selected Luna model, xhigh reasoning, in Codex.
Prepared: 2026-09-10. Task namespace: **SVT00--SVT19**.

Implement runnable examples, focused tests, verification examples, documentation,
and measured reports. Do not stop at a plan. Read this file, the four companion
specifications, and the JSON manifest before implementation:

- `docs/codex/svt/CASES.md`: exact matrix definitions and reference contracts.
- `docs/codex/svt/VERIFICATION.md`: finite-arithmetic enclosures and proofs.
- `docs/codex/svt/MILESTONES.md`: sequential implementation gates.
- `docs/codex/svt/SOURCES.md`: checked DOI and source-to-claim ledger.
- `docs/codex/svt/cases.json`: normative smoke/demo/stress case manifest.

The requested tiers are all in scope. Tier V is not satisfied by a bibliography,
a high-precision comparison, a small residual, an empty adapter, or an optional
INTLAB dependency. Implement the bounded, self-contained verification methods
specified in VERIFICATION.md. They are deliberately modest, rigorous baselines,
not reproductions of all algorithms in the three cited Rump papers.

### Relationship to previous work

Preserve NEIG examples, existing difficult-SVD examples, SVD00--SVD10 reports, and
all unrelated changes. This task may extend an implemented SVD suite, or provide
an additive suite when only its earlier specification exists. Never assume that
having a Markdown specification means the implementation exists or passed.

During SVT00 choose one canonical implementation of each reusable constructor and
metric. If existing helpers are suitable, reuse through a compatible facade or a
small regression-tested internal extraction. Do not duplicate constructors with
subtly different indices, precision rules, or matrix conventions. Preserve all
existing user-facing entry points. Keep the new `mp_svd_tiers` facade even when it
adapts existing code. Do not refactor unrelated eigenvalue code.

The preparation environment could not refresh the public GitHub checkout during
this revision. Earlier supplied specifications describe an API snapshot, not proof
of the executor's current checkout. Audit local source, module resolution, and
actual behavior. Do not infer current versions from this document's date.

## 1. Scope and boundaries

### 1.1 Required coverage

**Tier S**: Nishi--Rump--Oishi (NRO) integer block matrices with two-level,
three-level, and graded singular spectra; Jacobi--Stirling second-kind matrices;
Lah matrices; symmetric and nonsymmetric shifted diagonally dominant paths.

**Tier A**: lower and symmetric Pascal; dyadic-node Vandermonde; raw and mixed
graded bidiagonal; tall and wide Lauchli; known geometric, close, repeated,
rank-four, and rank-five Hadamard fixtures; bounded-integer NRO companion-like
matrices. Include complex phase and global scaling controls in demo.

**Tier V**:

1. V1: enclosures of all singular values and gap-certified positive singular
   subspace projector bounds, including internal multiplicity.
2. V2: existence and entrywise boxes for compatible SVD factors in the separated,
   positive, simple-singular-value setting. Use a common phase for each U/V pair.
3. V3: spectral-norm bounds, nonsingularity verification, inverse-norm bounds, and
   a certified positive lower bound for the smallest singular value when the
   Neumann residual test succeeds.

### 1.2 No backend expansion

Use only the existing public `mp`, `mpbits`, arithmetic, matrix, SVD, and solve
interfaces. New helpers belong in the example tree. Do not modify MPLAPACK,
gmpfrxx, MPFR, MPC, BLAS/LAPACK, dependency headers, `src/`, or installed `@mp`
methods. No new SVD driver, Jacobi backend, global precision hook, rounding-mode
API, native bridge, or package dependency. No production reinstall.

The verifier's local endpoint/rectangle structs are private example helpers,
not a public interval library or an INTLAB clone. The implementation uses
rigorous outward bounds from audited correctly rounded scalar operations; a
rounding-mode setter is not required. If the necessary scalar contract cannot
be established, Tier V is BLOCKED, not silently replaced with heuristic padding.
Independent Tier S/A work may continue, but the overall task is not PASS.

No Python, SymPy, MATLAB, symbolic package, interval package, Internet, or plotting
backend is required to run the final Octave examples. Preparation Python files
are mathematical checks, not substitutes for Octave acceptance. Do not vendor
TNTool or copy INTLAB, GNU Octave gallery, or article source code. Optional existing
structured comparators may be logged but may not become runtime dependencies.

### 1.3 Scientific restrictions

- Never substitute a known spectrum for a computed result.
- No `eig(A'*A)` oracle or production SVD. A named Lauchli negative control may
  form normal equations; Gram matrices of computed U/V in a proof are allowed.
- Do not add eigenproblem balancing flags to SVD. General diagonal left/right
  scaling does not preserve singular values.
- No forced binary64 failure, monotone-improvement requirement, or fixed count of
  numerically zero singular values.
- No unique-vector acceptance criterion for a repeated singular value.
- Do not label agreement at two precisions, HRA theory, or an ordinary residual
  as a verified enclosure.
- Do not attribute these verifier baselines to Rump--Lange or Rump--Ogita as an
  implementation of their algorithms. Use the explicit method IDs below.
- Broad valid intervals and failed sufficient conditions are legitimate numerical
  outcomes, not proof that an SVD does not exist. Mandatory resolved cases must
  nevertheless pass their declared targets.

All source, comments, help, diagnostics, reports, and new repository documents
must be English. Follow AGENTS.md and more-local instructions. Preserve dirty
worktrees and untracked files. Do not reset, clean, rewrite history, push, merge,
tag, publish, or change production installations. Use a topic branch only when
safe; suggested name: `topic/svd-tier-sav-examples`.

## 2. Entry points and layout

Suggested layout; reconcile actual test paths and next free example numbers:

```text
docs/codex/SVT-LUNA-XHIGH.md
docs/codex/SVT-GOAL.md
docs/codex/svt/{CASES,VERIFICATION,MILESTONES,SOURCES}.md
docs/codex/svt/cases.json
examples/NN_svd_tier_s.m
examples/NN_svd_tier_a.m
examples/NN_svd_verified.m
examples/svd_tiers/mp_svd_tiers.m
examples/svd_tiers/mp_svd_tiers_selftest.m
examples/svd_tiers/mp_svd_verify_examples.m
examples/svd_tiers/private/svt_*.m
test/test_svd_tiers.m
test/test_svd_verification.m
docs/svd-tiers.md
docs/svd-verification.md
svt00-report.md ... svt19-report.md
```

Each NN is separately allocated. Do not overwrite, renumber, or reuse an occupied
example number. Reports must identify their validated code state.

```octave
pkg load mplapack-interop
addpath (fullfile (pwd (), "examples", "svd_tiers"));
results = mp_svd_tiers ("smoke");
results = mp_svd_tiers ("demo", struct ("tier", "all", ...
  "output_dir", fullfile (pwd (), "artifacts", "svt-demo"), "plot", false));
verification = mp_svd_verify_examples ("smoke");
mp_svd_tiers_selftest ();
assert (results.ok);
```

`mp_svd_tiers` accepts profiles `smoke` (default), `demo`, `stress` and options:
`tier` = `all|S|A|V`; `output_dir` = empty or new directory; `plot` = logical.
Unknown options are errors. A tier filter is partial coverage and cannot certify
all-task completion. `tier=all` includes S/A rows and the mandatory V jobs. `tier=V`
uses the specified small/selected fixtures without relabeling that run as full
S/A coverage. `mp_svd_verify_examples` is a thin facade, not a second implementation.
A numbered example with a tier filter asserts its `scope_ok`; an all-tier task
acceptance wrapper asserts `results.ok`. Do not make the filtered examples fail
solely because the other tiers were intentionally not requested.

Top-level numbered examples resolve helpers relative to their own files, not the
working directory. Restore temporary path changes. No process-wide exit inside
reusable functions. Test wrappers must exit nonzero on `results.ok == false`.

## 3. Audit the actual public API

Earlier supplied source snapshots documented:

```octave
s = svd (A);
[U, S, V] = svd (A);
[U, S, V] = svd (A, "econ");
```

They rejected two outputs, used Rgesvd/Cgesvd, and returned V, not LAPACK's VT.
Verify this locally; do not invent behavior or demand a stale implementation.
For m-by-n, k=min(m,n), economy shapes must be U:m-by-k, S:k-by-k, V:n-by-k.
Verify complex reconstruction `A=U*S*V'`, input-selected precision, no mutation,
full/economy shapes, descending nonnegative values, and one-output consistency.

Inspect real scalar add/subtract/multiply/divide/sqrt/abs/comparison implementation
and prove the arithmetic contract needed by VERIFICATION.md. A few successful
probes alone do not establish correct rounding. Record audited source paths and
underlying MPFR rounding modes. Inspect lossless widening and exponent behavior.

Use repository-supported environment/build/test wrappers. Record actual `which`
paths, loaded modules, package versions, commit and dirty state. Never assume a
root-level make target, CI command, or local installed package path exists.

## 4. Precision and input identity

### 4.1 Four precision roles

Keep separate fields for:

1. work precision p of the actual SVD input;
2. model-construction precision used to represent the intended matrix exactly;
3. reference solve precision r;
4. interval evaluation precision q.

For smoke use references at 512 and 640 bits and q=768. For demo use references
at 768 and 896 bits and q=1024. For stress, if explicitly requested, references
at 1536 and 1664 bits and q=2048. Reference agreement targets are 2^-160, 2^-224,
and 2^-256 respectively for resolved positive values. These checks alone are
`consistent_reference`, never `verified`.

Do not silently increase reference precision. If a declared reference is unresolved,
report evidence. An explicitly revised experiment must receive a new run ID.

### 4.2 Build, freeze, and preserve

Build each MP input from its recipe at p. Prove exactness using CASES.md bounds.
The below-guard DD rows (demo p=128; stress p=256/512) are intentional rounded-input experiments;
label it `rounded_recipe`, show loss of tau, and do not treat the ideal positive
spectrum as the exact spectrum of that actual input. Other exact-input fixtures
must meet their guard; reject an incompatible manifest instead of silently widening.

Build native baselines from an exact model at adequate precision, convert once to
binary64, freeze, and reuse that same input for values-only and economy solves.
Where representability is proved (NRO block/companion, Lauchli, etc.), assert exact
entry equality after widening. Otherwise report the change without assuming rank.

Store both the intended model and the actual represented input. Residuals and
certificates always name and use their actual target. No reference overwrite of
A. Keep work-input aliases unchanged. Do not leak ambient precision on failure.

### 4.3 Exact widening

The previous snapshot used maximum-operand-precision arithmetic and identity
construction `mp(existing_mp)`. Audit and test this candidate widening method:
set the target default in a cleanup scope, then add a newly created target-precision
zero array to an MP object; convert native binary64 directly to MP. Validate that
q is not below the known source precision. Do not create a precision-inspection API.

Do not widen through `char` followed by parsing: same-precision decimal round-trip
is not cross-precision value preservation. Never replace a work-precision output
with a new high-precision solve while keeping its original label.

### 4.4 Frozen-input references

Compute references for the actual frozen native/MP inputs when they differ from
the exact model; do not reuse the model spectrum without equality or a proof.
A zero found numerically below a reference floor is not an exact-rank proof.
The DD tau-loss case has an exact rank proof in CASES.md. For other ambiguous
near-zero frozen references use `below_reference_resolution` and withhold relative
solver-error claims rather than forcing model zeros onto the rounded matrix.

For numerical comparison, a component is resolved if it exceeds
`2^(-floor(r_low/2))*norm(A_input,"fro")` in both reference runs. Compare resolved
components relatively; compare the remaining block by absolute norm-scaled error.
This floor is only an observational convention. It is not a certificate.

After SVT13, independently verify the higher-reference factorization and use its
intervals to bound work-result errors. This is a posteriori certification even
though the approximate factors came from the same solver: the certifier verifies
finite-arithmetic inequalities, not solver agreement.

## 5. Ordinary diagnostics and acceptance

For each distinct input/precision, run and time one-output SVD and three-output
economy SVD separately. Do not demand bit-identical results between their paths.
References, construction, and verification are excluded from SVD timings.

Keep computed order and factors together. Values are expected descending; fail
an ordering violation rather than repairing solver output. Ascending sorting of
reference values for presentation is allowed only with a recorded permutation.
No assignment algorithm is needed for sorted real nonnegative singular values.

Mandatory diagnostic fields:

- input Frobenius discrepancy and exactness/rounding status;
- total/model forward error and frozen-input solver error, separately;
- positive-tail relative error; norm-scaled absolute leakage for model zeros;
- reconstruction `||A-U*S*V'||F / ||A||F`;
- left/right triplet residuals `A*V-U*S`, `A'*U-V*S`;
- `||U'*U-I||F`, `||V'*V-I||F`;
- projector errors only for the declared clusters/null spaces;
- maximum and minimum resolved singular values, condition estimate and status;
- solver time, work/reference/evaluation precision, actual API path, statuses.

Use the following scalar residual definitions for nonzero A:

    rho_rec = ||A-U*S*V'||F / ||A||F;
    rho_R   = ||A*V-U*S||F / (||A||F*||V||F);
    rho_L   = ||A'*U-V*S||F / (||A||F*||U||F).

Reject zero-norm U/V when k>0. For the zero-A selftest, retain the absolute
numerators and require they vanish within the separately declared absolute test
tolerance; do not create a 0/0 normalized metric. These are ordinary diagnostics;
the verifier recomputes its own rigorous bounds with outward arithmetic.

Compute diagnostics at q from exactly widened outputs. Never form a badly scaled
norm in binary64 before widening. The zero-matrix selftest has an explicit
zero-norm branch. Native conversions for plots occur only after mathematical
metrics/comparisons; compute log errors in MP before converting logs for plotting.

For successful MP smoke/demo factor rows use the engineering envelope
`2^16 * max(m,n)^2 * 2^(-p)` for each normalized triplet/reconstruction residual
and each Frobenius orthogonality defect. These are fixed regression envelopes,
not universal theorems. Lower-precision forward inaccuracy is allowed. Native
rows have no prescribed failure or fixed accuracy expectation.

At the highest work precision (256 smoke, 512 demo) every exact-model fixture must
meet maximum relative error <= 2^-100 (smoke) or 2^-128 (demo) on positive singular
values, and norm-scaled zero leakage <= the same threshold. All highest-precision
fixtures meet their exactness guards. Model projector errors for the specified
Hadamard/Lauchli groups must be <= 2^-80 (smoke), 2^-100 (demo).

Before Tier V is implemented these gates use consistent numerical references and
are provisional. Final acceptance uses rigorous reference enclosures when there
is no exact analytic value. If a positive reference interval [l,h] has l>0, then
`max(abs(s-l),abs(s-h))/l`, evaluated outward, is a valid upper bound on relative
error. It must meet the same target. If l<=0, the relative claim is unresolved.
Do not weaken the gate or replace the input when it fails.

## 6. Profiles and Tier V jobs

The JSON manifest is normative. Smoke: 20 matrix cases, native plus 128/256 bits,
two SVD modes = **120 measured SVD rows**. Demo: the same 20 base cases plus one
complex and two global-scale controls, native plus 128/256/512 bits, two modes =
**184 measured SVD rows**. References, inverse solves, shape tests, and verification
jobs are separately counted. Stress is opt-in and has no fixed recovery target.

V jobs for each completed profile:

- V1 spectrum: certify every highest-work-precision economy row. Require resolved
  positive values and relative interval width <= 2^-90 smoke / 2^-120 demo for
  the mathematically positive values. Model zeros use scaled absolute width.
- V1 projectors: close/repeated Hadamard pair J={3,4} and the Lauchli small group;
  include tall, wide, and the complex demo control. Require projector bounds
  <= 2^-60 smoke / 2^-80 demo. Internal multiplicity must not be a rejection.
- V2 factors: geometric Hadamard, graded NRO block, and a separate 3-by-2 simple
  real/complex test. Require positive separated intervals and per-column vector
  radii <= 2^-60 smoke / 2^-80 demo. Reject individual identification of the exact
  repeated pair, and show that V1 still handles its subspace.
- V3 norms/inverse: highest-precision NRO two-level, NRO companion, DD symmetric.
  Require residual norm <1 and a strictly positive certified sigma_min bound.
  A singular rank-four input and an intentionally poor approximate inverse must
  not receive a false nonsingularity certificate.
- Adversarial verifier tests from VERIFICATION.md are mandatory, not optional.

Also certify selected frozen native demo inputs (NRO two-level, geometric,
DD symmetric). Broad intervals or inability to resolve positivity are expected
possibilities; do not make these cases fail merely for being broad. They demonstrate
the difference between a valid inclusion and a useful relative inclusion.

The final `results.ok` requires complete S/A rows, all numerical gates, all mandatory
V jobs, and no blocked prerequisite. A tier-only run has its own `scope_ok` but
must not be presented as the full task passing. Use separate coverage fields.

## 7. Output and serialization

When output_dir is empty, write no files. Otherwise require a new directory; never
delete or overwrite a prior result to obtain a clean run. Tests use owned temporary
paths. Required outputs:

```text
summary.tsv
singular-values.tsv
verification.tsv
certificates.json
inputs-and-factors.json
environment.txt
report.md
plots/                  # only if requested
```

Version schema `svt-v1`. Record case/tier/representation/parameters, work/reference/q,
input identity, output mode, accuracy metrics, statuses, certificate method ID,
proof preconditions, interval widths, cluster indices and gaps, factor radii,
inverse residual bound, timing categories, and source IDs. Store complex values
as real/imaginary components. No numeric evidence is down-converted to double.

Use exact dyadic serialization for certificate endpoints and certificate target
snapshots as specified in VERIFICATION.md. Decimal strings are display fields,
not inherently outward decimal interval endpoints. Include source precision and
SHA-256 for the canonical snapshot bytes. A certificate must bind to the actual
matrix and factors it checked. Decimal round-trip alone is not a proof of an
outward decimal interval.

Use method IDs `svt_polar_weyl_v1`, `svt_dilation_projector_v1`,
`svt_dilation_factor_boxes_v1`, and `svt_neumann_inverse_v1`. Record
`paper_algorithm_reproduction=false`. No names suggesting that Rump's full methods
have been ported. Valid statuses separate `CERTIFIED`, `INCONCLUSIVE`,
`UNSUPPORTED`, `INVALID_DATA`, and `ARITHMETIC_CONTRACT_UNPROVEN`. `CERTIFIED` with
broad bounds is distinct from `meets_accuracy_target=true`.

## 8. Completion

Execute milestones in MILESTONES.md, one at a time, with tests and a root report
before advancing. Continue automatically after PASS; stop dependent work on a
real prerequisite failure. Report contradictions in the specification rather than
silently modifying mathematics, targets, or scope.

Use the existing source-package builder and isolated package installation QA.
Verify helpers and mp do not accidentally resolve from the developer checkout.
Update the authoritative manual source, regenerate derived documentation, and run
existing relevant numerical/doc/example regressions. No release or PPA work.

Finish with the actual changed files, exact commands, measured S/A and V results,
all 20 milestone statuses, limitations, source attribution, and tests not run.
Do not report this preparation bundle's mathematical checks as Octave execution.
