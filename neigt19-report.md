# NEIGT19 report — genuine triangular and defective block Schur boxes

NEIGT19 evaluates exact mathematical complex Gram–Schmidt/QR through the
outward rectangle arithmetic of the compatible NEIGT18 factor boxes.  Every
normalization is a positive real interval with a strictly positive lower
endpoint.  The resulting `Q_box` and `R_box` are used with the direct interval
evaluation of `Q'*A*Q`.

For the separated simple cases, the lower triangle is intersected with exact
zero only under the already-proved simultaneous compatible eigenfactor
relation; this is an algebraic Schur proof, not numerical clipping.  For the
defective fixture, only the lower-left block below the certified two-dimensional
invariant subspace is forced to zero.  The strictly lower entry within the
leading 2×2 block remains the direct interval result, and the status is
`CERTIFIED_BLOCK_SCHUR`, never scalar triangular or diagonal.

## NEIGT19 gate

Command:

```text
timeout 300s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private --path test \
  --eval 'test_neigt19();' |& tee /tmp/neigt19-gate-1.log
```

Result:

```text
PASS: NEIGT19 interval QR, true triangular Schur, block Schur, and normalization traps
```

The gate verified:

| Job | Result | Required zero structure |
|---|---|---|
| VA1-01 real simple | `CERTIFIED_SCHUR_TRIANGULAR` | complete lower triangle |
| VA1-02 complex simple | `CERTIFIED_SCHUR_TRIANGULAR` | complete lower triangle |
| VA1-03 defective block | `CERTIFIED_BLOCK_SCHUR` | rows 3:4, columns 1:2 only |

All normalization lower bounds were positive.  Representative first
normalization lower bounds were `1.4244246232238394e-1` (real),
`3.0460384954008571e-1` (complex), and `9.999999999999999e-1` (defective
block).  The defective leading-block lower entry was retained from
`T_direct`, rather than being overwritten by zero.  An input with a zero first
column returned `INCONCLUSIVE_QR_NORMALIZATION` and did not produce a Schur
claim.

## V-A integration

Command:

```text
timeout 300s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --eval \
  'addpath("examples/neig_tiers"); \
   r=mp_neig_verify_examples("smoke",struct("tier","V-A")); \
   fprintf("status=%s ok=%d jobs=%d implemented=%d va1=%d va1complete=%d\\n", \
   r.status,r.ok,r.coverage.verification_job_count, \
   r.coverage.verification_jobs_implemented,r.coverage.va1_job_count, \
   r.coverage.va1_complete);' \
  |& tee /tmp/neigt19-integration-1.log
```

Result:

```text
status=PARTIAL_NOT_IMPLEMENTED ok=0 jobs=10 implemented=3 va1=3 va1complete=1
```

All three VA1 jobs are now complete.  V-A remains partial only because VA2 and
VA3 are future milestones; this integration invocation does not silently count
those jobs as implemented.

## Regression wall

Command:

```text
timeout 600s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private --path test \
  --eval 'test_neigt18(); test_neigt19();' \
  |& tee /tmp/neigt19-regression-1.log
```

Result:

```text
PASS: NEIGT18 compatible eigenfactor boxes, gauges, and repeated-root traps
PASS: NEIGT19 interval QR, true triangular Schur, block Schur, and normalization traps
```

## Implementation and provenance

Files changed:

```text
examples/neig_tiers/private/net_v_a1_model.m
examples/neig_tiers/private/net_v_a1_interval_qr.m
examples/neig_tiers/private/net_v_a1_schur_job.m
examples/neig_tiers/private/net_v_a1_job.m
examples/neig_tiers/mp_neig_verify_examples.m
test/test_neigt19.m
neigt19-report.md
```

The VA1 model helper uses a computed exact-similarity real-simple fixture and
the complex quarter-turn Hadamard fixture.  The defective model is prepared by
the bounded computed contour/QR candidate schedule.  No generator basis is
used as a certificate input, no public dependency/API was changed, and no
binary64 numerical fallback was introduced.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `d5184c09c9ae22e8e0438e88e8db345f466856a5` (NEIGT18 report state)
Final implementation commit: to be recorded after commit
Gate: PASS
VA1 Schur/block-Schur: PASS, 3/3
V-A integration: partial by design, VA1 complete and VA2/VA3 pending
Stress: NOT_RUN
Plotting: NOT_RUN
Push, merge, tag, and publication: NOT_PERFORMED

Known limitation: interval Gram–Schmidt is the specified conservative finite
baseline.  NEIGT19 does not claim adaptive Schur reordering or a diagonal
factorization for a defective block.
