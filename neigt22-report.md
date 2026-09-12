# NEIGT22 report — all tiers integrated and proof audit

NEIGT22 integrates the ordinary S/A profiles with all mandatory verification
jobs.  The gate was run as one invocation per profile path inside
`test_neigt22`, so the all-tier coverage assertions and the V-tier assertions
were evaluated together rather than inferred from separate reports.

## Gate result

The full integration gate passed with exit status 0:

```text
PASS: NEIGT22 full 120/168 ordinary rows and 26+26 verification jobs
```

Measured coverage:

| Profile | Ordinary eig rows | Verification jobs | Result |
|---|---:|---:|---|
| smoke | 120/120 | 26/26 | PASS |
| demo | 168/168 | 26/26 | PASS |

Both ordinary profiles reported `NUMERICS_ONLY_COMPLETE`.  Both verification
profiles reported `COMPLETE`, with 26 implemented jobs, every `pass` flag true,
and every `milestone_pass` flag true.

The 26 verification statuses were identical for smoke and demo:

| Jobs | Status |
|---|---|
| VS1-01..VS1-08 | `PASS` (8/8) |
| VS2-01..VS2-04 | `CERTIFIED_CLUSTER` (4/4) |
| VS3-01..VS3-04 | `PASS` (4/4) |
| VA1-01..VA1-02 | `CERTIFIED_SCHUR_TRIANGULAR` (2/2) |
| VA1-03 | `CERTIFIED_BLOCK_SCHUR` (1/1) |
| VA2-01..VA2-03 | `CERTIFIED_ALL_FINITE` (3/3) |
| VA3-01..VA3-04 | `CERTIFIED_PERRON_PAIR` (4/4) |

Thus the gate includes counted all-spectrum coverage, merged/defective cluster
certificates, genuine triangular and block Schur cases, finite generalized
pencil reduction, and normalized positive left/right Perron pairs.  No
certificate was promoted from a root-only or residual-only observation.

## Commands and evidence

The full gate was run from the source tree with the dependency environment
already selected by the test harness:

```text
git diff --check && timeout 28800s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private \
  --path examples/neig_tiers --path test --eval 'test_neigt22();' \
  |& tee /tmp/neigt22-gate-3.log
```

Exit status: `0`.

The relevant regression wall was also rerun after the NEIGT22 changes:

```text
set -o pipefail; timeout 3600s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private \
  --path examples/neig_tiers --path test \
  --eval 'test_neigt15(); test_neigt16(); test_neigt17(); \
          test_neigt20(); test_neigt21();' \
  |& tee /tmp/neigt22-regressions.log
```

Exit status: `0`.  The five focused regression results were:

```text
PASS: NEIGT15 bounded candidates, Riccati graph, and fail-closed negatives
PASS: NEIGT16 counted clusters, centered powers, projectors, and traps
PASS: NEIGT17 verified SVD pseudospectrum points, positive-area cells, and boundary traps
PASS: NEIGT20 finite pencils, mapped residuals, defective cluster, and fail-closed reductions
PASS: NEIGT21 positive graph, Collatz--Wielandt, Perron pair, stationary vector, and fail-closed negatives
```

Focused implementation evidence is preserved in:

```text
/tmp/neigt22-fix-neigt17.log
/tmp/neigt22-fix-merged-polynomial-neigt16.log
/tmp/neigt22-fix-va2-regression.log
/tmp/neigt22-vs2-demo-after-poly.log
/tmp/neigt22-va2-demo-after-newton.log
/tmp/neigt22-gate-3.log
/tmp/neigt22-regressions.log
```

## Changes made for the integrated gate

### V-S3 status-schema completion

`net_v_s3_job.m` now includes the shared `raw_lambda_hash` field in its
status template.  The all-V runner preallocates a common status schema, and
the missing field previously caused a struct-assignment failure when the
combined V tier was requested.  This is a schema/integration repair only; it
does not change the numerical certificate.

### V-A2 bounded candidate correction

The defective finite-pencil cluster path in `net_v_a2_job.m` now records and
uses the fixed bounded candidate-only Newton correction already specified for
candidate preparation.  It applies the correction independently to each
candidate, transforms the candidate basis, and then recomputes the graph and
cluster proof from that corrected candidate.  The attempts and selected basis
are retained in the result for auditability.  The solver output, auxiliary
candidate, frozen input, and proof target remain separate.

