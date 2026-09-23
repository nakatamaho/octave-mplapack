# P01 result — Debian source package

## Result

The `octave-mplapack` Debian source package for upstream 0.5.1 was generated
with source format `3.0 (quilt)`. The quilt reproducibility patch applies on
source-package extraction. Two source-package generations produced byte-identical
`.dsc` and Debian tarball artifacts. Lintian reported no tags with
`--display-info --pedantic`.

The package metadata uses source and binary name `octave-mplapack`. The
`debhelper-compat` level is 13, matching the inspected `dh-octave` 1.14.1
package dependency. Build rules use `dh-octave`, and the autopkgtest smoke test
exercises the installed package and MPLAPACK-backed operations.

## Source-package evidence

- Upstream archive: `octave-mplapack_0.5.1.orig.tar.gz`
- Upstream archive SHA256: `50622b177d9e320ad8c02d4c15aae037a0643c27300a5ead529f4e829ad8d080`
- Source package: `octave-mplapack_0.5.1-1.dsc`
- `.dsc` SHA256: `8138b648381dcbd98519f5179a094a3930f457a9bd5c05e7fe16dc13f3762e06`
- Debian tarball SHA256: `9af7577b0d600603afc1d956e8138dc0b5158f2042f83e0ab26ba3641e75dd0d`
- Repeated generation: both hashes matched byte-for-byte.
- Round-trip extraction: PASS; `reproducible-mkoctfile-debug-paths.patch` applied.

## Validation

- `dpkg-source -b .` twice: PASS
- `dpkg-source -x ...`: PASS
- `lintian --display-info --pedantic`: PASS, no tags
- `dpkg-parsechangelog` and Deb822 parsing of control, tests, and copyright: PASS
- `make -f debian/rules -n clean`, `sh -n debian/tests/smoke`, executable checks, and `git diff --check`: PASS
- `uscan` matching pattern: PASS when explicitly checking registered 0.5.0; the page currently lists only 0.5.0
- `dpkg-checkbuilddeps`: not satisfied in this environment; see limitations

## Scope and limitations

This closes P01 only. No binary `.deb` build or autopkgtest execution was
attempted; those belong to P02. The source package is unsigned and has not been
uploaded. The Salsa branch remains local and has not been pushed.

Build dependencies still unavailable in the configured archive include
`libgmpfrxx-mkii-dev (>= 1.5.0)` and `libmplapack-mpfr-dev`; `dh-octave`,
`dh-sequence-octave`, `debugedit`, and `debhelper-compat (= 13)` are also not
installed in this environment. The `debian/watch` source is the Octave Packages
index page. It currently reports 0.5.0 because follow-up PR #844, which adds
0.5.1, has not yet merged. Rerun the ordinary `uscan` check after that merge.

## Required milestone record

Branch: Salsa local `debian/latest` (not pushed); report/status update on project `main`
Starting commit: `398ce263036cdb81d1e3b096a04bef54a1d13971` (Salsa)
Final commit: `6a5adf11aae8b2ca1586240a7750b79b152b890d` (P01 Debian metadata, Salsa)
Files changed: Salsa `debian/.gitignore`, `debian/changelog`, `debian/control`, `debian/copyright`, `debian/patches/reproducible-mkoctfile-debug-paths.patch`, `debian/patches/series`, `debian/rules`, `debian/source/format`, `debian/tests/control`, `debian/tests/smoke`, `debian/tests/smoke.m`, and `debian/watch`; project `docs/milestones/README.md`, `docs/milestones/P01-debian-source-package.md`, and `P01-report.md`.
Commands run: `dpkg-source -b .` (twice), `dpkg-source --after-build .`, `dpkg-source -x`, `lintian --display-info --pedantic`, `dpkg-parsechangelog`, Deb822 parse checks, `make -f debian/rules -n clean`, `sh -n debian/tests/smoke`, `uscan --no-download --report --download-version=0.5.0 --verbose`, `dpkg-checkbuilddeps`, `patch --dry-run -p1`, `git diff --check`, and SHA256 checks.
Tests: Source-package build, repeatability, extraction/patch application, Lintian, Debian metadata parsing, rules/smoke syntax, and patch applicability PASS. `dpkg-checkbuilddeps` remains unsatisfied; the current package-index page is one release behind.
Gate: `GP01 PASS` — policy-valid Debian source package generated, unpacked, lintian-clean, and reproducible across two generations.
Known limitations: Build dependencies are unavailable, so P02 binary build and runtime autopkgtest remain blocked. Salsa push and upload remain unperformed. Rerun `uscan` after PR #844 merges.
