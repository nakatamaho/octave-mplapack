# P02 `gmpfrxx-mkii` packaging workspace

Status: **DRAFT / PARTIAL**. This directory contains a local packaging
scaffold and is not a Debian submission.

Input archive: `gmpfrxx_mkII.1.4.1.tar.xz` with SHA256
`395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4`.

The draft was exercised in an unprivileged lab with `dpkg-buildpackage`:
the source package and an `amd64` development package were produced from the
released archive. The rules explicitly stage CMake installation in
`debian/tmp` before `dh_install`; this was required to make the draft binary
build complete. This is build evidence only; it is not a Debian QA or
submission result. The draft still has a placeholder maintainer, no team or
Salsa identity, and no final binary-package split.

The resulting development package currently carries the unversioned
`libgmpxx_mkII_default_context_provider.so` together with the headers and
CMake metadata. Resolve that ABI/SONAME decision, Debian copyright policy,
dependency completeness, and the final runtime/development split before
publishing a package. The package must not be marked ready from this
placeholder.

The latest draft package hash and source-build evidence are recorded in
`release/debian/QA-EVIDENCE.md`; the extracted-package provider smoke also
passes. `lintian --pedantic` now runs and reports the documented provider
SONAME/ldconfig findings. `sbuild` and the remaining Debian QA tools are not
yet available in the base environment.

The committed `debian/watch`, `debian/upstream/metadata`, install manifest,
and provider-header autopkgtest are review-only additions. The provider test
requires the final package's unversioned provider-library policy and therefore
does not constitute an autopkgtest PASS until that ABI/SONAME decision is
accepted by Debian maintainers.
