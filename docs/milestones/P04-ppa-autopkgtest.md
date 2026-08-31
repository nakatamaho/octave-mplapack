# P04 — PPA autopkgtest

# Goal

Test the package actually installed from the staging PPA.

# Scope

Add package-level automated tests that load the installed Octave package, set
100 decimal digits, construct a system, and solve it with `A \ b`.

# Non-goals

- Running tests against the source checkout instead of the installed package
- Stable promotion before all tests pass
- Expanding the numerical API beyond M10

# Design constraints

The minimum installed-package test is:

```octave
pkg load mplapack
mpdigits(100);
A = mp({"1", "2"; "3", "4"});
b = mp({"1"; "2"});
x = A \ b;
```

Tests must resolve files from the installed binary package and exercise its
native MPLAPACK MPFR path.

# Implementation tasks

- Add appropriate Debian autopkgtest metadata and installed-package commands.
- Verify package origin and installed paths during the test.
- Run the minimum solve and relevant regression checks.
- Collect results for each staging series and architecture.

# Required tests

Run the minimum workflow from the installed package and verify a correct result,
MPFR precision behavior, native linkage, and no source-tree contamination.

# Gate

`GP04` passes when installed staging packages pass autopkgtest on every required
target. This gate is planned and is not passed by M00.

# Expected commit

`P04: add installed-package autopkgtests`
