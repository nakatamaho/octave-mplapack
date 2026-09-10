# SVT19 report

## Result

SVT19: PASS. The mplapack-interop-0.5.0-dev source package was generated
reproducibly, installed from an extracted archive into isolated Octave
prefixes, exercised with the complete SVT smoke and demo profiles, and
cycled through the package lifecycle.

No MPLAPACK rebuild, MPLAPACK source change, dependency change, release tag,
push, merge, publication, or PPA operation was performed. The multi-GB
Octave RSS during the demo was temporary execution memory. No memory image,
measurement bundle, build output, or other large artifact is in Git.

## Validated state

```
Branch:
    topic/svd-tier-sav-examples

Starting commit for SVT19:
    bb6badb74cf20dc988f382b537d2e37c092555aa

Octave:
    GNU Octave 11.1.0

Dependency environment:
    /home/docker/opt/octave-mplapack-stack
    MPLAPACK 3.0.1 release-candidate interface

Environment:
    PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig
    LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib
    CPATH=/home/docker/opt/octave-mplapack-stack/include
```

SVT19 made no source implementation changes. This report is the only
planned repository change for the milestone.

## Source package reproducibility

Two runs of SOURCE_DATE_EPOCH=0 tools/build-package.sh produced:

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

tools/verify-release-candidate.sh HEAD rebuilt the package twice from
independent git archive extractions of commit
bb6badb74cf20dc988f382b537d2e37c092555aa and reported the same SHA256 and
size. The archive has one top-level directory and contains no .git, native
outputs, development prefixes, SVT reports, or private QA files. It contains
the manual source and derived documentation, SVT documentation, examples
14--16, and the two SVT regression tests.

## Isolated package provenance

The archive was extracted and installed using:

```
Extracted source:
    /tmp/svt19-package-qa.jLaRI2/source

Octave package prefix:
    /tmp/svt19-package-qa.jLaRI2/packages

Octave architecture prefix:
    /tmp/svt19-package-qa.jLaRI2/arch

Package database:
    /tmp/svt19-package-qa.jLaRI2/packages/octave_packages
```

A fresh Octave process resolved the installed files as:

```
Public mp constructor:
    /tmp/svt19-package-qa.jLaRI2/packages/mplapack-interop-0.5.0-dev/@mp/mp.m

Native module:
    /tmp/svt19-package-qa.jLaRI2/arch/mplapack-interop-0.5.0-dev/x86_64-pc-linux-gnu-api-v61/__mplapack_core__.oct
```

Only examples/svd_tiers and its private directory from the extracted source
archive were added for the SVT profile and examples. No worktree inst/src,
old package prefix, or developer checkout path was used.

## Isolated smoke profile

The extracted-archive package invocation used the isolated package database
and prefixes, loaded mplapack-interop, added only the extracted SVT helper
paths, and ran mp_svd_tiers("smoke", tier="all", plot=false) followed by
svt_replay_snapshots.

```
SVT19 ISOLATED SMOKE PASS
    measured SVD rows: 120/120
    references: 40
    V jobs: 34
    records: 20
    replay snapshots: 80
    verification gates: PASS
    accuracy targets: PASS
```

The smoke artifact was kept outside Git. Selected hashes:

```
certificates.json:       8d155de3b1f835d04a560f9f4752f11c5de84658b98c4efd1309d1295b3b799a
inputs-and-factors.json: b88d3819098bd8381d7cd16af1349408d58d9c1ea089a16b4523d801f8109e38
report.md:               72e0149a11821aeaed8de525717c8bf531e06d2355ea1f18c44edac7c285d240
summary.json:            24a68c98e59100258faa4505b15117e9533adfcf6e67303fa6a00152c85a7bc0
verification.tsv:        a04c71a1996c28d4c623826896d5a85223fc83116085d7da01998b57a12af02a
```

## Isolated demo profile

The first demo attempt was rejected before computation because its output
directory had been pre-created. A later attempt was stopped by an explicit
30-minute timeout while still computing. Neither was a product failure. The
final attempt used a fresh output directory and a four-hour timeout.

