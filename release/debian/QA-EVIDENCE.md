# RELDEB00 local QA evidence

All commands in this note were run on 2026-09-20 from the project worktree.
They are provenance and environment evidence; they do not replace Debian
package QA.

## Release archives

```text
395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4  gmpfrxx_mkII.1.4.1.tar.xz  15176064 bytes
47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa  mplapack-3.0.1.tar.xz       85720132 bytes
3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04  mplapack-interop-0.5.0.tar.gz   817463 bytes
```

These values match `SHA256SUMS` and the published GitHub release assets.

## Installed MPLAPACK interface

The controlled installed environment reports:

```text
pkg-config module: mplapack_mpfr
pkg-config version: 3.0.1
cflags/libs: -I/usr/local/include/mplapack -I/usr/local/include -L/usr/local/lib -lmplapack_mpfr -lmpc -lmpfr -lgmp
```

The `/usr/local` output is observed environment evidence only; it is not a
committed build path and must not be used by Debian packaging.

## gmpfrxx release smoke

The 1.4.1 release was configured with CMake using GMP/MPFR/MPC components,
tests enabled, examples and benchmarks disabled, built with the system C++
compiler, and installed into an isolated `DESTDIR`. CTest reported:

```text
156/156 tests passed
```

The install audit found the headers, CMake metadata, and the default-context
provider described in `PACKAGING-AUDIT.md`.

## Debian toolchain

`dpkg-buildpackage`, CMake, make, C++, Octave 11.1.0, and octave-dev are
available. `debuild`, `dh`, `dh-octave`, `lintian`, `sbuild`, `autopkgtest`,
`piuparts`, `reprotest`, `gbp`, `uscan`, `dput`, `reportbug`, and `debsign` are
missing. Apt installation is unavailable to the unprivileged user. Therefore
P05 is BLOCKED and no Debian package QA result is claimed.

The repository's `tools/local-ci.sh` was also started with the previously
validated MPLAPACK prefix supplied only through `PKG_CONFIG_PATH`. That run
passed the dependency probe, the M00–M21 native probes, M20 complex probes, and
many public/NEIG checks, but it was intentionally interrupted before the full
suite completed at the user's request. It is therefore evidence of useful
progress, not a full local-CI PASS.

## P02 packaging draft

Using the released `gmpfrxx_mkII.1.4.1.tar.xz` archive, a local unprivileged
lab with `dpkg-buildpackage` produced both a Debian source package and the
draft binary package `libgmpfrxx-mkii-dev_1.4.1-1_amd64.deb`. The draft was
configured with system GMP/MPFR/MPC and with examples, benchmarks, and tests
disabled for the package build. The CMake build and install completed.

Two clean draft binary builds produced:

```text
548e6d4e4b04b7832672f8ee806b12d017b8e690524f60afb4fbee702a0188c  libgmpfrxx-mkii-dev_1.4.1-1_amd64.deb
```

The package contains headers, CMake metadata, and
`libgmpxx_mkII_default_context_provider.so`. The provider has an unversioned
SONAME and the draft uses placeholder maintainer metadata, so this is not a
release or Debian submission artifact. `lintian` could not yet run because
the base environment lacks its Perl dependency set; P02 remains PARTIAL and
P05 remains BLOCKED.
