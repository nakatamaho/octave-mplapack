# SVT00--SVT19 master report

## Final result

```
SVT00-SVT19: PASS
SVT-API-CLOSED
SVT-PACKAGE-QA-CLOSED
LARGE-ARTIFACT-COMMIT: NOT PERFORMED
PUSH/RELEASE/PUBLISH: NOT PERFORMED
```

All twenty milestones passed in sequence. Each milestone has a root
svtXX-report.md. The final package boundary was exercised from an extracted
source archive with an isolated installed package and isolated package
database. No MPLAPACK rebuild or source modification was performed.

This master report is evidence for the SVT-LUNA-XHIGH goal only. It does not
freeze or release MPLAPACK, does not start D00/D01, and does not authorize a
push, merge, tag, binary package, Debian package, PPA, or registry submission.

## Final source state

```
Repository:
    /tmp/t00-t14

Branch:
    topic/svd-tier-sav-examples

SVT19 report commit:
    1ed8b044f4dae898ad9290fd9ddd1312164d839d

Master-report commit:
    recorded after this report is committed

Historical SVT starting commit:
    760ec415a6f2b634f5cb80ee53758925cd32b83d

Octave:
    GNU Octave 11.1.0

Installed dependency environment:
    /home/docker/opt/octave-mplapack-stack

MPLAPACK dependency:
    3.0.1 release-candidate interface supplied by the existing QA environment
```

The SVT worktree was clean before this master report was added. The
multi-gigabyte Octave RSS observed while running the demo was temporary
process memory, not a repository artifact. No 4.2GB (or larger) memory image,
measurement bundle, native output, or package build directory was staged.

## Twenty-milestone status and exact state commits

The commit column identifies the implementation/report state used for the
milestone. SVT09 deliberately lists both family implementation commits:
the A2 Vandermonde implementation ended at f99c924..., the A3 bidiagonal
implementation ended at 0de2e170..., and the later 2ac674... state corrected
the consolidated SVT09 report while adding the next A4/A5 family.

| Milestone | Result | Scope and actual measured evidence | Implementation/report state |
|---|---|---|---|
| SVT00 | PASS | Existing real/complex SVD API, module paths, precision contract, and non-destructive reuse map audited; focused existing tests passed. | 9cc37c62733ee645dd0b8096fc989e7ef66c5c2a |
| SVT01 | PASS | Manifest facade, profile filters, precision cleanup, exact widening, path restoration, and output-directory safety passed; smoke=20 cases/120 rows and demo=23 cases/184 rows recorded. | ae72b006f0b7c4e5df2b8758d2e9c56b3df72893 |
| SVT02 | PASS | Exact Sylvester H/G, dyadic power/scaling, projectors, guards, and construction selftests passed. | 71861dcb8ad182442d30f770a55f049fe67f055b |
| SVT03 | PASS | Values-only/economy runner, frozen-input references, complex V convention, residual/orthogonality metrics, and provisional comparison selftest passed. | 35b6a89303d803c7cc3c27cc366d80f5ab11fe73 |
| SVT04 | PASS | S1 NRO two/three/graded constructors and measured rows passed; 84 measured rows. | 1d337398832cd351552467c95aef0e7930ae43fb |
| SVT05 | PASS | S2 Jacobi--Stirling recurrence, exact 5x5 fixture, and measured rows passed; 20 measured rows. | 6ba442bea1d8e461281ad09b7c0ec87106fac3ce |
| SVT06 | PASS | S3 unsigned Lah recurrence, rank metadata, and measured rows passed; 20 measured rows. | c965768d9c5f0a963aaf82aed9430a6ad8b7f428 |
| SVT07 | PASS | S4 symmetric/nonsymmetric diagonally-dominant paths, tau-loss control, and rank proof passed; 40 measured rows. | a243451a28901f9e0bb691d9013ccb77b062d954 |
| SVT08 | PASS | A1 lower/symmetric Pascal recurrences, P=Q*Q' identity, and measured rows passed; 40 measured rows. | 12322f51321f48cd6fc5044bb1e5e4611691d0e5 |
| SVT09 | PASS | A2 dyadic Vandermonde and A3 graded bidiagonal raw/mixed families passed; 60 combined measured rows. | f99c92421946530eb519555e6a279dd2f9b5302a; 0de2e170ac1b11c72d4f88c5ae2747b7214cded4; report correction 2ac674afaf5c0347b94d9050d586bf5eef0ccf41 |
| SVT10 | PASS | A4 Lauchli and A5 Hadamard spectrum/geometric/close/repeated/rank controls passed; 152 measured rows. | 2ac674afaf5c0347b94d9050d586bf5eef0ccf41 |
| SVT11 | PASS | A6 bounded-integer NRO companion-like family, Horner proof, entry bound, inverse fixture, and measured rows passed; 20 measured rows. | 19b584351600602edad7894f89d31cec09ba0a84 |
| SVT12 | PASS | V0.1--V0.3 outward scalar/interval/rectangle arithmetic and V4 exact dyadic serialization/replay passed. | acbf0c68efa3f4fe0e971ec8d364b10bf8bddf4b |
| SVT13 | PASS | V1a polar/Weyl singular-value enclosures consumed actual SVD factors and passed all malformed/complex/zero/adversarial gates. | f60ef5260b775769f0180ba6fe6b5bd903af9a1a |
| SVT14 | PASS | V1b signed-dilation cluster projectors, structural zeros, rotations/permutations, and collapse negative control passed. | 2e0ae606f67b22484e6d2ca986475bf1d99c5679 |
| SVT15 | PASS | V2 compatible simple-factor boxes, common-phase behavior, multiplicity handling, and real/complex cases passed. | 3d8b3744616f4717b271ae0c22cc530ed6a8752d |
| SVT16 | PASS | V3 verified inverse residual/norm/sigma-min bounds and singular/poor/rectangular negative controls passed. | fbd08cec1107465c95d9598b2bf5d9f06d467c04 |
| SVT17 | PASS | Complete measured artifacts and replay passed: smoke 120/120, demo 184/184, V jobs 34/41. | 60955ce809badf6cb48f4c6a9f587ad9a5affce8; report 4f73726d10ae020d3ec70213009051fc335437fe |
| SVT18 | PASS | Examples 14--16, SVD-tier/verification docs, manual regeneration, docs/example checks, and existing regression integration passed. | 36c8687c708eec132d59594dc6b98d752c62a47d; report bb6badb74cf20dc988f382b537d2e37c092555aa |
| SVT19 | PASS | Reproducible source package, isolated package smoke/demo, lifecycle, provenance, and fresh reinstall smoke passed. | 1ed8b044f4dae898ad9290fd9ddd1312164d839d |

