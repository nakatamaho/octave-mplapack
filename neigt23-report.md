# NEIGT23 report — output, independent replay, and presentation

## Result

NEIGT23 PASS.  The output/replay gate exited 0:

```text
PASS: NEIGT23 exact output, replay, tamper, conflict, and headless gates
```

The gate covered a complete ordinary smoke output bundle (120 measured rows),
exact MP proof serialization, fresh in-process replay, fresh-process replay,
tamper rejection, existing-directory rejection, report/TSV creation, and
`plot=false` headless behavior.  No plot file was emitted.

The replay result recorded `called_eig=false` and
`reconstructed_ideal_model=false`.  It re-ran the V-S1 certificate from the
serialized `A`, `X`, `T`, and `R` values, checked counted all-spectrum
coverage, singleton usefulness, the fixed usefulness target, and exact
certificate re-encoding.  Stored status and bounds were not trusted.

## Implementation

The new public example APIs are:

```text
examples/neig_tiers/mp_neig_write_outputs.m
examples/neig_tiers/mp_neig_replay.m
```

The writer creates only a new directory containing:

```text
rows.tsv
manifest.tsv
environment.txt
proof-vs1-01.json
report.md
```

The exact serializer is implemented in:

```text
examples/neig_tiers/private/net_neigt_capture_s1.m
examples/neig_tiers/private/net_neigt_encode_value.m
examples/neig_tiers/private/net_neigt_decode_value.m
examples/neig_tiers/private/net_neigt_json_encode.m
examples/neig_tiers/private/net_neigt_json_read.m
examples/neig_tiers/private/net_neigt_json_write.m
```

MP values are encoded element-by-element through the existing dyadic
extraction contract.  Decode sets the recorded destination precision before
mantissa reconstruction.  Complex values, matrices, cells, structs, logicals,
shapes, and finite metadata are tagged.  An explicit JSON array wrapper keeps
one-element arrays stable across `jsondecode` and re-encoding.  The top-level
schema, method version, profile, job, precision, payload, and SHA256 are
bound together.

The replay path contains no `eig` call and no model constructor.  It uses only
the stored exact input/candidate matrices and `net_v_s1_gershgorin` to
recompute the proof.  A modified target, method, endpoint, shape, input, or
certificate fails hash/predicate validation.

The existing ordinary row template was corrected so model/raw hashes and
error fields are initialized to empty values rather than neighboring field
names.  This changes only emitted metadata, not numerical inputs or results.

## Commands and evidence

Full gate:

```text
set -o pipefail; timeout 3600s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private \
  --path examples/neig_tiers --path test --eval 'test_neigt23();' \
  |& tee /tmp/neigt23-gate-2.log
```

Exit status: `0`.

Regression:

```text
set -o pipefail; timeout 900s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private \
  --path examples/neig_tiers --path test --eval 'test_neigt13();' \
  |& tee /tmp/neigt23-neigt13-regression.log
```

Exit status: `0`:

```text
PASS: NEIGT13 outward primitives, complex rectangles, range checks, and replay hash
```

The corrected implementation probes and their evidence remain in:

```text
/tmp/neigt23-quick.log
/tmp/neigt23-quick-2.log
/tmp/neigt23-quick-3.log
/tmp/neigt23-quick-4.log
/tmp/neigt23-quick-5.log
/tmp/neigt23-quick-6.log
/tmp/neigt23-quick-7.log
/tmp/neigt23-quick-8.log
/tmp/neigt23-quick-9.log
/tmp/neigt23-quick-10.log
/tmp/neigt23-quick-11.log
/tmp/neigt23-gate-1.log
/tmp/neigt23-gate-2.log
```

The failed probes were not hidden: they found, in order, a manifest profile
lookup error, untagged MP payload, Octave scalar `mp` indexing, JSON
one-element-array canonicalization differences, decode at the wrong precision,
and a missing `inst/src` path in the restart command.  Each was repaired and
the final gate was rerun.  The first full gate failed only in that restart
test command and is not counted as the final gate.

## Precision, presentation, and scope

The smoke proof was stored at evaluation precision 768 bits.  No binary64
fallback, builtin binary64 complex arithmetic, dependency change, MPLAPACK
change, installed-method change, or public precision API change was made.

Stress: `NOT_RUN` (opt-in).

Plotting: `NOT_RUN`.  The required `plot=false` headless test passed; display
conversion is not numerical evidence.

The writer emits one complete replayable representative proof artifact,
V-S1-01, alongside the complete ordinary TSV.  NEIGT22 remains the
authoritative evidence for all 26 V jobs; NEIGT25 owns final clean-package
all-profile output aggregation.  This report does not claim V-S2/V-S3/V-A
artifacts were serialized by this writer.

No push, merge, tag, or publication was performed.

## Required milestone record

Branch: `topic/neigt-tier-sav-examples`

Starting commit: `dea9d5c61d1443c65f78586f689c33c84340cdfb`

Final commit: to be recorded by the NEIGT23 report-record commit.

Files changed:

```text
examples/neig_tiers/mp_neig_replay.m
examples/neig_tiers/mp_neig_write_outputs.m
examples/neig_tiers/mp_neig_tiers.m
examples/neig_tiers/private/net_neigt_capture_s1.m
examples/neig_tiers/private/net_neigt_decode_value.m
examples/neig_tiers/private/net_neigt_encode_value.m
examples/neig_tiers/private/net_neigt_json_encode.m
examples/neig_tiers/private/net_neigt_json_read.m
examples/neig_tiers/private/net_neigt_json_write.m
test/test_neigt23.m
neigt23-report.md
```

Commands run: the full NEIGT23 gate and NEIGT13 regression commands above,
plus the quick Tier-S output/replay probes.

Tests: NEIGT23 output/replay/tamper/conflict/headless PASS; NEIGT13
arithmetic/serialization regression PASS.

Gate: `PASS`

Known limitations: stress and plotting were not run.  Only the declared
V-S1-01 representative is serialized/replayed by this output writer; complete
all-26 V-job clean-package aggregation remains NEIGT25 work.
