# Debian QA toolchain status

Checked on 2026-09-20 on Ubuntu 26.04 amd64.

Available locally:

```text
dpkg-buildpackage
cmake
make
c++ / g++
octave 11.1.0
octave-dev 11.1.0
debhelper / dh
dh-octave
lintian
autopkgtest
debuild
sbuild
piuparts
reprotest
git-buildpackage / gbp
uscan
dput
reportbug
debsign (tool only; no signing identity)
```

Installed but not usable for publication:

```text
upload key / Debian identity
Launchpad account / PPA credentials
```

The `resolute-amd64-sbuild` schroot is registered for Ubuntu 26.04 amd64.
Because the host has no root subuid mapping, invoke sbuild with
`--chroot-mode=schroot`; default unshare mode is not a product failure. Clean
P02/P03/P04 compilation has passed in that chroot, while Lintian still reports
draft policy findings. The tools now support the next clean lifecycle,
reproducibility, and package-policy checks, but they do not establish a
publication or Debian-ownership PASS.

## Resume command

Resume at P02/P03 policy closure and then run the required Lintian,
autopkgtest, lifecycle, and reproducibility checks. Do not mark a package PASS
from a successful sbuild alone.
