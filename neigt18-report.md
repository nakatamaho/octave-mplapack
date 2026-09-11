# NEIGT18 report — compatible eigenfactor boxes

NEIGT18 implements the V-A1 compatible simple-eigenfactor baseline.  The fixed
fixtures are the specified `A=Y*J*X` model with `J=diag(1,2,4,8)` for the
simple real case, its `[1,i,-1,-i]` diagonal phase conjugate for the complex
case, and `J2(1),4,8` for the defective case.  Each
simple root is prepared from one public `eig(...,"nobalance")` result, reordered
as a candidate-only basis, and independently passed through the k=1 NEIGT15
Riccati graph checker.  The resulting graph vectors and scalar root boxes are
then assembled into one interval `E` and diagonal `Lambda`; they are not
independently normalized columns.

The assembled factor is accepted only after strict disjointness of all root
boxes, an interval Neumann inverse witness for `E`, an explicitly enclosed
compatibility residual `A*E-E*Lambda`, and the fixed component-width target.
The dual factor is the outward box for `W=(E^-1)'`.  The interval inverse
witness uses `G=R0*E-I`, `||G||inf<1`, and the proved bound
`||E^-1-R0||inf <= ||G||inf/(1-||G||inf)*||R0||inf`.

The defective VA1-03 fixture is deliberately not promoted to individual
factors: its true Jordan block receives a nontrivial invariant-basis result,
but the individual-factor claim is refused and is reserved for the block-Schur
implementation in NEIGT19.

## NEIGT18 gate

Command:

```text
timeout 300s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private --path test \
  --eval 'test_neigt18();' |& tee /tmp/neigt18-gate-1.log
```

Result:

```text
PASS: NEIGT18 compatible eigenfactor boxes, gauges, and repeated-root traps
```

The focused gate passed real VA1-01 and complex VA1-02, confirmed coherent
phase-gauge invariance, rejected a duplicated factor column, rejected a
Lambda-only permutation, and rejected the repeated-root individual-factor
attempt.  VA1-03 retained `INCONCLUSIVE_DEFECTIVE_INDIVIDUAL` with
`milestone_pass=1` because the correct result at this milestone is a refusal,
not a false diagonalization claim.

## Measured simple factors

Smoke source/evaluation precision was 256/768 bits.  The returned eigenfactor
boxes were checked against the fixed `2^-40` usefulness target.

| Job | Status | width ratio | target | inverse `e` | roots disjoint | compatibility |
|---|---|---:|---:|---:|---|---|
| VA1-01 real | `CERTIFIED_EIGENFACTORS` | `8.8585516508992112e-153` | `9.0949470177292824e-13` | `7.3678765155389284e-151` | true | enclosed |
| VA1-02 complex | `CERTIFIED_EIGENFACTORS` | `4.2846530212416861e-155` | `9.0949470177292824e-13` | `5.7163288908434253e-154` | true | enclosed |

Both factors record raw `V`, `D`, and `W` hashes, graph certificates for all
four k=1 roots, `E_box`, `Lambda_box`, and the dual `W_box`.  The complex case
uses complex-coordinate arithmetic throughout the compatibility proof.

## Fixture correction audit

The NEIGT19 specification audit found that the initial implementation had
used `[1,2,4,5]` for the simple VA1 model.  That did not match the mandatory
CASES.md fixture.  The model and its independent assembly test were corrected
to `[1,2,4,8]`; the complex case now derives from that corrected real model by
the specified diagonal phase conjugation.  The defective case is explicit as
`J2(1),4,8` rather than a different generic model.

The corrected direct factor measurements at 256/768 source/evaluation bits
are:

| Job | status | width ratio | target | inverse `e` | roots disjoint | compatibility |
|---|---|---:|---:|---:|---|---|
| VA1-01 real | `CERTIFIED_EIGENFACTORS` | `8.5203938428343769e-153` | `9.0949470177292824e-13` | `5.793378436367298e-151` | true | enclosed |
| VA1-02 complex | `CERTIFIED_EIGENFACTORS` | `1.7040787685668754e-152` | `9.0949470177292824e-13` | `9.4738723077880239e-151` | true | enclosed |

Corrective logs are `/tmp/neigt-va1-correction-1.log` and
`/tmp/neigt-va1-correction-measurements-4.log`.  They supersede the
pre-correction measurements below.

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
  |& tee /tmp/neigt18-integration-1.log
```

Result:

```text
status=PARTIAL_NOT_IMPLEMENTED ok=0 jobs=10 implemented=3 va1=3 va1complete=0
```

This is the expected V-A partial state: VA1-01/02 are implemented and pass;
VA1-03 is a deliberate individual-factor refusal until NEIGT19, while VA2 and
VA3 remain future milestones.  The runner counted all three VA1 jobs and did
not silently mark the remaining V-A jobs implemented.

## Regression wall

Command:

```text
timeout 900s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private --path test \
  --eval 'test_neigt15(); test_neigt16(); test_neigt17();' \
  |& tee /tmp/neigt18-regression-1.log
```

Result:

```text
PASS: NEIGT15 bounded candidates, Riccati graph, and fail-closed negatives
PASS: NEIGT16 counted clusters, centered powers, projectors, and traps
PASS: NEIGT17 verified SVD pseudospectrum points, positive-area cells, and boundary traps
```

## Implementation and provenance

Files changed:

```text
examples/neig_tiers/private/net_v_a1_factors.m
examples/neig_tiers/private/net_v_a1_job.m
examples/neig_tiers/private/net_v_a1_validate_assembly.m
examples/neig_tiers/private/net_v_s2_graph.m
examples/neig_tiers/private/net_iv_cmatrix_point.m
examples/neig_tiers/private/net_iv_cmatrix_add.m
examples/neig_tiers/private/net_iv_cmatrix_mul.m
examples/neig_tiers/private/net_iv_cmatrix_fro_upper.m
examples/neig_tiers/private/net_iv_cmatrix_inf_upper.m
examples/neig_tiers/mp_neig_verify_examples.m
test/test_neigt18.m
neigt18-report.md
```

The scalar 1-by-1 interval representation was made safe for the existing
public MP wrapper, whose scalar objects do not support indexed access.  This
was required by k=1 Kronecker/graph proofs and is a proof-path robustness fix,
not a numerical fallback.  No dependency headers, backend, installed API, or
source implementation outside the NEIGT verification/example tree changed.

Corrective implementation commit: `e3b8bb8` (VA1 fixture audit and subsequent
NEIGT20 integration commit).

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `689aea6c010369fb31a3851d3d40c49148fe5c62` (NEIGT17 report state)
Final implementation commit: `f799487ec3f8512dee35d3ec69ed2427117c7abc`.
Gate: PASS
V-A1 simple portions: PASS, 2/2
V-A1 defective individual claim: correctly refused; block Schur deferred to NEIGT19
V-A integration: expected partial, 3 VA1 jobs recognized
Stress: NOT_RUN
Plotting: NOT_RUN
Push, merge, tag, and publication: NOT_PERFORMED

Known limitation: NEIGT18 does not claim a Schur factor.  Genuine triangular
and defective block-Schur boxes are the mandatory NEIGT19 work.
