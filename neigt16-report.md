# NEIGT16 report — counted clusters, centered powers, and projectors

NEIGT16 completes the V-S2 acceptance layer on top of the NEIGT15 verified
Riccati graph.  It separates the selected `M` block from `D2` with outward
interval Gershgorin data, adds a centered-power enclosure for defective
fixtures, and computes the raw-basis orthogonal-projector error bound from the
specified `g1`, `alo`, `b`, and sine-of-angle inequalities.

The proof returns `CERTIFIED_CLUSTER` only when all of the following hold:

* the graph is nontrivial and its full basis is certified nonsingular;
* the M/D2 regions are strictly disjoint and the exact block-size count is
  `k+(n-k)=n`;
* the centered-power radius meets the fixed profile target;
* the raw-X1 projector bound meets the fixed profile target.

No exact generator basis, exact root list, or higher-precision replacement
solve is used.  The MKS complement is obtained from a public computed
`eig(...,"nobalance")` call and is recorded as candidate-only data.

## Focused gate

Command:

```text
octave-cli --no-gui --quiet --no-init-file \
  --path /tmp/neigt-work2/inst --path /tmp/neigt-work2/src \
  --path /tmp/neigt-work2/test --eval 'test_neigt16();'
```

Evidence log: `/tmp/neigt16-gate-7.log`.

Result:

```text
PASS: NEIGT16 counted clusters, centered powers, projectors, and traps
ELAPSED:4:15.46
```

The gate covered all four mandatory smoke jobs and checked:

| Job/check | Result |
|---|---|
| VS2-01 SIM_REPEAT | `CERTIFIED_CLUSTER`, PASS |
| VS2-02 SIM_JORDAN | `CERTIFIED_CLUSTER`, PASS |
| VS2-03 SIM_TWO_JORDAN merged group | `CERTIFIED_CLUSTER`, PASS |
| VS2-04 MKS-zero | `CERTIFIED_CLUSTER`, PASS |
| Centered nilpotent square | exact zero, PASS |
| Invalid claimed separation | rejected, PASS |
| Full-space/triviality trap | rejected, PASS |

Representative final measurements at q=768 are:

| Job | required/refined power order | region radius | fixed target | raw projector bound |
|---|---:|---:|---:|---:|
| VS2-01 | 2 / 2 | `2.7016136048916335e-225` | `5.9604644775390625e-8` | `1.2467585179532108e-37` |
| VS2-02 | 2 / 2 | `8.3163278125159194e-112` | `5.9604644775390625e-8` | `1.2467585179532085e-37` |
| VS2-03 | 2 / 16 | `4.8828125e-4` | `4.8834085464477539e-4` | `4.0509016464057407e-36` |
| VS2-04 | 2 / 2 | `1.6242827758820155e-114` | `5.9604644775390625e-8` | `4.7638833777468053e-34` |

For VS2-03 the required block-dimension-2 enclosure is retained in the
witness.  A deterministic additional order `4*k=16` enclosure is used for
the merged physical-spread region; its radius is the value in the table.
The accepted merged target is `2*2^-12 + 2^-24`, as fixed by the manifest.

## Integration gate

Command:

```text
timeout 1500s octave-cli --no-gui --quiet --no-init-file \
  --path /tmp/neigt-work2/inst --path /tmp/neigt-work2/src \
  --eval 'addpath("/tmp/neigt-work2/examples/neig_tiers"); \
  r=mp_neig_verify_examples("smoke",struct("tier","V-S")); \
  fprintf("status=%s ok=%d jobs=%d implemented=%d vs1=%d vs1complete=%d vs2=%d vs2complete=%d\\n", \
  r.status,r.ok,r.coverage.verification_job_count, \
  r.coverage.verification_jobs_implemented,r.coverage.vs1_job_count, \
  r.coverage.vs1_complete,r.coverage.vs2_invariant_job_count, \
  r.coverage.vs2_invariant_complete);'
```

Evidence log: `/tmp/neigt16-integration-2.log`.

Result:

```text
status=PARTIAL_NOT_IMPLEMENTED ok=0 jobs=16 implemented=12 vs1=8 vs1complete=1 vs2=4 vs2complete=1
ELAPSED:10:55.47
```

The top-level partial status is expected because VS3 and V-A jobs remain
unimplemented.  Within the selected V-S scope, all eight VS1 jobs and all four
VS2 jobs are implemented and complete.

## Regression

NEIGT15 was rerun after the candidate and graph changes:

```text
PASS: NEIGT15 bounded candidates, Riccati graph, and fail-closed negatives
ELAPSED:1:37.95
```

The NEIGT15 test now checks the graph's invariant-basis claim directly while
allowing the later NEIGT16 cluster promotion at the job level.

## Implementation and provenance

```text
method: neigt_cluster_power_projector_v1
graph:  neigt_riccati_graph_v1
power:  centered interval matrix powers; required order is the defective block dimension
projector: neigt_raw_basis_projector_bound_v1
candidate: computed contour projector, public QR, public solve/eig complements
paper_algorithm_reproduction: false
```

Interval matrix products remain explicit scalar rectangle operations.  The
nonconjugating Kronecker transpose is preserved.  All proof operations use the
declared MPFR precision and the audited q-range; native binary64 is not a
numerical path.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `2919f8c` (NEIGT15)
Final commit: pending
Files changed: `private/net_v_s2_cluster.m`, `private/net_v_s2_candidate.m`,
`private/net_v_s2_graph.m`, `private/net_v_s2_job.m`,
`private/net_v_s2_newton.m`, `mp_neig_verify_examples.m`,
`test/test_neigt15.m`, `test/test_neigt16.m`, this report
Gate: PASS
Stress and plotting: NOT_RUN
Push, merge, tag, and publication: NOT_PERFORMED

Known limitation: V-S3 and V-A remain outside this milestone.  The selected
merged-cluster power refinement is a conservative bounded baseline and is not
claimed to reproduce the cited paper algorithm.
