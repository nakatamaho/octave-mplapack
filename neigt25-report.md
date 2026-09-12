# NEIGT25 report — isolated clean-package QA and final report

## Result

```text
NEIGT25: PASS
NEIGT00-NEIGT25: ALL PASS
```

The final milestone built the Octave source package from a clean Git
extraction, installed that archive into an owned temporary package prefix, and
ran the complete ordinary and verification walls there. The clean-package run
also checked which provenance, package uninstall/reinstall behavior, real and
complex smoke calls, help, and a replayable exact proof bundle.

NEIGT25 made no numerical implementation change and did not modify MPLAPACK,
gmpfrxx_mkII, dependency headers, installed methods, compiler semantics, or
public precision/rounding APIs. No push, merge, tag, release publication, or
production-prefix modification was performed.

## Branch and commits

Branch:

```text
topic/neigt-tier-sav-examples
```

NEIGT24 report-record starting commit:

```text
cc19daa9afef0c1d7e225a6c0c61108a9fddf700
```

NEIGT25 clean-package runner implementation:

```text
fed191a982acf0904bf73c2ce732fb837b0c36db
```

NEIGT25 QA hardening and final tested commit:

```text
03d1b49b3f4633602b146aa3fcde8d2bfe278e19
```

The report-record commit is created after this report-only update.

## Changed paths

NEIGT25 implementation and QA changes:

```text
tools/run-neigt-clean-package-qa.sh
```

This report is the only additional tracked path in the report-record commit.
The pre-existing untracked user files below were not staged, edited, or
removed:

```text
docs/NEIG-LUNA-XHIGH.md
docs/codex/SVT-GOAL.md
docs/codex/SVT-LUNA-XHIGH.md
docs/codex/svt/
octave-workspace
test/octave-workspace
```

## Exact final clean-package command

The final isolated run was:

```text
artifact=$(mktemp -d /tmp/neigt25-final-proof.XXXXXX)
set -o pipefail
PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
NEIGT25_ARTIFACT_DIR="$artifact" \
timeout 7200s tools/run-neigt-clean-package-qa.sh \
  |& tee /tmp/neigt25-clean-package-qa-final.log
status=${PIPESTATUS[0]}
exit "$status"
```

Exit status: 0.

The runner performed these operations in an owned temporary root:

```text
git archive HEAD -> clean source checkout
SOURCE_DATE_EPOCH=0 tools/build-package.sh
extract mplapack-interop-0.5.0-dev.tar.gz
pkg install -local into a temporary Octave package database
provenance checks with which(…)
ordinary smoke and demo, tier=all
V smoke and demo, all 26 jobs each
real/complex/help smoke
pkg unload and pkg uninstall -nodeps
post-uninstall path check
reinstall
second real/complex smoke
```

The final source-package identity produced by this run was:

```text
Source revision: 03d1b49b3f4633602b146aa3fcde8d2bfe278e19
Source archive: mplapack-interop-0.5.0-dev.tar.gz
Source archive size: 637589
Source archive SHA256: 1c155452eb52a909e38ea7a15f7047841d990bc9476d516ea9ff560616e1c6ee
MPLAPACK: 3.0.1 (/home/docker/opt/octave-mplapack-stack)
```

## Isolated provenance and lifecycle

The clean-package process reported:

```text
which mp:
/tmp/neigt25-clean-qa.TNTEIG/octave-packages/mplapack-interop-0.5.0-dev/@mp/mp.m

which mp_neig_tiers:
/tmp/neigt25-clean-qa.TNTEIG/source-extract/mplapack-interop-0.5.0-dev/examples/neig_tiers/mp_neig_tiers.m

which mp_neig_replay:
/tmp/neigt25-clean-qa.TNTEIG/source-extract/mplapack-interop-0.5.0-dev/examples/neig_tiers/mp_neig_replay.m

MPLAPACK version: 3.0.1
PASS: isolated which provenance
```

No public mp function resolved from the developer checkout. The helper
scripts resolved from the extracted source archive. The selected MPLAPACK
pkg-config prefix was /home/docker/opt/octave-mplapack-stack; the final run
did not select the stale /usr/local MPLAPACK prefix.

Lifecycle results:

```text
PASS: isolated package real/complex/help smoke
PASS: isolated uninstall removes package paths; extracted helper remains
PASS: isolated reinstall second real/complex smoke
PASS: NEIGT25 isolated clean-package QA
```

The function-shadow warnings for compatibility names such as fminbnd,
fminsearch, fsolve, fzero, interp1, interp2, mkpp, pchip, ppder, ppint,
ppval, quadgk, spline, and unmkpp were expected package warnings, not
failures. The post-uninstall check intentionally retained the extracted NEIG
helper path while confirming removal of installed package paths.

## Measured coverage

```text
ordinary smoke, tier=all: 120 measured eig rows
ordinary demo, tier=all: 168 measured eig rows
V smoke: 26 verification jobs, 26 implemented, 26 passing
V demo: 26 verification jobs, 26 implemented, 26 passing
```

