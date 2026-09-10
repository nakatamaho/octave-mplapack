# SVT18 report

## Result

SVT18: PASS. Three allocated top-level examples, detailed SVD-tier and
verification documentation, generated manual output, and regression-runner
integration are complete. Existing SVD and NEIG coverage remains in place.

## Validated source state

```text
Branch:
    topic/svd-tier-sav-examples

Starting commit:
    4f73726d10ae020d3ec70213009051fc335437fe

Implementation commit:
    36c8687c708eec132d59594dc6b98d752c62a47d

Octave:
    GNU Octave 11.1.0

Dependency environment:
    /home/docker/opt/octave-mplapack-stack
    MPLAPACK MPFR 3.0.1 release-candidate interface
```

The implementation commit contains:

```text
README.md
doc/mplapack-interop.texi
docs/codex/svt/SOURCES.md
docs/mplapack-interop.md
docs/svd-tiers.md
docs/svd-verification.md
examples/14_svd_tier_s.m
examples/15_svd_tier_a.m
examples/16_svd_verified.m
examples/svd_tiers/mp_svd_tiers_selftest.m
test/run_tests.m
test/test_svd_tiers.m
test/test_svd_verification.m
tools/check-tree.sh
tools/test-doc-examples.sh
```

No public `mp` method, native driver, backend, dependency, installed header,
rounding API, or binary64 numerical fallback was added. The SVT verification
methods remain example-local and retain `paper_algorithm_reproduction=false`.

## Top-level examples

All three small defaults were executed directly from the source tree with
absolute `inst` and `src` paths:

```text
examples/14_svd_tier_s.m:
    Tier S NRO SVD PASS, 4x4, 256 bits
    reconstruction residual 5.342764800888113...e-77

examples/15_svd_tier_a.m:
    Tier A Vandermonde SVD PASS, 3x4, 256 bits
    reconstruction residual 5.177068007856728...e-77

examples/16_svd_verified.m:
    Tier V SVD/inverse certificates PASS, 256 bits
    V1 svt_polar_weyl_v1 CERTIFIED
    V3 svt_neumann_inverse_v1 CERTIFIED
```

The examples use exact decimal/dyadic MP inputs, keep residuals as `mp`, and
convert no mathematical evidence to binary64. Each points to the complete
`mp_svd_tiers("demo", ...)` profile for full output.

## Tests and documentation gates

The documented dependency environment was explicitly set for the source-tree
commands:

```sh
export PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib:$LD_LIBRARY_PATH
export CPATH=/home/docker/opt/octave-mplapack-stack/include:$CPATH
```

The following checks passed:

```text
tools/check-tree.sh
tools/check-format.sh
tools/build-manual-markdown.sh
tools/build-docs.sh
tools/check-docs.sh
tools/test-doc-examples.sh
```

`tools/build-docs.sh` generated user HTML, Info/plaintext, Markdown, and
Doxygen HTML. It reported that a working TeX engine was unavailable, so a PDF
was not generated; this is the existing documented fallback and did not affect
the user-manual or developer-documentation gate.

`tools/test-doc-examples.sh` executed examples 01 through 16, including the
existing Hilbert and difficult nonsymmetric-eigenproblem examples and the
three new SVT examples. The selected help wall also passed for the public SVD,
eigen, factorization, and serialization entry points. Expected Octave
optimization shadow and gnuplot toolkit warnings were non-fatal.

Focused integration commands passed:

```sh
octave --no-gui --quiet --no-init-file \
  --path /tmp/t00-t14/inst --path /tmp/t00-t14/src \
  --eval "run('/tmp/t00-t14/test/test_svd_tiers.m');"
```

Observed: `PASS: test_svd_tiers (SVT18 Tier S/A and SVD integration)`.
This test covers the facade contract, exact common constructors, and a small
measured SVD contract without relaunching the multi-minute full profile wall.

```sh
octave --no-gui --quiet --no-init-file \
  --path /tmp/t00-t14/inst --path /tmp/t00-t14/src \
  --eval "run('/tmp/t00-t14/test/test_svd_verification.m');"
```

Observed: `PASS: test_svd_verification (SVT18 V0/V1/V2/V3 integration)`.
The V wall includes arithmetic-contract preconditions, malformed-input and
phase controls, repeated-factor handling, cluster projectors, and inverse
negative controls.

The existing full runner was then executed with the same dependency environment:

```sh
tools/dev-octave.sh --eval \
  "run('test/run_tests.m'); fprintf('SVT18 EXISTING RUNNER PASS\\n');"
```

It passed all existing M/C/N, mandatory C11L, NEIG, T00--T14, N07/N08, and
S00--S08 tests, followed by the SVT18 Tier S/A and V integration tests. The
first attempt without the dependency environment failed only at the expected
installed precision-header preflight; the documented environment retry
passed.

## Documentation and attribution

The authoritative manual source is `doc/mplapack-interop.texi`; its generated
Markdown output is `docs/mplapack-interop.md`, regenerated with local
`texi2any`/DocBook and Pandoc tooling. New standalone explanations are in:

```text
docs/svd-tiers.md
docs/svd-verification.md
docs/codex/svt/SOURCES.md
```

The docs distinguish literature motivation from suite adaptations: dimensions,
dyadic scales, complex phases, acceptance targets, and replay representation
are original suite choices. V1/V2/V3 are conservative point-matrix baselines,
not complete Rump--Lange, Rump--Ogita, or Rump algorithm ports. No new public
API documentation or backend map entry was needed because no installed API
was added.

One stale SVT01 selftest assumption was found during runner integration: it
expected the facade to return an `INCOMPLETE` skeleton without executing a
profile. The current facade correctly executes the selected profile. The
selftest was repaired to validate manifest counts and output-directory safety
without relaunching the full measurement wall; the corrected focused test
passed.

## Artifact and repository safety

No SVT17 measurement bundle was copied into the repository. The approximately
4.2 GB process RSS observed during the earlier demo was temporary execution
memory, not a repository artifact. No `/tmp/svt17-*` file, build output, or
large generated data was staged or committed.

No MPLAPACK rebuild, source modification, push, merge, tag, release, package
publication, or PPA operation was performed.

## Gate

```text
SVT18: PASS
focused S/A integration: PASS
focused V integration: PASS
top-level examples 14--16: PASS
documentation generation: PASS
documentation examples 01--16: PASS
existing regression runner: PASS
public API/backend boundary: PASS
```

## Known limitations and not run

The optional stress profile remains intentionally unrun. SVT19 isolated
source-package QA, final clean-package profile execution, and the final
SVT00--SVT19 master evidence report remain pending. PDF output was not
produced because the local TeX engine was unavailable; HTML, Info/plaintext,
Markdown, and Doxygen outputs passed.

No push or release action is authorized by the SVT goal.