```
SVT19 ISOLATED DEMO PASS
    measured SVD rows: 184/184
    references: 46
    V jobs: 41
    records: 23
    replay snapshots: 92
    verification gates: PASS
    accuracy targets: PASS
    plot: false; no plots generated
```

The final demo artifact was kept at
/tmp/svt19-package-qa.jLaRI2/demo-artifacts-long and was not committed.
Selected hashes:

```
certificates.json:       35a5189185056f9775b9116cd2f3154a338323232608dc468bd55622e454eb02
environment.txt:         929687726dbcd41dc12f3fa4b428d84ea59f04f9af1618b2cb0ed1ed055e7350
inputs-and-factors.json: 8bafcb7e331f014246071dbdbba6633e1fabaf57bed26091509060c513f811e4
report.md:               6d874f6dc2179784f0a97395054ad6b897b345b654712dad894f99b7668e45b2
summary.json:            d56bbdd4e6f04be6bae158c9b226ebfbffa595a010696798d5055a5b1ca5ae1f
verification.tsv:        917deba8ea68f2399edf1350895cf1f222ec60f1416a6f73dd014fbaedea5fb8
```

The artifact report records status PASS, exact V4 MPFR/MPC snapshots, and
the expected negative V3 classifications INCONCLUSIVE and
UNSUPPORTED_RECTANGULAR with gate value 1.

## Package lifecycle

The following checks passed using the generated source archive and isolated
prefixes:

```
initial install/load:       PASS
real smoke:                 PASS
complex smoke:              PASS
help mp:                    PASS
help mp_svd_tiers:          PASS (extracted helper path)
examples 14--16:            PASS (extracted archive)
pkg unload:                 PASS
pkg uninstall -nodeps:      PASS; public and arch directories removed
pkg reinstall from archive:  PASS
fresh-process second smoke: PASS
```

The second smoke passed real mldivide, complex svd, and MP reconstruction
assertions. The same-process reinstall emitted Octave's non-fatal native
module reload warning because old references were still present; the fresh
process then resolved the reinstalled native module from the isolated arch
prefix and passed independently. Expected compatibility function-shadow
warnings were non-fatal.

## Previous gates carried into SVT19

```
examples 01--16 documentation wall: PASS
test/test_svd_tiers.m:                PASS
test/test_svd_verification.m:        PASS
tools/check-tree.sh:                 PASS
tools/check-format.sh:               PASS
tools/check-docs.sh:                 PASS
tools/build-docs.sh:                 PASS
tools/build-manual-markdown.sh:      PASS
tools/test-doc-examples.sh:          PASS
test/run_tests.m including M/C/N,
  C11L, NEIG, T00--T14, N07/N08,
  S00--S08, and SVT18 integration:   PASS
```

Documentation generation produced HTML, Info/plaintext, Markdown, and
Doxygen output. PDF generation was not possible because no working TeX
toolchain was installed; the documented fallback passed.

## Harness-only retries

The following early invocations were corrected without source or package
changes: shell quoting around A-backslash-b, an unsupported complex
cell-string constructor, an Octave variable named source shadowing source(),
and a help lookup before adding the extracted helper path. The corrected
commands produced all PASS results above. These were command-construction
issues, not product failures.

## Not run / limitations

```
Optional SVT stress profile:             NOT RUN (opt-in)
Alternative OS/architecture package QA:  NOT RUN
Graphics-enabled SVT profile:            NOT RUN; required profile used plot=false
PDF manual generation:                   NOT RUN; TeX engine unavailable
Release/publish/tag/merge/push actions:  NOT RUN by SVT scope
MPLAPACK rebuild or source modification: NOT RUN by user instruction
Large measurement artifacts in Git:      NOT RUN; intentionally excluded
```

## Gate

```
SVT19: PASS
source package reproducibility: PASS
isolated extracted-package provenance: PASS
isolated smoke: PASS
isolated demo: PASS
package lifecycle: PASS
fresh-process reinstall smoke: PASS
SVT18 documentation/regression wall: PASS
large artifact commit: NOT PERFORMED
```

SVT00--SVT19 master evidence report is the remaining repository document.
No push or release action is authorized by the SVT goal.
