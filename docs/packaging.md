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

M20 audited the installed MPFR complex symbols and found them in the same
`libmplapack_mpfr.so.3` dependency already used by the real backend. The
runtime closure includes system MPC, MPFR, and GMP libraries, so the existing
`octave-mplapack` package can gain complex support in a later update without a
package rename. License and dependency metadata for those system libraries
remain P01/PPA work. The explicit M20 release decision is
`REAL-PPA-GO`; complex implementation is not required for the real-only PPA.
M22 records the concrete handoff in [`ppa-plan.md`](ppa-plan.md): Ubuntu
26.04/Octave 11.1 amd64 is the initial validated target, with an MPLAPACK MPFR
Debian package boundary and an `octave-mplapack` package update. No PPA upload
occurs before M23.
