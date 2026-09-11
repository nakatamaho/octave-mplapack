# NEIGT17 report — verified pseudospectrum points and cells

NEIGT17 implements the specified conservative V-S3 baseline.  It freezes the
exact target as the rectangle expression `z*I-A`, computes the candidate SVD
only at the declared source precision, and widens the returned candidate into
the audited evaluation precision for the proof.  The proof uses the prescribed
polar/Weyl terms

```text
gU, gV, fU, fV, r,
delta = r + s(1) * (fU*sqrt(1+gV) + fV)
```

and classifies `sigma_min(z*I-A)` only when the resulting closed interval is
strictly inside or outside the fixed epsilon threshold.  Cells use the
certified `d=hx+hy` 1-Lipschitz extension and retain positive area.  A finite
grid, a residual-only claim, and a precision-agreement claim are not used.
The method is explicitly a conservative baseline and is not claimed to
reproduce the full cited pseudospectrum algorithms.

## NEIGT17 gate

Focused command:

```text
timeout 300s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private --path test \
  --eval 'test_neigt17();'
```

Evidence: `/tmp/neigt17-gate-1.log` (the terminal gate was executed with this
command; the PASS line was retained in the session output).

Result:

```text
PASS: NEIGT17 verified SVD pseudospectrum points, positive-area cells, and boundary traps
```

The focused gate covered VS3-01 through VS3-04, exact-expression target
construction, candidate hash fields, unitary Gram bounds, positive-area cell
checks, a straddling singular-value interval, an exact threshold boundary,
and malformed interval rejection.

## Final smoke V-S integration

Command:

```text
timeout 1800s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --eval \
  'addpath("examples/neig_tiers"); \
   r=mp_neig_verify_examples("smoke",struct("tier","V-S")); \
   fprintf("status=%s ok=%d jobs=%d implemented=%d vs1=%d vs1complete=%d vs2=%d vs2complete=%d vs3=%d vs3complete=%d\\n", \
   r.status,r.ok,r.coverage.verification_job_count, \
   r.coverage.verification_jobs_implemented,r.coverage.vs1_job_count, \
   r.coverage.vs1_complete,r.coverage.vs2_invariant_job_count, \
   r.coverage.vs2_invariant_complete,r.coverage.vs3_job_count, \
   r.coverage.vs3_complete);' \
  |& tee /tmp/neigt17-integration-3.log
```

Result:

```text
status=COMPLETE ok=1 jobs=16 implemented=16 vs1=8 vs1complete=1 vs2=4 vs2complete=1 vs3=4 vs3complete=1
```

All V-S1, V-S2, and V-S3 jobs passed in the same smoke invocation.  The
integration wall includes the accepted slower NEIGT14 interval cases and the
NEIGT16 merged-cluster case; no stress schedule or plotting was run.

## Representative measured certificates

The following values were measured at the smoke source/evaluation precisions
(256/768 bits).  The SVD candidate was not replaced by a higher-precision
solve.

| Job | Claim | `delta` / cell extension | `lower` | `upper` | norm outside witness |
|---|---|---:|---:|---:|---|
| VS3-01 | `CERTIFIED_INSIDE` | `3.8834948733283944e-75` | `0` | `3.916932993090266e-75` | false |
| VS3-02 | `CERTIFIED_OUTSIDE` | `9.6986238947106848e-75` | `2.0036528396603174e+1` | `2.0036528396603174e+1` | true |
| VS3-03 | `CERTIFIED_INSIDE` | `3.8834948733283944e-75`, `d=3.0517578125e-5` | `0` | `3.0517578125e-5` (plus `3.9169e-75`) | false |
| VS3-04 | `CERTIFIED_OUTSIDE` | `9.6986238947106848e-75`, `d=1/4` | `1.9786528396603174e+1` | `2.0286528396603174e+1` | true |

The exact VS3-04 cell area was `6.25e-2`, and its outward norm-margin witness
was approximately `1.6706077656134855e+1`, well above `epsilon=2^-8`.  The
VS3-02 point norm-margin witness was approximately
`1.6706077656134855e+1`.  Both outside decisions therefore have a proved
operator-norm separation in addition to their SVD/Weyl enclosure.

## Regression wall

Command:

```text
timeout 900s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private --path test \
  --eval 'test_neigt15(); test_neigt16();' \
  |& tee /tmp/neigt17-regression-1.log
```

Result:

```text
PASS: NEIGT15 bounded candidates, Riccati graph, and fail-closed negatives
PASS: NEIGT16 counted clusters, centered powers, projectors, and traps
```

## Implementation and provenance

Files changed:

```text
examples/neig_tiers/private/net_v_s3_classify.m
examples/neig_tiers/private/net_v_s3_job.m
examples/neig_tiers/private/net_v_s3_svd.m
examples/neig_tiers/mp_neig_verify_examples.m
test/test_neigt17.m
neigt17-report.md
```

The scalar classifier has explicit `CERTIFIED_INSIDE`,
`CERTIFIED_OUTSIDE`, and `INCONCLUSIVE` outcomes.  It is used both for points
and for the cell extension.  All matrix products in the proof are explicit
complex rectangle products using the NEIGT outward primitive contract;
`gU>=1`, `gV>=1`, malformed intervals, nonfinite SVD values, negative singular
values, and non-descending singular values fail closed.  The Grcar outside
targets additionally record a conservative Frobenius norm separation witness.

An initial integration attempt exposed a runner-only structure mismatch: the
V-S3 proof completed, but the common status record lacked the legacy empty
`raw_V/raw_D/raw_W` fields.  The mismatch was corrected before the final gate;
the final integration log above is the accepted evidence.  No numerical input
or dependency was changed in that correction.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `5c2cf2aee8099f005a3bc710cf3ce53eb2015896` (NEIGT16 report state)
Final implementation commit: to be recorded after commit
Gate: PASS
V-S integration: PASS, 16/16
NEIGT15/16 regression: PASS
Stress: NOT_RUN
Plotting: NOT_RUN
Push, merge, tag, and publication: NOT_PERFORMED

Known limitation: the point/cell verifier is the requested finite
polar/Weyl/1-Lipschitz baseline.  It is not a full adaptive pseudospectrum
boundary algorithm and does not make global claims from a grid.
