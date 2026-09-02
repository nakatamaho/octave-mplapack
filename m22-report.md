# M22 RESULT

Repository: nakatamaho/octave-mplapack
Remote: https://github.com/nakatamaho/octave-mplapack.git
Branch: topic/m22-real-release-closure
Starting commit: d9ec2fcf4b8071cdc6f7807fe91a6baf02f84eaa
Final commit: 5b7867e1545054969e3a3993e9f3f4be0aaffdbe (gate/report commit)
PR: pending push

## Baseline

- M21 accepted base: d9ec2fcf4b8071cdc6f7807fe91a6baf02f84eaa
- M20 release decision: REAL-PPA-GO
- MPLAPACK dependency: 1cf03d1a1aa2afecde5f1840fbe9663ecfc31e57 (installed 3.0.1)
- Fresh project default: 512 bits
- Tested Octave: 11.1.0

## v0.1 public API

### Construction / precision
- `mp(...)`: real scalar, real double matrix, and decimal text-cell matrix.
- `mpbits`, `mpdigits`: construction/default precision controls; existing values retain precision.

### Matrix inspection
- `size`, `rows`, `columns`, `numel`, `ndims`, `isempty`, `end`: supported structural queries.
- Indexing/assignment: supported dense two-dimensional in-bounds forms with documented vector-linear limits.
- `double`, `disp`, scalar `char`: supported; matrix `char` remains deferred.

