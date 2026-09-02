# Real-only PPA handoff plan

M20 established `REAL-PPA-GO`; complex support is not a prerequisite for the
real-only release. M23 freezes the upstream candidate and records the exact
source/archive handoff. No Debian upload or PPA publication is performed here.

## Planned stages

| Stage | Deliverable |
|---|---|
| PPA1 | Debian package for the accepted MPLAPACK MPFR dependency, including the uniform-precision interface |
| PPA2 | `octave-mplapack` source/binary package and autopkgtest smoke coverage |
| PPA3 | Launchpad staging build and install/linkage checks |
| PPA4 | Public real-only v0.1 PPA and final tag after staging |

The initial target is Ubuntu 26.04 with Octave 11.1.0. Deep package QA has
validated amd64; other architectures remain a source-portability goal, not a
release claim. macOS packaging is separate and does not block the Ubuntu PPA.

## Package boundary proposal

Names are proposals for PPA1/PPA2 policy review:

```text
libmplapack-mpfr3
libmplapack-mpfr-dev
octave-mplapack
```

The MPLAPACK development package must provide the pinned uniform-precision
interface (including `mplapack_mpfr_precision.h`) and the MPFR library through
`pkg-config`. A future runtime closure is expected to contain Octave,
`libmplapack_mpfr.so.3`, MPC, MPFR, and GMP. The octave package's draft
Build-Depends are `debhelper-compat`, `octave-dev`, `pkg-config`, the
MPLAPACK MPFR development package, MPFR/MPC/GMP as needed or propagated, and
standard C++ build tools.

The public package name remains `octave-mplapack`; complex support can arrive
as a later package update because M20 found the complex symbols in the same
MPLAPACK MPFR library. Final Debian names, symbols, shlibs, and license files
belong to PPA1/PPA2. No source-tree path, temporary prefix, or Git checkout is
allowed in a package build.

## Handoff blockers

Before upload, PPA work must package the exact accepted MPLAPACK revision,
confirm Launchpad's Octave 11.1 availability, complete amd64 build/install
tests, and decide the multi-series architecture matrix. These are packaging
tasks, not blockers to the real-only architecture decision.
