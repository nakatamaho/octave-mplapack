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

The current local candidate applies a packaging-only CMake target
`SOVERSION 1` and splits the provider into
`libgmpxx-mkii-default-context-provider1`; the development package retains
the headers, CMake metadata, and unversioned linker symlink. This resolves the
local ELF packaging defect, but the package remains a review draft: Debian
copyright policy, dependency completeness, symbols/Multi-Arch policy, and
maintainer ownership still require review before publication.

The latest draft package hash and source-build evidence are recorded in
`release/debian/QA-EVIDENCE.md`; the extracted-package provider smoke also
passes. Direct binary `lintian --pedantic` on the split candidate reports only
the expected initial-upload warning; source-package licensing and metadata
findings remain. `sbuild` and the remaining Debian QA tools are not yet
available in the base environment.

The committed `debian/watch`, `debian/upstream/metadata`, install manifest,
and provider-header autopkgtest are review-only additions. Direct binary
Lintian for the local split candidate reports only the expected
`initial-upload-closes-no-bugs` warnings; this does not constitute Debian
archive acceptance.

The Debian source candidate is now `1.4.1+dfsg-1`. `debian/watch` requests a
`+dfsg` repack which excludes the unused `reference/upstream` snapshot from
the source archive; this removes the bundled GFDL-invariant documentation
from the Debian source package without changing the installed headers or
provider. The locally generated repacked orig archive has SHA256
`94792367fa08f50967319f3294cf7376688eaf172869df1227f61d1c9476ba87` and size
`14792668` bytes. This is local packaging evidence, not a final Debian source
artifact.

## Local provider SONAME candidate (2026-09-20)

The split candidate was installed into the local resolute stack rootfs and
`ldconfig` completed successfully. `readelf -d` reports:

```text
libgmpxx_mkII_default_context_provider.so.1
```

The development package depends on the new runtime package and owns only the
unversioned linker symlink. This is a packaging-only draft resolution; source
package licensing, Debian ABI/symbols policy, and maintainer review remain
open.
