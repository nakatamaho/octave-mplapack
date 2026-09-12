# EXDOC01 RESULT

## Result

```text
EXDOC01 PASS — TIERED NEIG/SVD EXAMPLES DECOMPOSED AND DOCUMENTED
D04-READY
```

EXDOC01 is documentation/example decomposition work only. No numerical
backend, dependency header, installed `mp` method, or public numerical API
was changed. D04 was not started automatically.

## Baselines and provenance

| Item | Identity |
|---|---|
| EXDOC01 starting commit | `a8a90586e094ec794262dc14c8e12d5ac1efff33` |
| EXDOC01 implementation commit | `f6188394095cc30394239a75c06ccf2fbeb14400` |
| Working branch | `topic/exdoc01-tiered-examples` |
| Development version | `0.5.0-dev` |
| DOC00 status | `docs/goals/DOC00-documentation-closure-before-D04-status.md` |
| DOC00 implementation freeze | `8f8bbdc0d75ccf4bc572ba843ad6b1ebf4ae0f75` |
| T00-T14 status | `docs/goals/T00-T14-status.md` |
| T00-T14 tested controller HEAD | `8ba6d849fa188765b372d9aa9f899d9de98a78cf` |
| Historical real checkpoint | `0bef79cddd3fdd70abafdf38bc1a4ab492652d33` |

The current MPLAPACK release-candidate provenance remains the identity
recorded by the T-series status document: MPLAPACK 3.0.1, commit
`c7e56f15dd4dc6413a1dc80b9d1c4109b77d5078`, source archive
`mplapack-3.0.1.tar.xz`, SHA256
`77008a2d6cc7b2d310a4d606e013003923872a6840f1098dda8b6f337f137afa`.
The T00-T14 and DOC00 dependency identities are unchanged.

## Original surfaces preserved

| Surface | Original entry point | EXDOC01 treatment |
|---|---|---|
| NEIG Tier S | `examples/14_neig_tier_s.m` | Full smoke aggregator and compatibility index preserved |
| NEIG Tier A | `examples/15_neig_tier_a.m` | Full smoke aggregator and compatibility index preserved |
| SVD Tier S | `examples/14_svd_tier_s.m` | Full smoke aggregator and compatibility index preserved |
| SVD Tier A | `examples/15_svd_tier_a.m` | Full smoke aggregator and compatibility index preserved |
| NEIG verification | `examples/16_neig_verified_vs.m`, `examples/17_neig_verified_va.m` | V verification surfaces preserved unchanged |
| SVD verification | `examples/16_svd_verified.m` | V verification surface preserved unchanged |

## Decomposed families

| Family | Manifest cases | Split runnable examples | Matching Markdown documents | Aggregator smoke cases |
|---|---:|---:|---:|---:|
| Nonsymmetric eigensystem — Tier S | 12 | 12 | 12 | 12 |
| Nonsymmetric eigensystem — Tier A | 9 | 9 | 9 | 8 |
| Singular value decomposition — Tier S | 9 | 9 | 9 | 7 |
| Singular value decomposition — Tier A | 14 | 14 | 14 | 13 |
| **Total** | **44** | **44** | **44** | **40** |

The four demo-only cases remain represented in the original index files and
split documentation, but are not part of the corresponding smoke profile:
`HAD_COMPLEX`, `S1-NRO-SCALE-UP`, `S1-NRO-SCALE-DOWN`, and
`A4-LAU-COMPLEX` as applicable to their manifests.

Master index:

```text
docs/examples/tiered/README.md
```

Migration map:

```text
docs/examples/tiered/MIGRATION.md
```

The requested non-symmetric eigensystem Tier S examples are directly under:

```text
examples/tiered/neig-tier-s/
docs/examples/tiered/neig-tier-s/
```

For example, `examples/tiered/neig-tier-s/sim_simple.m` is the short
runnable entry point and `docs/examples/tiered/neig-tier-s/sim_simple.md`
is its matching explanation.

## Runner and interface changes

The existing full runners now accept an optional `case_id` selection:

```text
examples/neig_tiers/mp_neig_tiers.m
examples/neig_tiers/private/net_options.m
examples/svd_tiers/mp_svd_tiers.m
```

This selects one existing manifest case for a short worked example. An
unfiltered runner invocation retains the original counted profile coverage.
No new public package API was added. The examples use only the existing
public `mp`, `mpbits`, `eig`, `svd`, QR, solve, and related interfaces.

Every split file contains its question, short steps, matching-document link,
package/setup path, one manifest case selection, a success assertion, and a
measured-result summary. Its detailed Markdown counterpart records the
matrix/model, manifest provenance, numerical difficulty, calls, expected
behavior, precision interpretation, conditioning limitations, variations,
common mistakes, and references. Complex eigensystem and SVD explanations
retain conjugate-transpose conventions; repeated and defective eigenspaces
are not described as diagonalizable.

## Documentation integration

Updated documentation surfaces:

```text
README.md
doc/mplapack-interop.texi
docs/mplapack-interop.md
docs/svd-tiers.md
docs/public-api-inventory.md
docs/backend-map.md
docs/advanced-numerics-compatibility.md
docs/octave-script-compatibility.md
docs/examples/tiered/                 # master, migration, 4 family indexes, 44 docs
```