The per-milestone detailed records are:

```
svt00-report.md through svt19-report.md
```

## Numerical S/A measurement wall

The normative manifest was executed with the existing public MP SVD API. At
the highest work precision, exact MPFR/MPC values and V4 snapshots were
retained; values were not down-converted to binary64. The measured source-tree
wall recorded:

```
Profile:       cases   measured SVD rows   references   V jobs   records   snapshots
smoke:           20          120/120            40         34       20         80
demo:            23          184/184            46         41       23         92
```

The measured family coverage was:

```
S1 NRO two/three/graded:                    84 rows
S2 Jacobi--Stirling:                        20 rows
S3 unsigned Lah:                            20 rows
S4 DD symmetric/nonsymmetric:               40 rows
A1 Pascal:                                  40 rows
A2 Vandermonde + A3 bidiagonal:             60 rows
A4 Lauchli + A5 Hadamard spectrum:         152 rows
A6 NRO companion-like:                      20 rows
```

The smoke and demo V walls covered all highest-precision S/A rows and the
required V1A, V1B, V2, and V3 jobs. Every completed verification job had gate
value 1 and target value 1. Expected negative classifications remain
fail-closed: unsupported individual repeated factors are not certified,
singular/poor inverse controls are INCONCLUSIVE, and rectangular V3 inverse
claims are UNSUPPORTED_RECTANGULAR.

## Precision and API contract

The implementation is example-local and private except for the already
existing public SVD interface. It preserves:

- MPFR/MPC one-operation/one-precision behavior through every complex path.
- public mp value semantics and operation-owned copies for destructive LAPACK
  calls.
- exact MP dyadic/integer construction and exact widening for diagnostics.
- no binary64 complex fallback, no hidden double norm/comparison path, and no
  routing of existing real-only operations through complex kernels.
- no new public rounding API, interval dependency, native SVD driver, backend,
  or numerical dependency.

The V implementation consumes the actual returned MPFR/MPC SVD factors and
the represented input. It does not recompute SVD, orthonormalize factors, or
claim a complete Rump--Lange/Rump--Ogita implementation. Every artifact
records paper_algorithm_reproduction=false.

The four verifier method IDs are:

```
svt_polar_weyl_v1
svt_dilation_projector_v1
svt_dilation_factor_boxes_v1
svt_neumann_inverse_v1
```

## Documentation, examples, and regression gates

The authoritative manual source remains doc/mplapack-interop.texi. Derived
Markdown was regenerated with the local texi2any/DocBook/Pandoc pipeline.
SVT18 added docs/svd-tiers.md, docs/svd-verification.md, and examples 14--16.

The following actual gates passed:

```
tools/check-tree.sh
tools/check-format.sh
tools/check-docs.sh
tools/build-manual-markdown.sh
tools/build-docs.sh
tools/test-doc-examples.sh
test/test_svd_tiers.m
test/test_svd_verification.m
test/run_tests.m
```

The documentation example wall executed examples 01--16. The existing runner
passed M/C/N, mandatory C11L, NEIG, T00--T14, N07/N08, S00--S08, and SVT18
integration. The build-docs gate produced HTML, Info/plaintext, Markdown, and
Doxygen output. PDF was not generated because no working TeX engine was
available; this is the documented fallback and did not invalidate the
manual/example gate.

## SVT19 package boundary and reproducibility

Two SOURCE_DATE_EPOCH=0 builds of the source package and two independent
git-archive builds were identical:

