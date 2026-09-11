# Acceptance targets and status policy

These are predeclared engineering gates, not claimed Octave observations or
universal backward-error theorems. The preparation checks do not establish them.
A missed mandatory target is FAIL/BLOCKED with evidence, not authorization to
change a fixture, lower a threshold, or rename an inconclusive job as successful.

## 1. Coverage and counts

`cases.json` is the ordinary measured-solve manifest. Without a filter:

| Profile | Cases | Work precisions including native | Balance modes | Measured three-output eig calls |
|---|---:|---|---:|---:|
| smoke | 20 | native64, 128, 256 | 2 | 120 |
| demo | 21 | native64, 128, 256, 512 | 2 | 168 |
| stress, explicit opt-in | 8 | native64, 256, 512, 1024 | 2 | 64 |

Native is run once per case/mode. Reference eig/SVD, contour/linear solves, candidate
refinement, values-only API probes and verifier calls are separately counted.
Every smoke/demo run also has **26 verification jobs**, as specified in
`verification-jobs.json`: 8 V-S1, 4 V-S2, 4 V-S3, 3 V-A1, 3 V-A2 and 4 V-A3.
A job may make several documented primitive/candidate/checker calls; 26 is the
number of required top-level jobs, not the total number of numerical operations.

Stress has no mandatory additional V schedule. Never count its absent V jobs as
smoke/demo passes. Independent unit/adversarial tests are not included in the 26.

## 2. Common ordinary-solve checks

Each MP smoke/demo row must have correct finite outputs, nonzero left/right
columns, exact raw-input preservation, state restoration and valid bijective
matching. The four normalized residuals in NUMERICS.md must be <=

```text
tau_res = 2^16 * n^2 * 2^(-p).
```

Use MP arithmetic to build this envelope. In genuine defective cases a singular
returned eigenvector matrix and unresolved simple-root condition estimates are
legitimate; a zero vector column or unexplained exception is not. Do not require
`inv(V)` or finite `cond(V)` there. For successful native rows record the same
metrics but impose no forward/residual target and no prescribed failure pattern.
A native solver exception is retained and makes the requested comparison incomplete.

The model-generation/exactness tests are independent of accuracy. At the highest
work precision of each mandatory profile every model must be represented exactly,
including every integer coefficient. A below-guard lower-precision input is only
permitted where the manifest explicitly allows rounding and records it. Native
rounding is measured; no native model-rank assertion is made without an exact proof.

## 3. Highest-work-precision forward targets

The following use model errors only when input equality with the model is proved.
For a different frozen input label the two errors separately. Highest work bits
are 256 for smoke and 512 for demo.

Define scale `a_scale=max(mp(1),norm(A_model,"fro"))`. This scale is for ordinary
forward diagnostics, not an independently verified norm. Report unscaled and
relative errors as well when defined; do not use a large scale to conceal the
additional circle, gap, or conditioning tests below.

| Case class | Smoke | Demo |
|---|---:|---:|
| All simple or semisimple models | absolute bottleneck / a_scale <= 2^-80 | <= 2^-160 |
| Frank orientations, additionally | relative bottleneck <= 2^-80 | <= 2^-160 |
| Hadamard bidiagonal, additionally | absolute bottleneck <= 2^-80 | <= 2^-120 |
| Forsythe nonzero original/scaled, additionally | circle bottleneck <= 2^-80 | <= 2^-120 |
| True defective model groups | absolute bottleneck / a_scale <= 2^(-floor(p/(4*kmax))) | same formula |

Here kmax is a **proved upper bound** on the maximum Jordan-block size: 2 for
SIM_JORDAN and SIM_TWO_JORDAN; n for FORSYTHE_ZERO; ell for MKS's zero part.
For MKS also require the nonzero-root subset, separated using the reduced model
polynomial, to meet the simple-model target. For SIM defective families require
the isolated simple roots outside the Jordan blocks to meet that target as well.
Do not impose exponential-in-p simple-root accuracy on a size-k Jordan splitting.

