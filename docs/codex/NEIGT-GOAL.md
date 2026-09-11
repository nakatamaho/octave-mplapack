# NEIGT execution prompt

Open Codex at the `octave-mplapack` repository root, select the user's Luna model
with xhigh reasoning, and paste the following. It references every companion in
this bundle; do not supply the entry document alone.

```text
/goal Implement docs/codex/NEIGT-LUNA-XHIGH.md and all referenced neigt companion specifications, cases.json, and verification-jobs.json for the mplapack-interop Octave package. Read AGENTS.md and all applicable local instructions first. Execute NEIGT00 through NEIGT25 sequentially, run each gate, and write neigtXX-report.md before advancing. Continue automatically after PASS; on a genuine blocker stop dependent work, preserve evidence, and provide a minimal reproducer. Do not stop at a plan.

Implement every requested Tier S/A matrix and every V-S/V-A verification target. S1 must implement the specified Ozaki--Ogita Theorem-1 error-free triple-product generator, including its actual generation precision, paired-block rule, requested-versus-realized standard forms, and independent exactness checks; do not replace it with a generic similarity generator. Preserve working NEIG/SVD/SVT/NEIGV examples, reuse compatible tested helpers, and never assume earlier specifications were implemented.

Use only the existing public mp arithmetic/eig/svd/qr/solve interfaces. Do not modify dependency headers, MPLAPACK, MPFR/MPC, src, installed mp methods, compiler semantics, or public precision/rounding/interval/generalized-eig/Schur APIs. Tier V must contain actual outward-safe arithmetic and proof checkers, not heuristic residuals, precision agreement, empty adapters, or optional external dependencies. Audit the scalar rounding/range contract and implement the complete conservative methods specified in CERTIFICATES.md, labeling them as baselines rather than full reproductions of the cited paper algorithms.

Require counted all-spectrum coverage; nontrivial repeated/defective/merged invariant-subspace certificates; verified pseudospectrum points and positive-area cells; compatible eigenfactor boxes; genuine triangular Schur factors for separated simple cases and explicitly block Schur for the defective case; finite generalized-pencil verification using a proved solve reduction even when eig(A,B) is absent; and positive normalized Perron pairs including the nontrivial left stationary vector. Never claim a true Jordan block is diagonalizable, infer exact multiplicity from a disk count, or confuse an invariant-basis certificate with a spectrally isolated cluster.

Keep generation models, frozen solver inputs, work precision, raw solver outputs, auxiliary candidates, and certificate targets separate and exactly identified. Use MP bijective minimum-bottleneck matching, correct complex left-vector conventions, and exact widening for diagnostics. Do not substitute known roots or higher-precision solves into measured outputs. Candidate-only QR, contour solves, and bounded graph Newton refinement are allowed only as specified and must be separately recorded.

Run all 120 smoke and 168 demo measured eig rows, all 26 verification jobs for each profile, fixed usefulness/accuracy gates, exact serialization/replay and adversarial tests, existing relevant regressions, and isolated clean-package QA. Stress is opt-in; report it and any plotting as NOT_RUN unless executed. Do not force native failures, require balancing improvement, weaken thresholds, change parameters after seeing results, silently widen work inputs, use an MP-to-binary64 numerical fallback, overwrite unrelated files/results/reports, or push/merge/tag/publish. Missing mandatory code or an unproved arithmetic contract is BLOCKED, not a successful unsupported case. Finish with the actual changed paths, exact commands, measured S/A/V results, all 26 milestone statuses, counted coverage, replayable certificates, source attribution, and honest limitations. Unexecuted tests are never PASS.
```

The main specification, not a shortened paraphrase, defines the task. A filtered
example run has its own scope_ok; only complete mandatory coverage can claim the
all-tier task passed. The installation helper copies instructions, not code that
has already passed these implementation gates.
