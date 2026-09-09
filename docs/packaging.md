# Packaging architecture

The GNU Octave package identity for the forward release is
`mplapack-interop`; `octave-mplapack` remains the repository name. The
historical D00 package name `mplapack` is retained only in historical release
records. The binary architecture and B01–B05 handoff are specified in
[`binary-distribution.md`](binary-distribution.md).

The intended dependency and delivery flow is:

```text
MPLAPACK packages
       |
       v
installed development interface
       |
       v
mplapack-interop source package
       |
       v
mplapack-interop binary package
       |
       v
GNU Octave users
```

MPLAPACK runtime and development packages remain conceptually separate from
the `octave-mplapack` source and binary packages. System dependencies are
preferred where possible; arbitrary dependency copies must not be bundled.

PPA work begins only after the M10 numerical baseline is stable enough.
Publication goes to a staging PPA before any stable archive. Launchpad builds
from source packages, and the stable artifacts must retain source/build
provenance rather than being silently rebuilt from different source.

Ubuntu 26.04 LTS is the first target. Ubuntu 24.04 LTS is secondary and must not
block the initial Octave 11 design. Actual Debian metadata belongs to P01 and
is intentionally absent during M00.

M20 audited the installed MPFR complex symbols and found them in the same
`libmplapack_mpfr.so.3` dependency already used by the real backend. The
forward binary architecture treats the package-local runtime closure and its
license notices as explicit B01–B05 deliverables; no global private-library
install is allowed. The old real-only PPA notes are historical and do not
authorize PPA work in D01R1. No PPA upload occurs before the PPA packaging
milestones.