The Texinfo manual now points to the master/family indexes and explains
`case_id`, while the generated Markdown manual was rebuilt with
`tools/build-manual-markdown.sh`. Doxygen was not needed for these
example-only changes. The documentation-as-Definition-of-Done rule remains
the permanent project rule from `AGENTS.md`.

## Verification

All commands below used the installed local stack through
`/home/docker/opt/octave-mplapack-stack/bin/octave-mplapack`, with the
isolated package database, unless explicitly marked source-mode.

| Check | Result |
|---|---|
| `bash -n tools/check-docs.sh tools/test-doc-examples.sh` | PASS |
| `./tools/check-docs.sh` | PASS — documentation consistency and one-to-one checks |
| `./tools/build-manual-markdown.sh` | PASS |
| `git diff --check` | PASS |
| NEIG Tier S aggregator | PASS — 72 measured rows |
| NEIG Tier A aggregator | PASS — 48 measured rows |
| SVD Tier S aggregator | PASS — 42 measured rows |
| SVD Tier A aggregator | PASS — 78 measured rows |
| Four aggregator total | PASS — 240 measured rows, 40 selected smoke cases |
| Independent split examples | PASS — 44/44 |
| Selected help lookups | PASS — 26/26 after package-load fix |
| Source-mode representative examples | PASS — `sim_simple.m` and `hadamard_rank5.m` |
| `test/test_svd_tiers.m` | PASS |
| `test/test_nonsymmetric_eig_suite.m` | PASS — completed after the SVD selftest |

The first complete docs wall reached all old examples and all 44 split
examples successfully, then exposed a tooling defect: the help loop started
fresh Octave processes without loading the package. The one-line fix adds the
same `package_load` preamble to help lookups. The corrected help wall passed
all 26 entries. This was a test-tooling defect only; no numerical example
failure occurred.

The 240 aggregator rows are the native and multiple-precision measured rows
for the four selected smoke profiles. The manifest-level unique smoke case
count is 40; the full manifests still report their original case counts of
12, 9, 9, and 14. The 44 split scripts each execute one case through the
existing runner and are not replacements for the counted smoke aggregators.

## V verification status

The existing V examples and their 26-job verification machinery were not
modified or reclassified by EXDOC01. `examples/16_svd_verified.m` passed in
the documentation wall. The heavy NEIG V-S/V-A pair was intentionally
excluded from the EXDOC01 docs-only wall with:

```text
EXDOC01_SKIP_HEAVY_VERIFICATION=1
```

Their status remains the accepted T00-T14/DOC00 baseline status; no new
EXDOC01 PASS claim is made for a rerun of those heavy jobs. The default
`tools/test-doc-examples.sh` behavior still executes them when the opt-out
is not set. Optional stress and plotting paths were not run.

## Precision and compatibility contract

The decomposition preserves the existing one-operation/one-precision
MPFR/MPC path. It does not add binary64 fallback, alter scalar semantics,
route real-only operations through complex kernels, or change operation-owned
copies used by destructive LAPACK calls. Full runners, manifests, V
certificates, replay data, and existing examples remain in place.

## Actual changed paths

Implementation content is in commit
`f6188394095cc30394239a75c06ccf2fbeb14400`. The changed tracked paths are:

```text
README.md
doc/mplapack-interop.texi
docs/advanced-numerics-compatibility.md
docs/backend-map.md
docs/examples/tiered/                 # master, migration, 4 family indexes, 44 docs
docs/mplapack-interop.md
docs/octave-script-compatibility.md
docs/public-api-inventory.md
docs/svd-tiers.md
examples/14_neig_tier_s.m
examples/14_svd_tier_s.m
examples/15_neig_tier_a.m
examples/15_svd_tier_a.m
examples/neig_tiers/mp_neig_tiers.m
examples/neig_tiers/private/net_options.m
examples/svd_tiers/mp_svd_tiers.m
examples/tiered/                     # 44 split runnable examples
tools/check-docs.sh
tools/test-doc-examples.sh
```

The help-load correction is an additional documentation-test-tool change
included in the small follow-up report commit. User-owned untracked files were
preserved and not staged:

```text
docs/NEIG-LUNA-XHIGH.md
octave-workspace
test/octave-workspace
```

## Upstream/dependency changes

```text
gmpfrxx_mkII: none
MPLAPACK: none
octave-mplapack numerical/native implementation: none
```

No push, merge, tag, release archive, package, Launchpad, PPA, or D04
operation was performed.

## Known limitations

- This milestone splits ordinary Tier S/A examples; V remains the separate
  verification surface.
- The heavy NEIG V-S/V-A wall was not rerun under EXDOC01 and is recorded as
  inherited baseline evidence, not new EXDOC01 measured evidence.
- Optional stress and plotting modes were not run.
- The full 44-example source-tree wall was not repeated after the installed
  package wall; two representative source-mode examples passed.
- The development version remains `0.5.0-dev`; release freezing belongs to
  D04.

## Final status

```text
EXDOC01 PASS — TIERED NEIG/SVD EXAMPLES DECOMPOSED AND DOCUMENTED
D04-READY
```

D04 remains a separate next goal and must not be started automatically.