For the mixed zero/nonzero MKS model, matching uses all n roots including the
algebraic zeros. The reduced polynomial must be square-free by an exact gcd test
at the mandatory dimensions, not by a numerical root-gap guess. An unexpected
multiple nonzero root is a specification failure to investigate.

Analytic condition checks: on highest-precision HAD_BIDIAG/HAD_COMPLEX and
TOEPLITZ/TOEPLITZ_SYM, compare each resolved simple-root condition estimate with
its independently evaluated formula. Maximum relative disagreement <=2^-40 smoke,
<=2^-80 demo. Pairing must be shared with the spectrum. Do not identify cond(D)
with individual eigenvalue condition numbers.

OO checks are stronger than merely small errors: exact intermediate products,
Theorem-1 predicate, requested-versus-realized fields, paired conjugacy, fixed
model identity across work bits, and the specified surviving/removed gaps all
must pass. Treat formula violations as generation failure before eig is called.

There is no adjacent-precision monotonicity or automatic-balancing-improvement gate.
Lower-precision forward errors alone may be INSUFFICIENT_PRECISION. Fixed final
work bits, reference settings and parameters cannot be changed silently.

## 4. V-S1: eight useful counted all-spectrum jobs

Each job uses the highest-work-precision **nobalance** result of its core case,
with the corresponding exact frozen input. Use those raw V and D as the first
candidate. Compute an inverse candidate at q; this does not change the eig output.
For these eight required jobs do not replace raw V,D with a higher-precision solve
to pass a width target. The similarity checker verifies the actual supplied data.

Require CERTIFIED_ALL, exactly n counted roots, n singleton components, and
maximum disk radius / max(1,verified upper Frobenius norm of A) <=2^-40 smoke or
2^-64 demo. Additionally OO128_CLOSE's first pair must be certified as two separate
singletons; a broad disk enclosing both is valid but fails this useful-case gate.
The real complex-pair OO case certifies nonreal conjugate regions, not two real roots.

The fixed cases are OO53_REAL, OO53_PAIR, OO128_CLOSE, TOEPLITZ, HAD_BIDIAG,
FRANK0, WILKINSON and GRCAR. If a required raw candidate is not good enough,
report that result, not a relabeled auxiliary solve. Extra rescue experiments are
permitted under new candidate IDs, but do not change the mandatory result.

## 5. V-S2: four nontrivial cluster/subspace jobs

Jobs use the explicitly smaller fixtures in `verification-jobs.json`, not a full
n=32 Riccati problem. Candidate preparation is bounded by NUMERICS.md. Candidates
may be computed at r1/r2, but their origin/bits and extra solves are recorded.

Require all graph contraction inequalities, nonsingular full X, full-rank Y1,
strict separation of the certified M and D2 spectral regions, exactly k cluster
roots with complementary count n-k, and CERTIFIED_CLUSTER. No full-space identity
projector counts. The certified raw-X1 orthogonal-projector error bound must be
<=2^-40 smoke or <=2^-64 demo.

For SIM_REPEAT, SIM_JORDAN and MKS-zero, require a certified cluster radius about
the query center <=2^-24 smoke or <=2^-48 demo. For the **merged** two-Jordan group,
with centers 1 and 1+d and query center 1+d/2, use radius <=2*d + that same target.
The unavoidable physical cluster spread is not numerical certification error.

The centered power enclosure is mandatory on defective jobs. Choosing another
candidate basis or improving it within the bounded schedule is allowed; shrinking
an interval by discarding outward uncertainty is not. The proof does not use the
known generator basis, exact root multiplicity, or an unverified query contour.

Also run a negative separated-cluster attempt with intentionally invalid claimed
separation and require no false isolated-cluster certificate. An invariant-basis
certificate without isolation is not the required CERTIFIED_CLUSTER result.

## 6. V-S3: four point/cell decisions

Inside and outside points and cells have predetermined targets in the JSON file.
Each must be classified with the polar/Weyl enclosure for the exact expression
zI-A and, for cells, the certified Lipschitz radius. Preserve the input, SVD
candidate and all proof terms. These are rigorous finite-matrix statements.

