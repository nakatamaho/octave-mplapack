# P02 result — clean local Debian build

## Result

The local Ubuntu 26.04.1 amd64 build and installed-package lifecycle for
`octave-mplapack` 0.5.1 passed. The binary was built from an extracted Debian
source package, installed, loaded and exercised in a fresh Octave user
environment, removed, and reinstalled from the same `.deb`.

## Source and binary artifacts

- Upstream archive: `octave-mplapack_0.5.1.orig.tar.gz`
- Upstream SHA256: `50622b177d9e320ad8c02d4c15aae037a0643c27300a5ead529f4e829ad8d080`
- Final source package: `octave-mplapack_0.5.1-1.dsc`
- `.dsc` SHA256: `3675b07ce5fd63d025c8307f2c47fc72cea6d5de64bf31d02f8e1d11b0b01216`
- Debian tarball SHA256: `ae8485698187da68ea2adf8442b02bc333ee3f1190588a359ce13443d3546d6c`
- Binary package: `octave-mplapack_0.5.1-1_amd64.deb`
- `.deb` SHA256: `d2d7775192f91df09a21965240f5076e4258211ac8fa1789f0f70a96016b7c73`
- Source-package generation was repeated; the `.dsc` and Debian tarball were
  byte-identical.

## MPLAPACK prerequisite package evidence

The MPFR runtime/development split was built locally from the verified MPLAPACK
3.0.1 source archive. The repacked orig tarball SHA256 is
`0f826cbae67075a86df896b4c0fd5880c4b98acbf26f3ed846cf2935edc47bc8`; the
source `.dsc` SHA256 is
`a7447323097137a83febe04bbdbca899aaebfc827f8585e9fce46f916fab24e5`. Runtime
and development `.deb` SHA256 values are `df866837cce6e85994b8375c810ccc3ca7db56d53c25fbe960e99651759c872b` and
`26ad47b68e17cec92989b578ac2e047ebda292aaf33cf5da19f41b9e1af14391`.
The build passed its six clean-process shared-library/relocation checks; the
installed smoke exercised MPFR `Rgemm`/`Rgesv` and MPC `Cgemm` through both
pkg-config modules. The packages were removed and reinstalled successfully.

## Build environment and validation

- Ubuntu 26.04.1 LTS, amd64; GNU Octave and `octave-dev` 11.1.0-3.
- `dh-octave` 1.14.1 (providing `dh-sequence-octave`) was installed from the
  Ubuntu archive. `dpkg-checkbuilddeps -B` passed.
- The declared local dependency stack was installed: `libgmpfrxx-mkii-dev`
  1.5.0+ds-1 and MPLAPACK 3.0.1+ds-1 runtime/development packages.
- Toolchain: generate the source package with `dpkg-buildpackage -S`, extract
  that `.dsc` with `dpkg-source -x`, then build with
  `dpkg-buildpackage -b -us -uc -j32`. The clean binary build took 31.58
  seconds.
- Source Lintian: no tags. Binary/source Lintian: no errors; the remaining
  tags are the expected initial-upload notice and pedantic reports that the
  upstream `examples/` and `docs/examples/` trees are not installed.
- The installed native module links to `libmplapack_mpfr.so.3`, MPC, MPFR, and
  GMP from system paths. `ldd` found no missing libraries. `readelf` confirmed
  GNU RELRO and BIND_NOW; no project-specific or temporary build paths were
  embedded.

## Installed-package test

The `debian/tests/smoke` script was run against the installed `.deb`, using a
fresh temporary `HOME` and no source checkout on Octave's path. It passed after
both initial installation and remove/reinstall. It verifies the 512-bit fresh
process default, package loading, real dense multiplication and solve,
Cholesky, QR, pivoted QR, LU, eigenvalues, SVD, complex multiplication and
`log2`, deterministic random generation, and binary serialization. Removal
also removed the package's native module and Octave package directory before
reinstallation.

## Required milestone record

Branch: Salsa local `debian/latest` (not pushed); project documentation on `main`
Starting commit: `6a5adf11aae8b2ca1586240a7750b79b152b890d` (Salsa P01)
Final commit: `0cc21bf23e3cf24939b23b9ba879e459d7a6e390` (Salsa P02; not pushed)
Files changed: Salsa `debian/changelog`, `debian/rules`, and `debian/patches/reproducible-mkoctfile-debug-paths.patch`; project `docs/milestones/README.md`, `docs/milestones/P02-local-deb-build.md`, and `P02-report.md`.
Commands run: `apt-get install dh-octave`; `dpkg-checkbuilddeps -B`; `dpkg-buildpackage -S -us -uc -sa` twice; `dpkg-source -x`; clean `dpkg-buildpackage -b -us -uc -j32`; `lintian --display-info --pedantic`; local `.deb` install/remove/reinstall; `debian/tests/smoke`; `ldd`, `readelf`, and SHA256 checks; `git diff --check`.
Tests: Source package extraction and patch application, repeated source generation, clean binary build, Lintian, Octave package load and numerical smoke, remove/reinstall lifecycle, ELF dependency/hardening checks: PASS.
Gate: `GP02 PASS` — locally built package completed the installed lifecycle and package-level numerical tests.
Known limitations: The `autopkgtest` runner and a `sbuild`/`pbuilder` chroot were not used; the autopkgtest smoke script itself was run directly against the installed binary. `dh_octave_check` reported zero embedded BIST tests. The MPLAPACK packaging tree remains a local staging workspace, not a committed Salsa repository. The source package is unsigned and neither Salsa nor PPA publication was performed. Pedantic example-install tags remain documented above.
