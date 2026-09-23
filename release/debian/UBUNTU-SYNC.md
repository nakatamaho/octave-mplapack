# Ubuntu sync status

Status: **N/A / NOT STARTED**.

The first target is Ubuntu 26.04 (Resolute) with the Octave 11.1 baseline.
There is no accepted Debian package to sync, no Ubuntu archive version, and
no Launchpad PPA publication. The staging PPA must be built and tested before
any sync discussion.

Do not target Ubuntu 24.04 or older releases for the current interop archive;
its declared minimum is GNU Octave 11.1.0. Do not backport Octave in this
controller.

When the external gate is available, compare the actual Debian and Ubuntu
versions and determine whether an Ubuntu delta is needed. Record the result
here only after a real Launchpad/Ubuntu build or archive review.
