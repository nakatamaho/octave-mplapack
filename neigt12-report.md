# NEIGT12 report

Task and milestone: NEIGT — complete ordinary smoke/demo profiles and
preliminary reporting.

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `6c9845545e43d1f3a7947896bf1bc4e4928175c2`

## Implemented

- Replaced the manifest-only ordinary facade with a measured profile runner.
  It constructs each declared frozen model, runs native64 once and every
  declared MP work precision in both `nobalance` and `balance` modes, retains
  raw eig outputs, and widens diagnostics separately at the declared
  evaluation precision.
- Added dispatch/reference coverage for every smoke/demo case, including the
  complex Hadamard control, and records input/model/raw-output hashes,
  reference provenance, environment, timings, residuals, matching and
  condition-status diagnostics.
- Added fixed lower-work `NOT_APPLICABLE_LOWER_WORK` handling.  Only the
  highest declared work precision is evaluated against the fixed forward
  threshold; lower work rows remain measured and cannot be mistaken for a
  failed highest-precision gate.
- Corrected the MKS gate to split the algebraic zero group from the reduced
  polynomial's nonzero roots.  The zero group uses the conservative defective
  boundary `2^(-floor(p/(4*kmax)))`; the nonzero subset retains the simple-root
  target.  This resolved the two false demo failures without changing any
  solver input or measured output.
- Added a line-oriented TSV writer and fixed its newline/tab serialization.
  The all-tier result remains explicitly `NUMERICS_ONLY_COMPLETE` with
  `ok=false` while Tier V is not implemented.

## Gate

NEIGT12: **PASS** — all ordinary smoke and demo rows were present and
measured; every native row completed; every MP row completed; fixed numerical
gates passed; all references were finite and valid; and the all-tier result
honestly retained `verification_status=NOT_IMPLEMENTED` and `ok=false`.

Smoke coverage: 20 cases, 120 measured eig rows, 72 S-tier rows plus 48
A-tier rows.

Demo coverage: 21 cases, 168 measured eig rows, including both modes of the
complex Hadamard case.

The corrected demo MKS nobalance and balance `mp512` rows both passed.  In the
prior run the full MKS normalized bottleneck was about `4.50e-17` because of
the defective zero roots, while the independently checked nonzero subset was
about `1.54e-152`; applying the declared split boundary is therefore required
and is not a threshold relaxation.

## Commands and results

All commands used the installed package environment:

```text
PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib
CPATH=/home/docker/opt/octave-mplapack-stack/include
```

```text
timeout 240s octave-cli --no-gui --quiet --no-init-file \
  --path /tmp/neigt-work2/inst --path /tmp/neigt-work2/src \
  --eval 'run("/tmp/neigt-work2/test/test_neigt12.m");'
exit 0
PASS: NEIGT12 ordinary smoke coverage is 120 rows and V remains explicit
```

```text
timeout 240s octave-cli --no-gui --quiet --no-init-file \
  --path /tmp/neigt-work2/inst --path /tmp/neigt-work2/src \
  --eval 'addpath("/tmp/neigt-work2/examples/neig_tiers"); \
  r=mp_neig_tiers("smoke", struct("tier","all", \
  "output_dir","/tmp/neigt12-smoke-out5")); \
  fprintf("status=%s rows=%d ok=%d\\n", r.status, numel(r.rows), r.ok);'
exit 0
status=NUMERICS_ONLY_COMPLETE rows=120 ok=0
```

```text
timeout 1200s octave-cli --no-gui --quiet --no-init-file \
  --path /tmp/neigt-work2/inst --path /tmp/neigt-work2/src \
  --eval 'addpath("/tmp/neigt-work2/examples/neig_tiers"); \
  r=mp_neig_tiers("demo", struct("tier","all", \
  "output_dir","/tmp/neigt12-demo-out3")); \
  fprintf("status=%s rows=%d ok=%d ordinary=%d\\n", \
  r.status, numel(r.rows), r.ok, r.coverage.ordinary_complete);'
exit 0
status=NUMERICS_ONLY_COMPLETE rows=168 ok=0 ordinary=1
```

```text
timeout 180s octave-cli --no-gui --quiet --no-init-file \
  --path /tmp/neigt-work2/inst --path /tmp/neigt-work2/src \
  --eval 'addpath("/tmp/neigt-work2/examples/neig_tiers"); \
  r=mp_neig_tiers("smoke", struct("tier","A", \
  "output_dir","/tmp/neigt12-writer-out")); \
  fprintf("status=%s rows=%d ok=%d\\n", r.status, numel(r.rows), r.ok);'
exit 0
status=NUMERICS_COMPLETE rows=48 ok=1
wc -l /tmp/neigt12-writer-out/neigt-smoke-rows.tsv
49
```

The attempted MAT serialization of the full result was not used as evidence:
Octave's MP matrix serialization raised
`array_value(): wrong type argument 'mplapack_mpfr_matrix_internal'`.  The
runner itself completed successfully; NEIGT12 evidence uses the returned
status and the line-oriented TSV output, and no large MAT artifact is part of
the repository.

## Files changed

`examples/neig_tiers/mp_neig_tiers.m`,
`examples/neig_tiers/mp_neig_tiers_selftest.m`,
`examples/neig_tiers/private/net_case_model.m`,
`examples/neig_tiers/private/net_case_reference.m`,
`examples/neig_tiers/private/net_dyadic_parameter.m`,
`examples/neig_tiers/private/net_raw_hash.m`,
`test/test_neigt01.m`, `test/test_neigt12.m`, and this report.

Final commit: pending NEIGT12 commit.

## Limitations and next milestone

Tier V-S/V-A verification, audited outward arithmetic, exact certificate
serialization/replay, adversarial proof tests, and clean-package QA remain
unimplemented.  `ok=false` for `tier=all` is intentional and is not a
milestone failure.  Stress and plotting were not run.

Next milestone: NEIGT13 — audited outward arithmetic and exact serialization.
