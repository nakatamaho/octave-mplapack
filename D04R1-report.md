# D04R1 — 0.5.1 MPC/pkg-config compatibility release report

## Outcome

The local `mplapack-interop 0.5.1` release commit and annotated tag are
complete. Tag `v0.5.1` points to the release commit listed below. The
reproducible source archive is available locally at
`dist/mplapack-interop-0.5.1.tar.gz`; GitHub/PPA uploads were intentionally not
performed. The immutable `v0.5.0` tag and archive were not changed.

The release changes address the Ubuntu 26.04 `mpc.pc` dependency failure,
make the installed MPLAPACK `.pc` metadata consumable without inventing an
`mpc.pc`, and route complex `log2` through gmpfrxx `mpfrxx::log2` rather than a
direct `mpc_log2` symbol. No upstream MPLAPACK or gmpfrxx source was changed.

## Release artifact

```text
Version:       mplapack-interop 0.5.1
Commit:        a85b4616e195cd250c813fd87cc7d50e0c303c60
Annotated tag: v0.5.1
Tag object:    56147fd941e9253084e2cea942af287d13121c6e
Archive:       dist/mplapack-interop-0.5.1.tar.gz
SHA256:        6079487fff60b3480eb567d5fdcc5afb7133f3489a0ebef1090cbbdc2a86346f
Size:          819207 bytes
```

`tools/verify-release-candidate.sh` built two clean archives from the release
commit. Their file lists and hashes matched the local artifact. The archive
contains one top-level directory and excludes repository-only handoff
metadata and the local installer helper.

## QA evidence

- `gmpfrxx_mkII 1.5.0` CTest: **190/190 PASS**.
- A clean isolated installer run built the gmpfrxx/MPLAPACK stack, found
  `mplapack_mpfr` and `mplapack_mpfr_precision.h`, passed the dependency
  precision probe, installed and loaded the Octave package, and passed real
  and complex smoke checks. The installed module had no unresolved
  `mpc_log2` symbol. Installer log: `/tmp/d04r1-final-installer.log`.
- The GNU Parallel documentation/example/help run completed **92/92 PASS**
  with `--jobs 32` in **737 seconds (12 minutes 17 seconds)**. The individual
  task results and timing notes are in
  `reports/D04R1-doc-examples-parallel-run.md`.
- `tools/check-format.sh`, `tools/check-tree.sh`, and
  `tools/check-github-math.sh`: **PASS**.
- `tools/check-docs.sh`: **PASS** when run with the isolated installed stack
  in `PKG_CONFIG_PATH`; this also rebuilt and passed the MPLAPACK MPFR
  dependency probe and the deterministic documentation matrix checks. The
  initial invocation without that environment correctly failed because
  `mplapack_mpfr` was not discoverable.
- `tools/build-manual-markdown.sh`, shell syntax checks,
  `git diff --check`, and archive inspection: **PASS**.
- Remote `origin` has no `v0.5.1` tag; no push or GitHub Release was created.

The clean installer and the 92-task wall used the 0.5.1 candidate snapshot
before final release-documentation-only edits. The final source archive was
subsequently rebuilt and independently verified from the release commit.

## Scope and follow-up

This is a local commit/tag release only. Debian packaging, Launchpad/PPA,
GitHub publication, and Octave registry submission remain deferred. The full
`tools/local-ci.sh` regression/sanitizer wall was not run for this milestone.
GNU Parallel's native `--joblog` was omitted during the 92-task run; individual
logs, task statuses, and timings were retained as documented in the run
report.

The handoff report is committed separately after the release tag; the tag
continues to point to the source-release commit above.

Branch: `topic/d04r1-mpc-compat`
Starting commit: `18454dda239f76061cafc37b47856db58267c0ea`
Final commit: `a85b4616e195cd250c813fd87cc7d50e0c303c60` (target of `v0.5.1`)
Files changed: `DESCRIPTION`, `NEWS.md`, `README.md`, `doc/mplapack-interop.texi`, `docs/backend-map.md`, `docs/complex-api.md`, `docs/complex-backends.md`, `docs/complex-compatibility.md`, `docs/dependency-release-stack-r2.md`, `docs/doxygen/Doxyfile`, `docs/goals/D04R1-mpc-compat.md`, `docs/mplapack-interop.md`, `examples/18_complex_log2.m`, `inst/@mp/log2.m`, `reports/D04R1-doc-examples-parallel-run.md`, `src/Makefile`, `src/mp_script_compat.cc`, `test/m22_dependency_probe.cc`, `tools/build-package.sh`, `tools/install-local-octave-mplapack.sh`, `tools/local-ci.sh`, `tools/test-doc-examples.sh`, and `D04R1-report.md` (follow-up handoff commit; release tag unchanged).
Commands run: `tools/build-manual-markdown.sh`; `SOURCE_DATE_EPOCH=0 tools/build-package.sh`; `tools/verify-release-candidate.sh a85b4616e195cd250c813fd87cc7d50e0c303c60`; `tools/check-format.sh`; `tools/check-tree.sh`; `tools/check-github-math.sh`; `PKG_CONFIG_PATH=/tmp/d04r1-final-prefix/lib/pkgconfig:/tmp/d04r1-final-prefix/lib64/pkgconfig tools/check-docs.sh`; `sh -n` and `bash -n tools/install-local-octave-mplapack.sh`; `git diff --check`; local annotated tag creation; remote tag check with `git ls-remote`.
Tests: Release archive reproducibility PASS (two clean builds; SHA256 above); gmpfrxx CTest 190/190 PASS; clean installer/dependency/real-complex smoke PASS; no unresolved `mpc_log2`; documentation/example/help wall 92/92 PASS in 737 seconds; format/tree/GitHub-math/docs checks PASS.
Gate: **PASS — D04R1 local 0.5.1 commit, reproducible archive, and annotated tag complete.** Public uploads were not in scope.
Known limitations: GitHub/PPA/Debian/registry uploads were not performed; full `tools/local-ci.sh` regression/sanitizer wall was not run; the GNU Parallel native joblog was omitted (per-task evidence is retained).
