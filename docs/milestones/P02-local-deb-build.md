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

# Gate

`GP02` passes when clean local packages complete the documented build and
installed-package lifecycle. This gate is planned and is not passed by M00.

# Expected commit

`P02: validate clean local Debian package build`
