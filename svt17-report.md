# SVT17 report

## Result

SVT17: PASS. The complete measured smoke/demo profiles, versioned
machine-readable artifacts, exact dyadic snapshots, replay checker, and
negative coverage controls passed for the allocated SVT case set.

## Scope and implementation

SVT17 completed the measured-artifact and replay path for the existing
Tier-S/Tier-A cases. The implementation is confined to the SVT example and
private verification code; it does not alter the MPLAPACK backend, add a
dependency, or introduce a binary64 fallback.

Files changed in the SVT17 implementation commit:

```text
examples/svd_tiers/mp_svd_tiers.m
examples/svd_tiers/private/svt_build_case.m
examples/svd_tiers/private/svt_certify_factor_boxes.m
examples/svd_tiers/private/svt_check_coverage.m
examples/svd_tiers/private/svt_dyadic_decode.m
examples/svd_tiers/private/svt_json_safe.m
examples/svd_tiers/private/svt_replay_snapshots.m
examples/svd_tiers/private/svt_run_profile.m
examples/svd_tiers/private/svt_serialize_mp_array.m
examples/svd_tiers/private/svt_write_profile_artifacts.m
```

The numerical path remains one-operation/one-precision MPFR/MPC. Inputs,
factors, and replay snapshots are serialized as exact dyadic values. The
profile is headless with `plot=false`; no plots or build artifacts are part
of the repository.

## Gate commands

The following environment was used for both profiles:

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
```

Smoke profile:

```sh
octave --no-gui --quiet --no-init-file --path inst --path src \
  --eval "addpath('examples/svd_tiers'); \
  r=mp_svd_tiers('smoke', struct('tier','all', \
  'output_dir','/tmp/svt17-smoke.wgeH2T/artifacts','plot',false)); \
  assert(r.ok); assert(r.measured_svd_rows==120); assert(r.v_job_count==34);"
```

Demo profile and in-process replay:

```sh
octave --no-gui --quiet --no-init-file --path inst --path src \
  --path examples/svd_tiers/private --eval \
  "addpath('examples/svd_tiers'); \
  r=mp_svd_tiers('demo', struct('tier','all', \
  'output_dir','/tmp/svt17-demo.HB0P1l/artifacts','plot',false)); \
  assert(r.ok); assert(r.measured_svd_rows==184); \
  q=svt_replay_snapshots('/tmp/svt17-demo.HB0P1l/artifacts/inputs-and-factors.json'); \
  assert(q.status=='PASS'); assert(q.records==23 && q.snapshots==92);"
```

The standalone replay invocation explicitly adds the private helper path:

```sh
octave --no-gui --quiet --no-init-file --path inst --path src \
  --eval "addpath('examples/svd_tiers'); \
  addpath('examples/svd_tiers/private'); \
  q=svt_replay_snapshots('/tmp/svt17-smoke.wgeH2T/artifacts/inputs-and-factors.json'); \
  assert(strcmp(q.status,'PASS')); assert(q.records==20 && q.snapshots==80);"
```

An independent structural checker verified row counts, unique
`(case_id,mode,native,work_bits)` keys, JSON record/snapshot counts, gate and
target values, canonical hash lengths, and absence of a `plots/` directory.
The coverage checker was also run with an empty row set and with duplicate
rows; both negative controls rejected the invalid coverage.

## Measured results

```text
profile   cases  measured SVD rows  references  V jobs  records  snapshots
smoke       20          120/120          40       34       20         80
demo        23          184/184          46       41       23         92
```

All targeted V jobs had `gate=1` and `target=1`. The demo included V1A for
all 23 cases, selected native V1A jobs, V1B factor-box jobs, V2 projector
jobs, V3 positive checks, the explicit poor/singular negative controls, and
the rectangular unsupported gate. V3 negative controls were `INCONCLUSIVE`
with a passing gate, as required; no inconclusive result was promoted to a
false singularity or accuracy claim.

The runs used GNU Octave 11.1.0 and the already installed, recorded
MPLAPACK 3.0.1 release-candidate environment. No MPLAPACK rebuild or source
installation was performed during SVT17. The demo took approximately
3 hours 21 minutes and used substantial temporary process memory; that RSS
and all `/tmp/svt17-*` artifacts are excluded from the repository and were
not committed.

## Artifact evidence

The demo artifacts were written only under:

```text
/tmp/svt17-demo.HB0P1l/artifacts
```

They were independently checked and are not source-controlled. Their
SHA256 values were:

```text
certificates.json       35a5189185056f9775b9116cd2f3154a338323232608dc468bd55622e454eb02
environment.txt         929687726dbcd41dc12f3fa4b428d84ea59f04f9af1618b2cb0ed1ed055e7350
inputs-and-factors.json 8bafcb7e331f014246071dbdbba6633e1fabaf57bed26091509060c513f811e4
report.md               6d874f6dc2179784f0a97395054ad6b897b345b654712dad894f99b7668e45b2
singular-values.tsv     e7187d79857f58776701f16b80481c59a2c50e0040cf5f137e417a1f51c4c043
summary.json             657ca62e70a40fc41886e0b274b5f56f6762d3c733608c3cde08028267f8a484
summary.tsv              6bc417cf049f50eb77a66ec10607accd3b97cefc5ebb352e154aad06af4a8a35
verification.tsv         917deba8ea68f2399edf1350895cf1f222ec60f1416a6f73dd014fbaedea5fb8
```

The `inputs-and-factors.json` file contains 23 complete target/factor
records and 92 replay snapshots (input, U, S, and V for each case). The
smoke replay independently reported 20 records and 80 snapshots.

## Final gate record

```text
Branch:
    topic/svd-tier-sav-examples

Starting commit:
    fbd08cec1107465c95d9598b2bf5d9f06d467c04

Final implementation commit:
    60955ce (SVT17: add complete measured artifacts and replay)

Files changed:
    10 SVT facade/private implementation files listed above

Commands run:
    smoke profile, demo profile, standalone snapshot replay,
    independent artifact structure check, and empty/duplicate coverage
    negative controls; all with plot=false and the recorded local stack

Tests:
    smoke 120/120; demo 184/184; all V gates and artifact checks PASS

Gate:
    SVT17 PASS

Known limitations:
    The generated measurement artifacts remain temporary evidence under
    /tmp and are intentionally not committed. The demo is computationally
    expensive. SVT18 documentation/integration work remains.
```

No push, merge, tag, release, package publication, or MPLAPACK rebuild was
performed.
