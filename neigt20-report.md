# NEIGT20 report — finite generalized pencils

NEIGT20 implements `neigt_verified_finite_pencil_v1`.  The mandatory VA2
fixtures are generated as exact MP models with `A=B*C`.  The checker computes
the candidate reduction `R_B` and `C0` with public MP solves, but never treats
either candidate as exact.  It proves

```text
eB = ||I-R_B B||inf < 1
etaB = upper(||R_B(A-B*C0)||inf/(1-eB))
```

and sends the resulting entrywise enclosure of the exact `C=B^(-1)A` to the
existing V-S1 and V-S2 interval checkers.  The V-S2 graph for VA2-03 uses the
two bounded candidate strategies and the fixed VA2 cluster-radius target
`2^-16`; the target is recorded in `verification-jobs.json` and is not
adapted to a measured result.

The original pencil remains the certificate target.  Right residuals are
`A*V-B*V*D`; left columns are mapped by `W=B^(-H)*W_C` and the residual is
`W'*A-D*W'*B`.  These are approximate-candidate residual evaluations, so their
outward finite norm bounds are recorded separately from exact zero-containing
interval identities.  The defective graph certificate additionally proves
`A*Y1=B*Y1*M` by interval evaluation and retains the nontrivial two-dimensional
invariant subspace rather than claiming a defective diagonalization.

## NEIGT20 gate

Command:

```text
timeout 1500s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private --path test \
  --eval 'test_neigt20();' |& tee /tmp/neigt20-gate-1.log
```

Result:

```text
PASS: NEIGT20 finite pencils, mapped residuals, defective cluster, and fail-closed reductions
```

The gate independently checked the exact constructor identity, all three
smoke VA2 jobs, both mapped residuals, all six finite-root counts, the
defective cluster and original-pencil graph residual, plus singular-B and
zero-inverse negative reductions.

## Measured smoke jobs

Source/evaluation precision was 256/768 bits.  All finite-root counts were
6/6 and all B inverse residuals were below one.

| Job | Status | `eB` | `etaB` | right residual upper | left residual upper | cluster |
|---|---|---:|---:|---:|---:|---|
| VA2-01 real | `CERTIFIED_ALL_FINITE` | `1.7004633e-229` | `2.226061e-228` | `5.6324911e-229` | `7.6347064e-229` | — |
| VA2-02 complex | `CERTIFIED_ALL_FINITE` | `1.7004633e-229` | `4.5010748e-228` | `6.4466374e-229` | `7.1994114e-229` | — |
| VA2-03 defective | `CERTIFIED_ALL_FINITE_AND_CLUSTER` | `1.7004633e-229` | `6.1474324e-228` | `8.2379336e-229` | `8.8259439e-229` | `CERTIFIED_CLUSTER` |

VA2-03 returned cluster radius `1.1920929e-7`, below the fixed target
`1.5258789e-5`, with strict complement separation, positive projector-bound
check, and an enclosed original-pencil graph residual.  The first candidate
did not satisfy complement separation; the allowed second candidate did.  The
failed candidate is retained in the job's candidate preparation record.

## V-A integration

Command:

```text
timeout 1800s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src \
  --eval 'addpath("examples/neig_tiers"); \
   r=mp_neig_verify_examples("smoke",struct("tier","V-A")); \
   fprintf("status=%s ok=%d jobs=%d implemented=%d ...\\n", ...);' \
  |& tee /tmp/neigt20-integration-1.log
```

Result from `/tmp/neigt20-integration-1.log`:

```text
status=PARTIAL_NOT_IMPLEMENTED ok=0 jobs=10 implemented=10 va1=3 va1complete=1 va2=3 va2complete=1 va3=4 va3complete=0
job=VA1-01 status=CERTIFIED_SCHUR_TRIANGULAR pass=1 milestone=1
job=VA1-02 status=CERTIFIED_SCHUR_TRIANGULAR pass=1 milestone=1
job=VA1-03 status=CERTIFIED_BLOCK_SCHUR pass=1 milestone=1
job=VA2-01 status=CERTIFIED_ALL_FINITE pass=1 milestone=1
job=VA2-02 status=CERTIFIED_ALL_FINITE pass=1 milestone=1
job=VA2-03 status=CERTIFIED_ALL_FINITE pass=1 milestone=1
job=VA3-01 status=NOT_IMPLEMENTED pass=0 milestone=0
job=VA3-02 status=NOT_IMPLEMENTED pass=0 milestone=0
job=VA3-03 status=NOT_IMPLEMENTED pass=0 milestone=0
job=VA3-04 status=NOT_IMPLEMENTED pass=0 milestone=0
```

At NEIGT20, all VA1 and VA2 jobs are implemented; VA3 is intentionally not
implemented until NEIGT21, so a V-A all-jobs invocation correctly does not
report overall `ok` yet.

## Implementation and provenance

Files changed:

```text
examples/neig_tiers/private/net_v_a2_model.m
examples/neig_tiers/private/net_v_a2_expand_modulus.m
examples/neig_tiers/private/net_v_a2_job.m
examples/neig_tiers/private/net_v_a2_reduction.m
examples/neig_tiers/private/net_v_s1_gershgorin.m
examples/neig_tiers/private/net_v_s2_graph.m
examples/neig_tiers/private/net_v_s2_cluster.m
examples/neig_tiers/mp_neig_verify_examples.m
docs/codex/neigt/verification-jobs.json
test/test_neigt20.m
neigt20-report.md
```

No dependency headers, MPLAPACK, MPFR/MPC, public `mp` API, compiler
semantics, or source-tree numerical implementation changed.  `eig(A,B)` is
not used.  The only candidate spectral solve is public `eig(C0,"nobalance")`,
and the defect graph uses the bounded public contour/solve/QR candidate
preparation already audited in V-S2.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `7c55588231f720ac27d6cc675f43043e87742cec` (NEIGT19 report state)
Final implementation commit: `e3b8bb8`
Gate: PASS
VA2: PASS, 3/3
V-A integration: PASS for implemented VA1/VA2 (6/6); VA3 pending by milestone order
Stress: NOT_RUN
Plotting: NOT_RUN
Push, merge, tag, and publication: NOT_PERFORMED

Known limitation: this is the specified conservative finite-pencil reduction
baseline.  It proves finite roots from B nonsingularity and reduction
enclosure; it does not certify infinite eigenvalues or implement generalized
QZ, and does not claim a full eigenbasis for the defective pencil.