The corrected demo VA2-03 result was:

```text
status=CERTIFIED_ALL_FINITE pass=1 milestone=1
cluster status=CERTIFIED_CLUSTER pass=1 sep=1
```

The recorded cluster radius was approximately `3.1282548362e-148`, against
the fixed `2^-64` target `5.4210108624e-20`; the projector bound was
approximately `1.2467585180e-37`.  No target, precision, candidate schedule,
or input was widened after observing the failure.

### V-S2 merged two-Jordan polynomial certificate

`net_v_s2_cluster.m` retains the raw centered-power calculation and adds a
conservative centered-polynomial power certificate for the `two_jordan`
merged-cluster regime.  It computes the center and second moment from the
outward interval box of the computed reduced matrix `M`, then verifies the
corresponding squared polynomial bound.  It does not consume known roots,
generator columns, or a higher-precision replacement solve.  The result is
explicitly marked `paper_algorithm_reproduction=false`; it is a conservative
baseline certificate, not a claim to reproduce a cited paper algorithm.

For demo VS2-03 the fixed target was:

```text
1.822542117224656976759433746337890625e-12
```

The raw centered power radius remained recorded at approximately
`7.2759576141834259e-12`.  The independently computed merged-polynomial
certificate passed with polynomial norm approximately `5.7711652302e-305`
and lower bound approximately `9.7023815755e-48`, yielding
`CERTIFIED_MERGED_DISK` and the overall `CERTIFIED_CLUSTER` result.  This
avoids incorrectly claiming that the raw high power alone resolves the
physical merged cluster.

## Contract and proof audit

The integrated gate exercises the existing example-local outward arithmetic,
MP-only candidates, exact widening, correct complex left-vector convention,
minimum-bottleneck matching, graph contraction, interval residuals,
Gershgorin/counting, Schur/block-Schur, finite-pencil solve reduction, and
positive-pair proof paths.  The new code remains within the public `mp`,
`eig`, `svd`, `qr`, and solve interfaces.  There is no binary64 complex
fallback, no dependency-header change, no MPLAPACK change, no installed
method change, and no route from existing real-only operations through a
complex kernel.

All proof-producing paths keep generation models, frozen solver inputs,
working precision, raw outputs, auxiliary candidates, and certificate targets
as distinct recorded objects.  The negative tests remain part of the focused
NEIGT15--21 regression wall.

Stress execution: `NOT_RUN` (opt-in).

Plotting execution: `NOT_RUN` (optional and not needed for this numerical
gate).

An earlier ad-hoc VA2 diagnostic printed the successful certificate and then
attempted to display a nonexistent diagnostic field; that diagnostic was not
used as a gate and had no source-side effect.  The focused regression and the
full NEIGT22 gate both exited 0 without this diagnostic formatting mistake.

No push, merge, tag, or publication was performed.

## Required milestone record

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `139ed7f186899600ca7ccc2f52ccb9b47b2f34a2`

Final commit: to be recorded by the NEIGT22 report-record commit.

Files changed:

```text
examples/neig_tiers/private/net_v_a2_job.m
examples/neig_tiers/private/net_v_s2_cluster.m
examples/neig_tiers/private/net_v_s3_job.m
test/test_neigt22.m
neigt22-report.md
```

Commands run:

```text
git diff --check
timeout 28800s octave-cli ... --eval 'test_neigt22();' |& tee /tmp/neigt22-gate-3.log
timeout 3600s octave-cli ... --eval 'test_neigt15(); test_neigt16(); test_neigt17(); test_neigt20(); test_neigt21();' |& tee /tmp/neigt22-regressions.log
```

Tests: NEIGT22 full gate PASS; NEIGT15, NEIGT16, NEIGT17, NEIGT20, and
NEIGT21 focused regressions PASS.

Gate: `PASS`

Known limitations: stress and plotting were not run.  The merged two-Jordan
polynomial method is intentionally documented and recorded as a conservative
baseline, not as a full reproduction of the cited paper algorithm.
