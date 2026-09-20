# mpclib3 1.4.1 Debian/PPA draft

This is a packaging draft for GNU MPC 1.4.1, used as a prerequisite by
`octave-mplapack-interop` 0.5.0.  The released interop source calls
`mpc_log2`, which was added in GNU MPC 1.4.0; Ubuntu 26.04 currently carries
MPC 1.3.1.  The PPA dependency order therefore needs this package before
`gmpfrxx-mkii`, `mplapack`, and `octave-mplapack-interop`.

The source archive is the official GNU MPC 1.4.1 release.  This directory
contains Debian metadata only; the upstream archive is supplied separately by
the PPA/source-package build.

This draft does not claim Debian acceptance, maintainer ownership, or a public
PPA upload.