The earlier NEIGT24 focused integration gate additionally recorded the
ordinary Tier-S/Tier-A smoke split as 72/48 measured rows and V-S/V-A as
16/10 jobs. NEIGT25 ran the complete tier=all ordinary result and the complete
26-job V result in both profiles.

### Verification job results

The following 26 statuses were identical in V smoke and V demo:

| Job | Result |
| --- | --- |
| VS1-01 | PASS |
| VS1-02 | PASS |
| VS1-03 | PASS |
| VS1-04 | PASS |
| VS1-05 | PASS |
| VS1-06 | PASS |
| VS1-07 | PASS |
| VS1-08 | PASS |
| VS2-01 | CERTIFIED_CLUSTER |
| VS2-02 | CERTIFIED_CLUSTER |
| VS2-03 | CERTIFIED_CLUSTER |
| VS2-04 | CERTIFIED_CLUSTER |
| VS3-01 | PASS |
| VS3-02 | PASS |
| VS3-03 | PASS |
| VS3-04 | PASS |
| VA1-01 | CERTIFIED_SCHUR_TRIANGULAR |
| VA1-02 | CERTIFIED_SCHUR_TRIANGULAR |
| VA1-03 | CERTIFIED_BLOCK_SCHUR |
| VA2-01 | CERTIFIED_ALL_FINITE |
| VA2-02 | CERTIFIED_ALL_FINITE |
| VA2-03 | CERTIFIED_ALL_FINITE |
| VA3-01 | CERTIFIED_PERRON_PAIR |
| VA3-02 | CERTIFIED_PERRON_PAIR |
| VA3-03 | CERTIFIED_PERRON_PAIR |
| VA3-04 | CERTIFIED_PERRON_PAIR |

Defective cases were not claimed diagonalizable; cluster counts were not
treated as exact multiplicity proofs; the defective Schur case was reported
as block Schur; finite pencils used the proved solve reduction; and Perron
certificates included the positive left stationary vector.

## Replayable certificate evidence

The clean-package run generated and exported:

```text
/tmp/neigt25-final-proof.R50XMe/replayable-proof/
```

Raw file SHA256 values:

```text
environment.txt   330 bytes    0b24386698fcd2dd5e72d30b8b533bdbe7850efa5915d8c362e5f802fab809ec
manifest.tsv       404 bytes   b4ee05d1e0a0933cbe4bed8f92267688b78865f020d3d679cd466e4efb816d0f
proof-vs1-01.json 51715 bytes 2816e6cd2029b799cbd43575ed489e1a16736a30de420e8dbeb1cddde7af69cd
report.md          627 bytes   3afaba1cc4b26615fe43db4ce0af36b5f9eefe62975c198b6f16e2187dadf088
rows.tsv           44106 bytes 222e3c8cc9864f40a39d0e05bfeb50ab7e089b5bb27fc4a722b21018b64ba02c
```

The canonical schema-bound proof digest recorded in the manifest, environment,
and report is:

```text
0c4092117ddc2eb73658dbb3e61d1bfb9f2e5f4b54f0422295537d68c6e41c16
```

The proof method is neigt-s1-replay-v1. It stores measured MP inputs,
candidate values, and certificate data separately and does not use eig,
ideal-model reconstruction, or a binary64 numerical fallback during replay.

The exported proof was independently replayed in a fresh Octave process:

```text
timeout 900s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private \
  --path examples/neig_tiers --eval \
  'r = mp_neig_replay ("/tmp/neigt25-final-proof.R50XMe/replayable-proof/proof-vs1-01.json"); assert (r.ok);'
```

Result: PASS, exit status 0.

## Final gates and commands

The final NEIGT25 gates were:

```text
timeout 7200s tools/run-neigt-clean-package-qa.sh
timeout 900s tools/check-neigt-source-package.sh
tools/check-docs.sh
tools/build-docs.sh
tools/check-tree.sh
git diff --check
bash -n tools/run-neigt-clean-package-qa.sh
```

All exited 0. The source-package gate performed two independent clean Git
extractions and reported:

```text
Archive: mplapack-interop-0.5.0-dev.tar.gz
Size: 637589
SHA256: 1c155452eb52a909e38ea7a15f7047841d990bc9476d516ea9ff560616e1c6ee
PASS: NEIGT source package contents and reproducibility
```

The documentation gates reported:

```text
PASS: DOC00 documentation consistency checks
PASS: user HTML, Info/plaintext, Markdown, and Doxygen HTML built
PASS: M00-M23 tree checks
```

Final relevant regressions were run after the NEIGT25 implementation commit:

```text
timeout 900s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private \
  --path examples/neig_tiers --path test --eval 'test_neigt13();'

timeout 1800s octave-cli --no-gui --quiet --no-init-file \
  --path inst --path src --path examples/neig_tiers/private \
  --path examples/neig_tiers --path test --eval 'test_neigt23();'
```

Both exited 0:

```text
PASS: NEIGT13 outward primitives, complex rectangles, range checks, and replay hash
PASS: NEIGT23 exact output, replay, tamper, conflict, and headless gates
```