```
Archive:
    dist/mplapack-interop-0.5.0-dev.tar.gz

Size:
    568787 bytes

SHA256 A:
    0d241528616dc3b747f2759ec4af9991aae78346a3f41bdeecb7ff687a6932c8

SHA256 B:
    0d241528616dc3b747f2759ec4af9991aae78346a3f41bdeecb7ff687a6932c8

Hashes identical:
    YES

Archive entries:
    736
```

The archive includes DESCRIPTION, the manual, SVT documentation, examples
14--16, and both SVT tests. It excludes .git, build/native outputs,
development prefixes, reports, and private QA files.

The final isolated package provenance was:

```
Extracted source:
    /tmp/svt19-package-qa.jLaRI2/source

Package prefix:
    /tmp/svt19-package-qa.jLaRI2/packages

Architecture prefix:
    /tmp/svt19-package-qa.jLaRI2/arch

Package database:
    /tmp/svt19-package-qa.jLaRI2/packages/octave_packages

Public constructor:
    /tmp/svt19-package-qa.jLaRI2/packages/mplapack-interop-0.5.0-dev/@mp/mp.m

Native module:
    /tmp/svt19-package-qa.jLaRI2/arch/mplapack-interop-0.5.0-dev/x86_64-pc-linux-gnu-api-v61/__mplapack_core__.oct
```

The isolated package smoke passed 120/120 rows, 40 references, 34 V jobs,
20 records, and 80 replay snapshots. The isolated package demo passed
184/184 rows, 46 references, 41 V jobs, 23 records, and 92 replay snapshots.
All verification gates and accuracy targets were PASS.

The lifecycle passed initial install/load, real and complex smoke, help for
mp and mp_svd_tiers, examples 14--16, unload, uninstall, reinstall from the
archive, and a fresh-process second smoke. The fresh process proved the
public and native modules resolved from the isolated prefixes.

## Actual source changes

Before this master report was added, Git reported 107 changed paths, 9893
insertions, and 4 deletions relative to the historical SVT starting commit.
The SVT changes are confined to:

```
SVD-tier controller and private constructors/verifiers:
    examples/svd_tiers/

Allocated runnable examples:
    examples/14_svd_tier_s.m
    examples/15_svd_tier_a.m
    examples/16_svd_verified.m

Regression integration:
    test/run_tests.m
    test/test_svd_tiers.m
    test/test_svd_verification.m

Manual/documentation:
    doc/mplapack-interop.texi
    docs/mplapack-interop.md
    docs/svd-tiers.md
    docs/svd-verification.md
    docs/codex/SVT-LUNA-XHIGH.md
    docs/codex/svt/
    README.md
    README-SVT.md

Milestone evidence:
    svt00-report.md through svt19-report.md

QA tooling used or adjusted:
    tools/check-tree.sh
    tools/test-doc-examples.sh
    tools/build-package.sh
    tools/verify-release-candidate.sh
```

The exact machine-readable inventory remains available from:

```
git diff --name-status 760ec415a6f2b634f5cb80ee53758925cd32b83d..HEAD
```

No source archive, native output, temporary prefix, credentials, or
multi-gigabyte measurement artifact is part of that inventory.

## Source attribution and limitations

The suite uses literature-motivated NRO, Jacobi--Stirling, Lah, DD, Pascal,
Vandermonde, Lauchli, Hadamard, bidiagonal, and companion-like constructions.
Dimensions, phases, dyadic scales, controls, targets, serialization, and
replay format are suite adaptations. The reports do not claim to reproduce a
paper's complete structured HRA algorithm or to provide a generic HRA
guarantee.

The following were intentionally not run:

```
SVT stress profile:                         NOT RUN (opt-in)
Alternative OS/architecture package QA:     NOT RUN
Graphics-enabled SVT profile:               NOT RUN; plot=false was required
PDF manual generation:                      NOT RUN; TeX unavailable
MPLAPACK rebuild or source modification:    NOT RUN by user instruction
Push, merge, release tag, or publication:   NOT RUN by SVT scope
Debian/binary/PPA/registry work:            NOT RUN
Large artifact commit:                      NOT PERFORMED
```

The demo required several hours and high temporary RSS, but completed in the
isolated package environment. The earlier output-directory refusal, timeout
termination, shell quoting, constructor-form, variable-shadowing, and
pre-path help lookup were harness-only issues; corrected runs produced the
recorded PASS results and no source changes.

## Final gate summary

```
SVT00: PASS
SVT01: PASS
SVT02: PASS
SVT03: PASS
SVT04: PASS
SVT05: PASS
SVT06: PASS
SVT07: PASS
SVT08: PASS
SVT09: PASS
SVT10: PASS
SVT11: PASS
SVT12: PASS
SVT13: PASS
SVT14: PASS
SVT15: PASS
SVT16: PASS
SVT17: PASS
SVT18: PASS
SVT19: PASS

SVT00-SVT19: PASS
SVT-API-CLOSED
SVT-PACKAGE-QA-CLOSED
```

No next milestone is started automatically. D00/D01 and all release,
distribution, PPA, and registry work remain outside this goal.
