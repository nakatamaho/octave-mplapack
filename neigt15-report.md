# NEIGT15 report — bounded candidates and invariant graphs

NEIGT15 adds the candidate-only and proof-side machinery for the V-S2
invariant-subspace jobs.  A contour projector is evaluated at the declared
16, 32, and 64 nodes, followed by public QR and at most two completion
strategies.  The resulting basis is only a candidate.  A bounded, at-most-four
step point Newton correction is also recorded as candidate preparation; it is
never treated as a certificate.

The proof path constructs a separately checked similarity enclosure, partitions
it, forms the nonconjugating-transpose Kronecker operator explicitly, and
verifies the preconditioner residual and Riccati self-map/contraction bounds
with the NEIGT13 outward rectangle arithmetic.  The returned claim is only a
nontrivial `CERTIFIED_INVARIANT_BASIS`; cluster separation and projector-width
claims are intentionally deferred to NEIGT16.

## Focused gate

Command:

```text
octave-cli --no-gui --quiet --no-init-file \
  --path /tmp/neigt-work2/inst --path /tmp/neigt-work2/src \
  --eval 'run("/tmp/neigt-work2/test/test_neigt15.m");'
```

Evidence log: `/tmp/neigt15-gate-2.log`.

Results:

| Check | Result |
|---|---|
| Exact synthetic graph with nonzero quadratic term | PASS |
| Candidate Newton, maximum four steps | PASS |
| Nonconjugating complex Kronecker transpose | PASS |
| Deliberately wrong conjugating transpose | rejected, PASS |
| Singular preconditioner | rejected, PASS |
| Failed contraction | rejected, PASS |
| Computed SIM_REPEAT (`VS2-01`) | `CERTIFIED_INVARIANT_BASIS`, PASS for NEIGT15 |
| Computed SIM_JORDAN (`VS2-02`) | `CERTIFIED_INVARIANT_BASIS`, PASS for NEIGT15 |
| Contour nodes | 16, 32, 64; 0 failed nodes |
| Completion strategies | at most 2; first successful strategy retained |

The focused gate completed in `1:32.98` and ended with:

```text
PASS: NEIGT15 bounded candidates, Riccati graph, and fail-closed negatives
```

The V-S integration smoke command also reran all eight VS1 jobs and the two
implemented VS2 jobs.  It completed in `8:03.81` with:

```text
status=PARTIAL_NOT_IMPLEMENTED ok=0 jobs=16 implemented=10 vs1=8 vs1complete=1 vs2=2 vs2complete=1
```

The partial status is intentional: VS2-03 and VS2-04 remain reserved for
NEIGT16, and the manifest-level 26-job result is not claimed here.

The two computed jobs use the smoke source precision (256 bits) for model and
candidate preparation and 768 bits for the proof evaluation.  They each used
the declared 16/32/64 contour schedule and completed with one strategy.  The
graph proof has a nontrivial split `1 <= k < n`; no full-space identity
projector is used.

## Method and provenance

```text
candidate method: neigt_candidate_contour_qr_v1
Newton method:    neigt_candidate_graph_newton_v1
proof method:     neigt_riccati_graph_v1
paper_algorithm_reproduction: false
candidate source: computed_subspace_bounded_schedule
```

All candidate roots, bases, and Newton iterates remain distinct from the
outward proof inputs.  No generator columns, higher-precision replacement
eigensolve, native binary64 arithmetic, or public API/dependency change was
introduced.

## Scope and limitations

NEIGT15 implements only the invariant-basis portion of V-S2.  The four
mandatory V-S2 jobs do not yet satisfy their final `CERTIFIED_CLUSTER`,
centered-power, or raw-projector usefulness claims; NEIGT16 owns those gates.
V-S3 and all V-A jobs remain unimplemented.  Stress and plotting were not run.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `9015857` (NEIGT14)
Final commit: pending (implementation staged after the gates above)
Files changed: `private/net_v_s2_candidate.m`, `private/net_v_s2_graph.m`,
`private/net_v_s2_job.m`, `private/net_v_s2_newton.m`,
`mp_neig_verify_examples.m`, `test/test_neigt15.m`, this report
Commands run: focused NEIGT15 gate above; direct VS2-01 and VS2-02 computed
job checks; V-S integration smoke with the eight VS1 and two active VS2 jobs
Tests: NEIGT15 focused gate PASS; NEIGT13 arithmetic regression PASS; V-S
integration smoke complete with VS1 complete and active VS2 milestone complete
Gate: PASS
Known limitations: final V-S2 cluster/projector acceptance is deferred to
NEIGT16; no push, merge, tag, or publication was performed.
