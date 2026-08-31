# M01 — Build and dependency probe

# Goal

Build the smallest native `.oct` module and prove that Octave can load a module
linked to MPLAPACK's MPFR backend. The target public function is
`mplapack_version()` after `pkg load mplapack`.

M01 implements the private module as `__mplapack_core__.oct`. Its `version`
command calls `Rlamch_mpfr("E")`, verifies that the returned machine epsilon is
positive and finite, and reports the Octave, MPLAPACK, backend, and MPFR
versions through `mplapack_version()`.

# Scope

Report, where reliably obtainable, the Octave version, MPLAPACK version,
`backend = mpfr`, and MPFR version. Establish the minimal package native build.

The build uses `pkg-config` module `mplapack_mpfr`, requires MPLAPACK 3.0.0 or
newer without fixing a patch version, and passes the detected version into the
native module at compile time. `src/Makefile` honors the package manager's
`MKOCTFILE` value, including values with options.

# Non-goals

- Native `mp` storage or constructors
- Numerical matrix operations
- A general MPLAPACK wrapper layer

# Design constraints

Use `mkoctfile` through package tooling, honor `MKOCTFILE`, and discover
`mplapack_mpfr` through `pkg-config`. Do not hard-code a prefix or depend on an
MPLAPACK source/build tree. Keep `__mplapack_core__.oct` private.

The first M01 attempt exposed an underlinked installed MPLAPACK MPFR shared
library through the unresolved `mpc_set_z` relocation. M01 resumed only after
the defect was corrected upstream and the installed library passed a clean
SONAME load, `ldd -r`, and DT_NEEDED inspection. No downstream preload, RPATH,
or manually appended backend libraries compensate for that former defect.

# Implementation tasks

- Record the `pkg-config` version, flags, libraries, and resolved installation.
- Implement the non-fabricated `Rlamch_mpfr("E")` version/runtime probe.
- Build and load the module directly and through Octave package installation.
- Inspect the MPLAPACK and native-module linker dependencies and symbols.
- Generate `dist/mplapack-<version>.tar.gz` deterministically from an explicit
  source set with `tools/build-package.sh`.
- Install, load, uninstall, and reinstall that archive under a temporary HOME
  from a neutral working directory.

# Required tests

Prove that `mkoctfile` produces the module, Octave loads it, runtime linker
dependencies resolve, and the MPLAPACK MPFR backend is actually linked without
access to an MPLAPACK build tree.

`tools/local-ci.sh` verifies the standalone MPLAPACK load and relocations,
native DT_NEEDED and `Rlamch_mpfr` reference, direct native/public probes,
missing-dependency failure, clean rebuild, deterministic archive contents,
Octave 11.1 metadata parsing, and isolated installed-package paths and runtime.

# Gate

`G01 PASS`: the build, load, linkage, dependency, source-package,
installed-package, clean-rebuild, negative-dependency, and version-reporting
evidence succeeded with the installed MPLAPACK MPFR consumer interface.

# Expected commit

`M01: add native MPLAPACK MPFR build probe`
