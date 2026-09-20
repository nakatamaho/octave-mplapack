# RELDEB00 status

## Completed local stages

```text
R00  PASS    released archives, tags/commits, licenses, and SHA256 recorded
P00  PASS    candidate names available in local Debian/BTS audit
P01  PARTIAL packaging boundary and license audit recorded
```

## Pending stages

```text
P02  PARTIAL  local gmpfrxx-mkii source/binary draft builds; provider ABI/SONAME and Debian QA remain
P03  PARTIAL  release/build-system audit complete; source package and Debian policy review remain
P04  PARTIAL  archive/build-boundary audit complete; source package depends on P02/P03
P05  BLOCKED  debuild/sbuild/lintian/autopkgtest/piuparts/reprotest unavailable
U00  PENDING  staging PPA metadata and credentials
U01  BLOCKED  Launchpad account, PPA, and upload key not configured
U02  PENDING  requires U01
D00  PENDING  ITP filing requires reporter identity and current WNPP recheck
D01  BLOCKED  Salsa/mentors account and signing identity not configured
D02  BLOCKED  sponsor/RFS workflow requires Debian submission identity
```

The local machine is Ubuntu 26.04 amd64 with Octave 11.1.0. It has
`dpkg-buildpackage`, CMake, and a compiler, but does not have `debuild`,
`sbuild`, `lintian`, `autopkgtest`, `piuparts`, `reprotest`, `gbp`, `uscan`,
`dput`, or `reportbug`; apt installation cannot be performed without root.
These are concrete environment blockers, not PASS results.

No ITP, Salsa repository, mentors upload, PPA upload, RFS, or public Debian
submission has been attempted. The next resumable stage is P02/P03 package
policy closure after the gmpfrxx provider ABI decision and packaging toolchain
are available; P04 must then be built against those packaged interfaces.
