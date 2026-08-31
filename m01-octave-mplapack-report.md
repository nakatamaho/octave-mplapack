# M01 RESULT

Repository:
nakatamaho/octave-mplapack

Remote:
https://github.com/nakatamaho/octave-mplapack.git

Branch:
topic/m01-build-probe

Starting commit:
1f7a60975b2db08a97f4cc0b8f2f6fb1242fc8dc

Final commit:
ccab9a2f8d5d9fe39500fae627ba1a8fde8da9bd

PR:
[#2 — M01: add native MPLAPACK MPFR build probe](https://github.com/nakatamaho/octave-mplapack/pull/2)

## MPLAPACK installation

- Version: 3.0.1
- pkg-config cflags: `-I/usr/local/include/mplapack -I/usr/local/include`
- pkg-config libs: `-L/usr/local/lib -lmplapack_mpfr -lmpc -lmpfr -lgmp`
- Prefix: `/usr/local`
- Library directory: `/usr/local/lib`

## MPLAPACK dependency-fix verification

- Clean-process libmplapack_mpfr load: PASS using derived SONAME `libmplapack_mpfr.so.3`
- ldd -r: PASS; no missing libraries or unresolved relocations
- DT_NEEDED: `libmpc.so.3`, `libmpfr.so.6`, `libgmp.so.10`, plus standard runtime libraries
- Original mpc_set_z failure: absent
- Result: PASS

## Package conformance

- COPYING: present
- LICENSE/COPYING match: PASS
- DESCRIPTION validation: PASS with Octave 11.1 package parser and `pkg install`; `0.1.0-dev` accepted

## Native build

- Module: `src/__mplapack_core__.oct`
- Build command: `make -C src clean`, `make -C src check-deps`, `make -C src`
- MPLAPACK probe routine: `Rlamch_mpfr("E")`
- Real MPLAPACK symbol reference: `U Rlamch_mpfr(char const*)`
- Direct MPLAPACK dependency: `libmplapack_mpfr.so.3`
- Unresolved dependencies: none; standalone plugin inspection showed only Octave host symbols, all matched to installed Octave libraries and resolved during runtime loading

## Runtime diagnostic

- Octave: 11.1.0
- MPLAPACK: 3.0.1
- Backend: mpfr
- MPFR: 4.2.2
- Probe routine: `Rlamch_mpfr("E")`
- Probe value: `7.4583e-155`
- Probe result: PASS

## Public wrapper

- mplapack_version: PASS
- direct-source path: `<repository>/inst/mplapack_version.m`
- result: PASS

## Source package

- Archive: `dist/mplapack-0.1.0-dev.tar.gz`
- Contents validation: PASS; deterministic, single top-level directory, required package files present, no Git/build/private artifacts

## Isolated package test

- Temporary environment: isolated `mktemp` HOME and neutral working directory; removed after QA
- pkg install: PASS from source archive; native compilation used package-supplied `MKOCTFILE`
- pkg load: PASS
- installed mplapack_version path: `<temporary HOME>/.local/share/octave/api-v61/packages/mplapack-0.1.0-dev/mplapack_version.m`
- installed __mplapack_core__ path: `<temporary HOME>/.local/share/octave/api-v61/packages/mplapack-0.1.0-dev/x86_64-pc-linux-gnu-api-v61/__mplapack_core__.oct`
- source-tree shadowing: absent
- runtime probe: PASS
- uninstall/reinstall: PASS
- result: PASS

## QA

- prerequisite check: PASS
- check-tree: PASS
- check-format: PASS
- local-ci: PASS
- clean rebuild: PASS twice with runtime re-test
- negative dependency test: PASS; expected exit status 2 with clear diagnostic
- git diff --check: PASS
- generated-artifact cleanup: PASS; source tree clean, ignored archive retained for inspection
- git status: clean
- GitHub push: PASS
- remote SHA: `ccab9a2f8d5d9fe39500fae627ba1a8fde8da9bd`, matches local
- GitHub CI: PASS; structural checks succeeded for push and PR

## Files changed

`.gitignore`, `COPYING`, `DESCRIPTION`, `INDEX`, `NEWS.md`, `README.md`, architecture/milestone documentation, native bridge and Makefile, public wrapper, M01 tests, package builder, and QA scripts.

## Gate

G01 PASS

## Known limitations

- native multiprecision mp value is not implemented
- arithmetic is not implemented
- M02 has not started
- GitHub CI remains structural; native M01 QA is authoritative in the configured MPLAPACK environment
- the installed MPLAPACK has its own RUNPATH for backend dependencies; octave-mplapack adds no preload, RPATH, or hard-coded dependency path

## Next milestone

M02 — Native mp value storage

```text
Branch:
topic/m01-build-probe
Starting commit:
1f7a60975b2db08a97f4cc0b8f2f6fb1242fc8dc
Final commit:
ccab9a2f8d5d9fe39500fae627ba1a8fde8da9bd
Files changed:
18 files
Commands run:
Repository audit; toolchain and pkg-config inspection; clean load, ldd/readelf/nm checks; clean builds; Octave probes; package generation/install/removal/reinstall; QA; commit; push; PR and CI verification.
Tests:
check-tree PASS; check-format PASS; local-ci PASS; clean rebuild PASS; negative dependency PASS; isolated package runtime PASS; GitHub structural CI PASS.
Gate:
G01 PASS
Known limitations:
Native mp storage and arithmetic are not implemented; M02 has not started.
```
