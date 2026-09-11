# NEIGT14 report — V-S1 counted all-spectrum certificates

NEIGT14 implements the first mandatory verified-spectrum tier.  The checker
uses the raw highest-work, nobalance `eig` output as its candidate.  It widens
that output to the declared evaluation precision, proves the inverse residual
with explicit complex-rectangle products, bounds the similarity residual, and
then applies outward Gershgorin disks and their overlap supergraph.  No
higher-precision eigensolve, root substitution, or binary64 fallback is used.

The matrix-product implementation batches independent row-vector scalar
operations only to reduce interpreter overhead.  Each real endpoint product,
sum, and subtraction is still an independently rounded MP operation and is
enclosed with the audited `8*2^-q*abs(r)` primitive bound.  This changed the
GRCAR certificate timing from approximately 4 minutes to 86 seconds without
changing the proof predicates.

## Gate evidence

Command:

```text
octave-cli --no-gui --quiet --no-init-file \
  --path /tmp/neigt-work2/inst --path /tmp/neigt-work2/src \
  --eval 'run("/tmp/neigt-work2/test/test_neigt14.m");'
```

Evidence log: `/tmp/neigt14-gate-3.log`.

Profile and proof precision:

```text
profile: smoke
candidate bits: 256
evaluation bits: 768
usefulness target: 2^-40
candidate: raw highest-work nobalance V,D,W
```

| Job | Core case | Dimension | Result |
|---|---|---:|---|
| VS1-01 | OO53_REAL | 8 | PASS |
| VS1-02 | OO53_PAIR | 8 | PASS |
| VS1-03 | OO128_CLOSE | 8 | PASS; close first pair remains separate |
| VS1-04 | TOEPLITZ | 16 | PASS |
| VS1-05 | HAD_BIDIAG | 8 | PASS |
| VS1-06 | FRANK0 | 8 | PASS |
| VS1-07 | WILKINSON | 10 | PASS |
| VS1-08 | GRCAR | 12 | PASS |

All eight jobs returned `CERTIFIED_ALL`, counted exactly all `n` roots, had
`n` singleton components, and met the usefulness bound
`max_radius / verified_frobenius_upper <= 2^-40`.  The run also executed the
negative checks: a zero inverse candidate returned
`INCONCLUSIVE_INVERSE_RESIDUAL`, and touching disks returned
`CERTIFIED_ALL_NOT_USEFUL` rather than a singleton claim.

Measured wall time:

```text
full focused gate: 7:05.99
```

The logged interval-certificate times were 29.154 s, 31.009 s, 26.006 s,
146.984 s, 26.168 s, 25.904 s, 44.375 s, and 81.602 s for VS1-01 through
VS1-08, respectively.  The final two negative checks completed after the
positive jobs.

## Proof/code map

| Requirement | Implementation |
|---|---|
| RN primitive and range contract | `private/net_iv_primitive.m`, `private/net_iv_round.m` |
| Explicit complex rectangle matrix products | `private/net_iv_cmatrix_mul.m` |
| Verified inverse residual | `private/net_iv_inverse_residual.m` |
| Similarity residual and Neumann transfer | `private/net_v_s1_gershgorin.m` |
| Gershgorin disks and overlap graph | `private/net_v_s1_gershgorin.m` |
| Raw candidate/hash binding | `mp_neig_verify_examples.m` |
| Positive and negative focused gate | `test/test_neigt14.m` |

The method identifier is `neigt_similarity_gershgorin_v1` and
`paper_algorithm_reproduction=false`.  The certificate is a conservative
example-local baseline, not a claim to reproduce a paper implementation or
its complexity.

## Scope and limitations

Only the V-S1 jobs are implemented by this milestone.  The V-S2, V-S3, and
V-A jobs remain explicitly `NOT_IMPLEMENTED` and therefore the all-verifier
facade is not yet complete.  No stress profile, plot, source-package QA, or
clean-package QA was claimed here.

Branch: `topic/neigt-tier-sav-examples`
Starting commit: `d02931ac4858b555763cc8784bfd408ac8cd4511`
Final commit: pending
Files changed: `mp_neig_verify_examples.m`, `private/net_iv_cmatrix_mul.m`,
`private/net_iv_primitive.m`, `private/net_iv_round.m`,
`private/net_v_s1_gershgorin.m`, `test/test_neigt14.m`, this report
Commands run: focused NEIGT14 gate above; NEIGT13 regression after the
batched-product change
Tests: NEIGT13 PASS; VS1-01..08 PASS; negative inverse/overlap checks PASS
Gate: PASS
Known limitations: later NEIGT milestones are not implemented yet; no push,
merge, tag, or publication was performed.
