# NEIG08 report

Task and milestone: NEIG — difficult nonsymmetric eigensystems; documentation, runnable example, package extraction, and final regression closure.

Branch: `main`

Starting commit: `c80584793817ddcbb0afe1580d79f55b3da6d0a2`

Final commit: see the Git commit containing this report; the exact SHA is recorded by the final handoff.

## Scope

NEIG08 closes the documentation and clean-package boundary without adding a
package-level numerical API, a new backend, or a new dependency. The difficult
eigensystem harness remains an example/QA surface built from the existing
public `mp`, `mpbits`, `eig`, `norm`, and MP inspection interfaces.

Implemented files and documentation surfaces:

- `examples/13_nonsymmetric_eig_suite.m`
- `examples/nonsymmetric_eig/` documentation/output helpers and private constructors/runners
- `docs/nonsymmetric-eig-suite.md`
- `doc/mplapack-interop.texi`
- regenerated `docs/mplapack-interop.md`
- `docs/doxygen/mainpage.dox`
- `docs/doxygen/native-contracts.dox`
- `docs/public-api-inventory.md`
- `docs/backend-map.md`
- `docs/advanced-numerics-compatibility.md`
- `docs/octave-script-compatibility.md`
- `README.md`
- `tools/run-nonsymmetric-eig-suite.sh`
- `tools/test-doc-examples.sh`
- `test/test_nonsymmetric_eig_suite.m`
- `test/run_tests.m`
- `neig08-report.md`

No `inst/` public API, native backend, dependency, or precision-storage
implementation was changed by NEIG08.

## Documentation closure

The Texinfo user manual now documents the five representations, both balance
modes, the left-vector identity `W'*A = D*W'`, actual-output reevaluation,
deterministic bottleneck matching, MP precision/default restoration, native
input controls, output files, and the explicit display-only plot conversion.
The Markdown manual was regenerated from Texinfo using the existing
DocBook/Pandoc pipeline. Doxygen mainpage and native contract notes record the
algorithm, ownership, precision, and left-eigenvector conventions. The API
inventory explicitly records that this is an example/QA harness and adds no
package-level row; the compatibility and backend maps link its coverage.

The runnable documentation path includes `examples/13_nonsymmetric_eig_suite.m`.
It runs the five-family smoke profile and asserts exactly 30 rows. The focused
test and `test/run_tests.m` also execute the 40-row demo wall.

## Environment and commands

- GNU Octave 11.1.0 from `/usr/bin/octave`.
- Installed MPLAPACK 3.0.1 MPFR/MPC stack from `/home/docker/opt/octave-mplapack-stack`.
- `pkg-config`, `CPATH`, and `LD_LIBRARY_PATH` selected the installed stack.
- GNU Texinfo `makeinfo`/`texi2any`, Pandoc, and Doxygen 1.15.0 were used for the documentation gates.

Commands run:

- `tools/check-docs.sh`
- `tools/check-format.sh`
- `tools/check-tree.sh`
- `tools/build-manual-markdown.sh`
- `tools/build-docs.sh`
- `tools/test-doc-examples.sh`
- `tools/run-nonsymmetric-eig-suite.sh smoke`
- `tools/run-nonsymmetric-eig-suite.sh demo`
- `tools/dev-octave.sh --eval 'run ("test/run_tests.m");'`

## Clean source-package QA

`SOURCE_DATE_EPOCH=0 tools/build-package.sh` produced a source package that
contained the new documentation and example files. The archive was extracted
to an independent temporary tree and installed into an isolated Octave package
prefix, with only the installed MPLAPACK stack on the dependency include and
library paths.

The clean extracted-package lifecycle passed:

```text
install -> pkg load -> real smoke -> complex smoke -> help lookups
-> extracted runnable example -> pkg unload -> uninstall
-> reinstall -> second real/complex smoke
```

The verbose build log was checked for dependency paths. No `-I/tmp/t00-t14`
or `-L/tmp/t00-t14` source-worktree path occurred; the MPLAPACK include path
was `/home/docker/opt/octave-mplapack-stack/include/mplapack`. The first
attempt exposed only a QA-command type mistake (`mplapack_version()` returns a
metadata struct in this environment, not a string); the corrected lifecycle
run passed. A harmless Octave warning reported that a reinstalled `.oct`
library was not reloaded while the same process still held references; the
second smoke passed and the lifecycle was accepted.

## Numerical and regression results

- NEIG self-test: PASS, including exact constructors, independent references,
  matching, left/right residual conventions, 1024-bit `2^-700`, 2048-bit
  `2^-1500`, ambient restoration, and Forsythe `2^-1600` construction.
- all-family smoke: PASS, exactly 30 rows.
- all-family demo: PASS, exactly 40 rows.
- both `balance` and `nobalance`: PASS for every family and precision row.
- result writer: PASS for `summary.tsv`, `eigenvalues.tsv`,
  `environment.txt`, and `report.md`; existing-file overwrite refusal PASS.
- optional plot: PASS; `spectrum.png` generated. Its `double` conversion is
  explicitly presentation-only and is absent from solver/metric paths.
- documentation example wall: PASS for examples 01 through 13 and selected
  help lookups.
- full `test/run_tests.m`: PASS for M01–M23, C01–C12 including mandatory
  C11L, N00–N08, T00–T14, S00–S08, and the NEIG suite.
- native MPFR/MPC dependency probe: PASS during every source and package
  build.

## Gate

NEIG08 gate: **PASS**

## Milestone table

| Milestone | Result | Evidence |
|---|---|---|
| NEIG00 | PASS | API/backend audit and focused existing eig regressions |
| NEIG01 | PASS | exact Hadamard construction and precision canaries |
| NEIG02 | PASS | MP bottleneck matching and actual-output metrics |
| NEIG03 | PASS | Hadamard smoke/demo, balance modes, condition evidence |
| NEIG04 | PASS | Frank construction and independent structured reference |
| NEIG05 | PASS | exact companion coefficients and native-rounding control |
| NEIG06 | PASS | original/scaled Forsythe and 2048-bit underflow boundary |
| NEIG07 | PASS | all-family 30/40 rows, output bundle, optional plot |
| NEIG08 | PASS | manual, Markdown, Doxygen, examples, clean package, full regression |

## Known limitations

- The optional PNG is visualization only and is not numerical evidence.
- Native rows are explicit binary64 input controls; they do not validate or
  replace MP rows.
- Reference paths use package MP arithmetic/backend in structured independent
  constructions; they are not an external-library oracle.
- The stress profile is available for local runs but is not part of the fixed
  30-row smoke / 40-row demo acceptance wall.
- Existing Octave functions such as `fminsearch`, `fsolve`, and `spline` may
  emit core-function shadowing warnings when the package is loaded. This is
  existing package compatibility behavior, not a new NEIG numerical path.

Branch: `main`
Starting commit: `c80584793817ddcbb0afe1580d79f55b3da6d0a2`
Final commit: see the Git commit containing this NEIG08 report
Files changed: NEIG08 implementation, docs, runnable example, test integration, and report listed above
Commands run: documentation, all-family smoke/demo, clean package lifecycle, and full `test/run_tests.m` commands above
Tests: all listed gates PASS
Gate: PASS
Known limitations: listed above
