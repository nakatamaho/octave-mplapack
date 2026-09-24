# P02 — Local Debian build

# Goal

Build and exercise `octave-mplapack` in a clean Ubuntu environment before PPA
publication.

# Scope

Use the appropriate supported subset of tools such as `debuild`,
`dpkg-buildpackage`, `lintian`, `sbuild`, or `pbuilder` to build source and
binary packages and verify lifecycle behavior.

# Non-goals

- Requiring every possible Debian build tool blindly
- PPA upload or Launchpad publication
- Testing only from the source checkout

# Design constraints

The clean environment must use declared dependencies. Tests must exercise the
installed package, and build results must remain traceable to the generated
source package.

# Implementation tasks

- Select and document the supported clean-build toolchain.
- Build source and binary packages in the clean environment.
- Install, load, remove, and reinstall the binary package.
- Run package-level Octave functionality and dependency diagnostics.

# Required tests

Verify source-package creation, clean build, lint results as applicable,
installation, `pkg load mplapack`, removal, reinstall, functional operation,
and correct dependency declarations.

# Result and supported toolchain

`GP02 PASS` on Ubuntu 26.04.1 amd64 with Octave 11.1.0-3 and
`dh-octave` 1.14.1. Build dependencies were checked with
`dpkg-checkbuilddeps -B`. The source package was generated twice with
`dpkg-buildpackage -S -us -uc -sa`; both generations were byte-identical.
The binary was built from a fresh `dpkg-source -x` extraction using
`dpkg-buildpackage -b -us -uc -j32`.

The declared local dependencies were `libgmpfrxx-mkii-dev` 1.5.0+ds-1 and
MPLAPACK 3.0.1+ds-1. The installed package was exercised with a fresh Octave
user directory, removed, and reinstalled. `debian/tests/smoke` passed after
both installations. See the root-level [`P02-report.md`](../../P02-report.md)
for artifact hashes, commands, test details, and remaining limitations.

# Gate

`GP02` passes when clean local packages complete the documented build and
installed-package lifecycle. Result: **PASS**; PPA staging and publication
remain deferred to P03 and later.

# Expected commit

`P02: validate clean local Debian package build`