## All milestone statuses and tested revisions

These are the exact final tested/report-record revisions carried by the
corresponding milestone history. NEIGT18, NEIGT19, and NEIGT20 share the
consolidated corrected verification record at 423ab12….

| Milestone | Status | Tested revision |
| --- | --- | --- |
| NEIGT00 | PASS | 7c98d86fa48c7b0e3a8ace458f431dcc2e384330 |
| NEIGT01 | PASS | 75cd5f126e46044f314ecd4bd2b1239f74da2f84 |
| NEIGT02 | PASS | fc9ef380a7205958d151e2f7f36ef2ed176369d7 |
| NEIGT03 | PASS | c1505b2fe600c8300ae2babff29b42f562903407 |
| NEIGT04 | PASS | c88fef1b6528b77a8cb098d21af41239a951c79d |
| NEIGT05 | PASS | 40e3a749c5b694467bb37555d46f95521f3c0bad |
| NEIGT06 | PASS | 05a64e4f778042a2142f243c954d2dcc31f11dd5 |
| NEIGT07 | PASS | fbb9a6441e1e04dd25c0148d70d69aa772a167cf |
| NEIGT08 | PASS | 3407a72e56c2e25f0a1b95f5ea2c3c38be55918c |
| NEIGT09 | PASS | fed4fe205907f9dfb2c9183cd4c77717c5477449 |
| NEIGT10 | PASS | 3a9a4ce6e85ed82bc4063768eee5a3738dd9cc9a |
| NEIGT11 | PASS | 6c9845545e43d1f3a7947896bf1bc4e4928175c2 |
| NEIGT12 | PASS | 138511fe1f2e1f14fffc8632783435d3fb9af85d |
| NEIGT13 | PASS | d02931ac4858b555763cc8784bfd408ac8cd4511 |
| NEIGT14 | PASS | 90158578d6da11e008a678850ed51808c45b7c1f |
| NEIGT15 | PASS | 2919f8ca1bfa68cc34bd6ce4a1bea7ca40af44ae |
| NEIGT16 | PASS | 5c2cf2aee8099f005a3bc710cf3ce53eb2015896 |
| NEIGT17 | PASS | 689aea6c010369fb31a3851d3d40c49148fe5c62 |
| NEIGT18 | PASS | 423ab12964e180c638c7bf0a39cf3a1ca820285a |
| NEIGT19 | PASS | 423ab12964e180c638c7bf0a39cf3a1ca820285a |
| NEIGT20 | PASS | 423ab12964e180c638c7bf0a39cf3a1ca820285a |
| NEIGT21 | PASS | 139ed7f186899600ca7ccc2f52ccb9b47b2f34a2 |
| NEIGT22 | PASS | dea9d5c61d1443c65f78586f689c33c84340cdfb |
| NEIGT23 | PASS | dc25773fa8f4cd18cfd4562fc3503ae30b038f6f |
| NEIGT24 | PASS | cc19daa9afef0c1d7e225a6c0c61108a9fddf700 |
| NEIGT25 | PASS | 03d1b49b3f4633602b146aa3fcde8d2bfe278e19 |

## Source attribution and contract audit

The NEIGT implementation uses the existing public mp, mpbits, eig, svd, qr,
and solve interfaces. The S1 generator remains the specified Ozaki–Ogita
Theorem-1 error-free triple-product generator with its recorded generation
precision, paired-block rule, requested/realized forms, and independent
exactness checks. The V methods use conservative outward-safe arithmetic and
proof checkers as documented in docs/codex/neigt and the milestone reports;
they are labeled baselines rather than full reproductions of the cited paper
algorithms.

Measured data, work precision, raw solver outputs, auxiliary candidates, and
certificate targets remain separate. Complex left-vector conventions, MP
bijective minimum-bottleneck matching, exact widening, finite pencil solve
reduction, block Schur semantics, and positive normalized Perron pairs are
covered by the earlier focused gates and the final clean-package integration
wall.

## Known limitations and NOT_RUN items

```text
Stress cases: NOT_RUN (opt-in)
Plotting: NOT_RUN; plot=false headless gate PASS
ASan: NOT_RUN in NEIGT25
UBSan: NOT_RUN in NEIGT25
LSan: NOT_RUN in NEIGT25
TeX/PDF manual output: NOT_RUN because no working TeX toolchain was available
```

The sanitizer items were not reported as PASS; NEIGT25 changed only the shell
QA runner and the existing NEIGT13/23 regression contracts were rerun. The
existing whole-worktree check-format.sh cannot be claimed clean because it
scans the pre-existing untracked binary test/octave-workspace; tracked-file
checks and git diff --check pass.

The clean-package source version remains 0.5.0-dev; no package release was
frozen or published by NEIGT25.

## Final conclusion

```text
NEIGT00-NEIGT25: PASS
ISOLATED-CLEAN-PACKAGE-QA: PASS
REPLAYABLE-CERTIFICATE: PASS
SOURCE-PACKAGE-REPRODUCIBLE: PASS
```

No subsequent milestone is started automatically by this report.