### Arithmetic
- Unary signs and `+`, `-`, `.*`, `./`: direct MPFR.
- `*`: MPLAPACK `Rgemm`.
- `\`: `Rgesv` for square and `Rgelss` for rectangular minimum-norm least squares.

### Structural
- `.'`, `'`, `reshape`, `[A,B]`, `[A;B]`, and value-semantic assignment are supported.

### Factorizations
- `chol`: `Rpotrf`, selected-triangle dense semantics.
- `qr`: `Rgeqrf`/`Rorgqr`, `Rgeqp3`/`Rorgqr` pivoted forms.
- `lu`: `Rgetrf`, packed/two-output/P/vector forms for rectangular and singular matrices.

The complete inventory, feature matrix, public-to-native map, and error table
are in `docs/v0.1-api.md`.

## Unsupported v0.1 surface

- complex, sparse, and N-D values;
- matrix `char`, comparisons, logical operators, power, reductions, and general transcendentals;
- matrix growth/deletion/logical assignment and broad vector-linear indexing;
- `det`, `inv`, `rank`, `cond`, `norm`, `eig`, `svd`;
- `qr(A,B)`, QR/LU update families, sparse factorization forms, and automatic SPD solve optimization.

## API audit

- @mp methods enumerated: all 28 files in `inst/@mp` plus `mpbits`, `mpdigits`, and `mplapack_version`.
- Native operations mapped: public wrapper-to-private command/backend map is in `docs/v0.1-api.md`.
- Stale/dead API: no unexplained public method; `mrdivide` is an intentional legacy guard.
- Feature table: `docs/v0.1-api.md` and README.
- Limitations table: `docs/v0.1-api.md` and `docs/octave-compatibility.md`.

## Error semantics

- Error namespace: `mplapack:mp:<SpecificCondition>` for new public guards.
- Stable identifiers: input, dimension, indexing, assignment, option, output-count, non-square, and Cholesky guards are inventoried in `docs/v0.1-api.md`.
- Dimension/option/unsupported errors: clean deterministic failures.
- Factorization errors: audited M17/M18/M19/M21 status behavior unchanged.
- Silent double fallback found: no.
- Infinite recursion found: no.
- Crash found in compatibility firewall: no.
- Legacy exception: `mplapack:NotImplemented` remains for accepted `mrdivide` behavior.

## Help / docs

- `help mp`, `help mpbits`, `help mpdigits`: audited.
- `help @mp/mtimes`, `help @mp/mldivide`, `help @mp/chol`, `help @mp/qr`, `help @mp/lu`: audited with method Texinfo.
- Structural wrappers now have concise method help.
- README: release-quality quick start, feature status, dependency and PPA scope.
- v0.1 API doc: `docs/v0.1-api.md`.
- compatibility doc: `docs/octave-compatibility.md`.
- factorization docs: `docs/cholesky.md`, `docs/qr.md`, `docs/pivoted-qr.md`, `docs/lu.md` linked.
- examples: four executable real-only examples.

## Examples

- scalar precision: `examples/01_scalar_precision.m`.
- matrix arithmetic: `examples/02_matrix_arithmetic.m`.
- solve: `examples/03_linear_solve.m`.
- factorization: `examples/04_factorizations.m`.
- Installed-example smoke: passed in the isolated package lifecycle.

## Developer UX

- Dev entrypoint: executable `tools/dev-octave.sh`.
- Build behavior: verifies `pkg-config`, runs `check-dependency`, builds `src`, sets the queried library directory, and starts Octave with absolute repository paths.
- Dependency detection: `pkg-config`; no developer-specific path is committed.
- Absolute paths: none in production configuration.
- Result: one-command checkout workflow; release QA remains archive/install based.

## Version / metadata

- Provisional version: `0.1.0` target for M23; current `DESCRIPTION` version remains `0.1.0-dev`.
- Authoritative version source: `DESCRIPTION`.
- DESCRIPTION: complete and requires Octave >= 11.1.0.
- NEWS: provisional release section added.
- README status: consistent with real-only M22 closure and M23 pending.
- License: BSD-2-Clause; `LICENSE` and `COPYING` identical.
- Minimum Octave: 11.1.0 (tested).

## MPLAPACK dependency

- Required interface: `mplapack_mpfr_precision.h` and `MplapackMpfrPrecisionScope`.
- Feature probe: `test/m22_dependency_probe.cc`, built by `make -C src check-dependency`.
- Version-string dependency: not sufficient; header/compile/run probe is required.
- Required header: `mplapack_mpfr_precision.h`.
- pkg-config: `mplapack_mpfr` 3.0.1.
- Runtime library: `libmplapack_mpfr.so.3`.
- Source-tree leakage: none in committed package configuration.
- Incompatible dependency error: clear uniform-precision calling-contract diagnostic.

## Package archive

- Archive: deterministic `dist/mplapack-0.1.0-dev.tar.gz`.
- Clean checkout build: passed through `tools/local-ci.sh`.
- Contents audit: includes `inst/`, `src/`, `test/`, `docs/`, `examples/`, `tools/`, metadata, and license.
- Build artifacts excluded: yes, including `.build-m22`, `.oct`, object, `.libs`, `.deps`.
- Private files excluded: yes; root milestone reports are not package roots.
- Installed package: passed.
- Help installed: passed for QR/LU and public wrappers.
- Examples installed: passed.
- Uninstall: passed.
- Reinstall: passed.

## Compatibility firewall

- `eig`, `svd`, `det`, `inv`, `rank`, `norm`, `sin`, `exp`, `sqrt`, power, comparison, and right-division probes: all fail cleanly.
- Matrix unsupported-function fallback: no implicit `double`, crash, or recursion observed.
- Result: G22-FIREWALL evidence passes.

## PPA handoff

- Ubuntu target: 26.04.
- Octave target: 11.1.
- MPLAPACK package proposal: `libmplapack-mpfr3` / `libmplapack-mpfr-dev` (PPA policy proposal).
- `octave-mplapack` Build-Depends draft: debhelper-compat, octave-dev, pkg-config, MPLAPACK MPFR dev, MPFR/MPC/GMP, and C++ build tools.
- Runtime dependency draft: Octave, `libmplapack_mpfr.so.3`, MPC, MPFR, GMP.
- PPA1: MPLAPACK Debian source/runtime package.
- PPA2: octave-mplapack Debian package/autopkgtest.
- PPA3: Launchpad staging build.
- PPA4: public real-only PPA after M23.
- Complex blocks PPA: no; M20 is `REAL-PPA-GO` and complex symbols share the runtime library.
- Remaining PPA blockers: Debian policy/package names, Launchpad availability, multi-series/architecture QA.

## Release checklist

- File: `docs/release-checklist.md`.
- Complete: M22 preparation items complete; M23 execution items remain unchecked.
- M23-ready: yes.

## QA

- Clean build: passed.
- Clean package: passed.
- Installed smoke: passed, including unload/uninstall/reinstall.
- Full local CI: passed (`tools/local-ci.sh`).
- ASan: passed through native targets.
- UBSan: passed through native targets.
- LSan: passed through native targets.
- M20 complex probe: passed.
- M00-M21 regression: passed unchanged.
- `git diff --check`: passed.

## Gates

- G22-API: PASS
- G22-DOCS: PASS
- G22-ERRORS: PASS
- G22-PACKAGE: PASS
- G22-DEPENDENCY: PASS
- G22-DEV-UX: PASS
- G22-PPA-HANDOFF: PASS
- G22-METADATA: PASS
- G22-FIREWALL: PASS
- G22-REGRESSION: PASS

M22 PASS

Release conclusion: REAL-V0.1-API-CLOSED

## Code changes

Added the dependency feature probe, release-closure test/firewall, four
examples, developer entrypoint, API/compatibility/PPA/release documents,
method help, package/archive QA, and M22 report. No numerical backend or
MPLAPACK source was modified.

## Files changed

`.gitignore`, `INDEX`, `NEWS.md`, `README.md`, M22 docs, `examples/*`, selected
`inst/@mp` help blocks, `src/Makefile`, M22 tests/probe, and package QA tools.
Pre-existing unrelated legacy report deletions remain unstaged.

## Commits

- `bd2982b` M22: add MPLAPACK interface feature probe
- `49e7cac` M22: document and close the real v0.1 API
- `8e20303` M22: add release examples and package QA
- final report/status commit: `5b7867e` (metadata-only follow-up below)

## Push

- Push: pending
- Remote tip: pending
- Local tip: pending
- GitHub CI: pending push

## Known v0.1 limitations

Dense real only; complex, sparse, N-D, matrix `char`, growth/deletion and
logical assignment, broad vector-linear indexing, comparisons, reductions,
transcendentals, `det`, `inv`, `rank`, `cond`, `norm`, `eig`, `svd`, QR/LU
update families, `qr(A,B)`, sparse factorization forms, and automatic SPD
solve optimization remain unsupported. M22 creates no tag or PPA upload.

## Remaining blockers before M23

No real API blocker remains. M23 must perform the feature freeze/release-candidate
review, choose the final version metadata, and execute the checklist subset;
PPA1 follows only after M23.

## Recommended next action

Review and merge M22, then proceed to M23 v0.1 feature freeze / release-candidate
preparation. Do not begin PPA1 or complex C00 automatically.

Branch: topic/m22-real-release-closure
Starting commit: d9ec2fcf4b8071cdc6f7807fe91a6baf02f84eaa
Final commit: 5b7867e1545054969e3a3993e9f3f4be0aaffdbe (gate/report commit)
Files changed: see Files changed above; legacy report deletions are pre-existing and unstaged
Commands run: `tools/check-tree.sh`; `tools/check-format.sh`; `git diff --check`; `make -C src check-dependency`; `make -C src`; `octave test/run_tests.m`; examples smoke; `tools/build-package.sh`; `tools/local-ci.sh`
Tests: M00-M21 regression, M22 release closure, dependency probe, package lifecycle, examples, help, firewall, ASan/UBSan/LSan, M20 complex probe
Gate: G22-API/DOCS/ERRORS/PACKAGE/DEPENDENCY/DEV-UX/PPA-HANDOFF/METADATA/FIREWALL/REGRESSION all PASS
Known limitations: documented in `docs/v0.1-api.md`, `docs/octave-compatibility.md`, and above
