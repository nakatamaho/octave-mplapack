# D04R1 — 0.5.1 MPC/pkg-config compatibility release report

## Outcome

`mplapack-interop 0.5.1` is merged into `main` and published as the GitHub
Release for annotated tag `v0.5.1`. The immutable `v0.5.0` tag and archive
were not modified. The release archive was uploaded and downloaded back from
GitHub for a byte-for-byte comparison. Debian/PPA work remains separate.

The release fixes the Ubuntu 26.04 `mpc.pc` dependency failure, normalizes
installed MPLAPACK `.pc` metadata without inventing an `mpc.pc`, and routes
complex `log2` through gmpfrxx `mpfrxx::log2` rather than a direct `mpc_log2`
symbol. `NEWS.md` and the GitHub release notes summarize these changes. No
upstream MPLAPACK or gmpfrxx source was changed.

## Release artifact

```text
Version:       mplapack-interop 0.5.1
Main commit:   95fb40f8732e45882d6878d62c7c9a8417006491
Annotated tag: v0.5.1
Tag object:    b0101c047e3143edb47bcbcc50573279e48f1e5b
GitHub Release: https://github.com/nakatamaho/octave-mplapack/releases/tag/v0.5.1
Asset:         mplapack-interop-0.5.1.tar.gz
SHA256:        50622b177d9e320ad8c02d4c15aae037a0643c27300a5ead529f4e829ad8d080
Size:          819039 bytes
```

`tools/verify-release-candidate.sh` built two clean archives from the main
release commit. Their file lists and hashes matched. The uploaded release asset
was downloaded from GitHub and compared byte-for-byte with the verified local
archive. The archive has one top-level directory and excludes repository-only
handoff metadata and the local installer helper.

## QA evidence

- `gmpfrxx_mkII 1.5.0` CTest: **190/190 PASS**.
- A clean isolated installer run built the gmpfrxx/MPLAPACK stack, found
  `mplapack_mpfr` and `mplapack_mpfr_precision.h`, passed the dependency
  precision probe, installed and loaded the Octave package, and passed real
  and complex smoke checks. The installed module had no unresolved
  `mpc_log2` symbol. Installer log: `/tmp/d04r1-final-installer.log`.
- The GNU Parallel documentation/example/help run completed **92/92 PASS**
  with `--jobs 32` in **737 seconds (12 minutes 17 seconds)**. Individual
  task results and timing notes are in
  `reports/D04R1-doc-examples-parallel-run.md`.
- `tools/check-format.sh`, `tools/check-tree.sh`, and
  `tools/check-github-math.sh`: **PASS**.
- `tools/check-docs.sh`: **PASS** with the isolated installed stack in
  `PKG_CONFIG_PATH`; it also rebuilt and passed the MPLAPACK MPFR dependency
  probe and deterministic documentation matrix checks. The initial invocation
  without that environment failed because `mplapack_mpfr` was not discoverable.
- `tools/build-manual-markdown.sh`, shell syntax checks, `git diff --check`,
  source archive reproducibility, and release-asset download comparison:
  **PASS**.
- The final remote `main`, topic branch, and `v0.5.1` tag point to release
  commit `95fb40f8732e45882d6878d62c7c9a8417006491`.

The clean installer and 92-task wall used the 0.5.1 candidate snapshot before
final publication-documentation edits. The native numerical source was
unchanged in those edits; the final release archive was independently rebuilt
from the merged commit and verified against the uploaded asset.

## Scope and follow-up

The GitHub source release is complete. Debian packaging, Launchpad/PPA upload,
and Octave registry submission remain deferred. The full `tools/local-ci.sh`
regression/sanitizer wall was not run for this milestone. GNU Parallel's native
`--joblog` was omitted during the 92-task run; individual logs, task statuses,
and timings were retained as documented in the run report.

This handoff report is committed after the release tag; the tag continues to
point to the source-release commit above.

Branch: `main`
Starting commit: `18454dda239f76061cafc37b47856db58267c0ea`
Final commit: `95fb40f8732e45882d6878d62c7c9a8417006491` (target of `v0.5.1`)
Files changed: `D04R1-report.md`, `DESCRIPTION`, `NEWS.md`, `README.md`, `doc/mplapack-interop.texi`, `docs/backend-map.md`, `docs/complex-api.md`, `docs/complex-backends.md`, `docs/complex-compatibility.md`, `docs/dependency-release-stack-r2.md`, `docs/doxygen/Doxyfile`, `docs/goals/D04R1-mpc-compat.md`, `docs/mplapack-interop.md`, `examples/18_complex_log2.m`, `inst/@mp/log2.m`, `reports/D04R1-doc-examples-parallel-run.md`, `src/Makefile`, `src/mp_script_compat.cc`, `test/m22_dependency_probe.cc`, `tools/build-package.sh`, `tools/install-local-octave-mplapack.sh`, `tools/local-ci.sh`, `tools/test-doc-examples.sh`.
Commands run: `git fetch origin`; `tools/build-manual-markdown.sh`; `SOURCE_DATE_EPOCH=0 tools/build-package.sh`; `tools/verify-release-candidate.sh 95fb40f8732e45882d6878d62c7c9a8417006491`; `tools/check-format.sh`; `tools/check-tree.sh`; `tools/check-github-math.sh`; `PKG_CONFIG_PATH=/tmp/d04r1-final-prefix/lib/pkgconfig:/tmp/d04r1-final-prefix/lib64/pkgconfig tools/check-docs.sh`; shell syntax checks and `git diff --check`; `git checkout main`; `git merge --ff-only topic/d04r1-mpc-compat`; annotated tag refresh; `git push origin main topic/d04r1-mpc-compat +refs/tags/v0.5.1:refs/tags/v0.5.1`; `gh release create v0.5.1 ...`; `gh release view`; `gh release download` and `cmp`.
Tests: Release archive reproducibility PASS (two clean builds); gmpfrxx CTest 190/190 PASS; clean installer/dependency/real-complex smoke PASS; no unresolved `mpc_log2`; documentation/example/help wall 92/92 PASS in 737 seconds; format/tree/GitHub-math/docs checks PASS; uploaded asset matches local archive byte-for-byte.
Gate: **PASS — merged to `main`; annotated `v0.5.1` GitHub Release and source asset published and verified.**
Known limitations: Debian/PPA/registry uploads were not performed; full `tools/local-ci.sh` regression/sanitizer wall was not run; the GNU Parallel native joblog was omitted (per-task evidence is retained).
