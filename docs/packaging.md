# Packaging architecture

The intended dependency and delivery flow is:

```text
MPLAPACK packages
       |
       v
installed development interface
       |
       v
octave-mplapack source package
       |
       v
octave-mplapack binary package
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
