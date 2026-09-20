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
```

Not installed:

```text
debuild
sbuild
piuparts
reprotest
git-buildpackage / gbp
uscan
dput
reportbug
debsign
```

The available tools support local binary/lintian and smoke evidence, but no
clean `sbuild`/`autopkgtest` testbed, reproducibility run, Debian signing, or
public upload. The apt-cache candidates observed for the Ubuntu 26.04 target
include `dh-octave 1.14.1`, `debhelper-compat 13`, `devscripts 2.26.7`,
`lintian 2.129.0ubuntu2.1`, `sbuild 0.91.2ubuntu3`, `autopkgtest 5.55`,
`piuparts 1.6.0build1`, and `reprotest 0.7.32`.

## Resume command

After a clean Debian/Ubuntu testbed is available, resume at P02/P03 policy
closure. Do not mark a package PASS from `dpkg-buildpackage` alone; run the
required lintian, autopkgtest, lifecycle, and reproducibility checks.