Inside: simple/defective exact query center for a small Jordan-similarity matrix.
Outside: a far point for Grcar. The cells have positive width; they are not point
certificates renamed as cell certificates. Test scalar classification at a
straddling interval separately and require INCONCLUSIVE. A coarse plot or observed
SVD value is not evidence for any classification.

## 7. V-A1: compatible factors

For the real and complex simple jobs, require simultaneously compatible right
and dual left eigenfactor boxes and a true unitary triangular Schur factorization
contained in the returned boxes. Show all root regions are simple/disjoint, all
phase/gauge choices are consistent, and the interval exact-QR divisions have
strictly positive lower bounds. Maximum component-radius divided by
max(1,maximum candidate factor-entry magnitude) <=2^-40 smoke, <=2^-64 demo.

For the defective job require the nontrivial leading two-dimensional invariant
block and a unitary **block-upper-triangular** factorization; the lower-left block
is zero by invariance. Do not zero the block's strictly lower triangle or claim
a diagonal eigenfactorization exists. Use the same radius target. Report
CERTIFIED_BLOCK_SCHUR explicitly, not CERTIFIED_SCHUR_TRIANGULAR.

Negative phase/permutation and incompatible-factor tests must reject falsely
small boxes. Interval factor products must enclose the target; this inclusion
alone, without the existence proof, is not a substitute for the checker.

## 8. V-A2: finite pencils

All three jobs require an outward nonsingularity witness for B, a reduction-error
enclosure for B^(-1)A, and verified finite eigenvalue coverage of the original
pencil. The simple real/complex jobs require n separated root regions, radius
scaled by max(1,verified upper norm of C0) <=2^-32 smoke, <=2^-64 demo. Map left
vectors with B^(-*) and check original-pencil residuals; never reuse ordinary
left vectors untransformed. The defective job additionally requires its leading
2-root isolated invariant subspace with the V-S2 width/projector goals.

Public eig(A,B) is an optional comparator; absence cannot omit this V-A2 target.
The mandatory implementation is the verified finite solve-reduction. Reject a
singular-B or unproved-invertible B case without a false finite-spectrum claim.
Record infinite-root support as outside the declared domain, not implemented.

## 9. V-A3: four positive pair jobs

Certify P, P', the positive diagonal-similarity model and its transpose on the
specified small dimensions. Require positive vector box lower bounds, exact
normalization equation, strict contraction, irreducibility witness and compatible
root inclusion; intersect the Collatz--Wielandt root bound when it tightens it.
Maximum root/vector interval radius, scaled by max(1,candidate magnitude), must
be <=2^-32 smoke or <=2^-64 demo. The left stationary vector is nonuniform and
must not be replaced by the teleportation r. Positivity and normalization are
existence properties of the enclosed true pair, not just midpoint properties.

The second-root/gap statement is separately checked on the MARKOV ordinary model
and can be additionally certified using V-S1. It is not a conclusion of the
Perron-only certificate. A rounded native matrix does not inherit exact row sums.

## 10. Negative tests, replay and task-level PASS

Mandatory adversarial tests cover every proof precondition: interval crossing zero,
nonfinite/range violations, singular or bad inverse candidates, touching spectral
groups, duplicate roots, wrong complex transpose, graph gap collapse, defective
individual-vector requests, SVD Gram defects, mixed gauges, singular B, negative
matrix entries, reducibility and normalization errors. A broad mathematically
valid enclosure is not itself a bug; a false narrow one is.

Exact serialization must round-trip before and after process restart. Replay
recomputes proof predicates on the recorded frozen targets without invoking eig
or silently rebuilding the ideal model. Tampered input, shape, exponent, radius,
method ID or bound must be detected. Zero-endpoint serialization is not negative
zero preservation; signed floating zero is canonicalized to exact real zero.

`scope_ok` is local to requested coverage; `ok` for all-tier smoke/demo requires
all rows, all positive V jobs at their usefulness targets, all adversarial tests,
no unresolved arithmetic contract, and no missing prerequisite. Ordinary error
plots and stress cases have no authority to override these gates. Final completion
also requires repository integration and clean-package QA from MILESTONES.md.
