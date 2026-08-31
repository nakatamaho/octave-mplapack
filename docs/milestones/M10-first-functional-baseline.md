# M10 — First functional baseline

# Goal

Make the first complete source-install workflow succeed:

```octave
pkg install .
pkg load mplapack

mpdigits(100);

A = mp({"1", "2"; "3", "4"});
B = mp({"5", "6"; "7", "8"});
C = A * B;

b = mp({"1"; "2"});
x = A \ b;

disp(C);
disp(x);
```

# Scope

Integrate M01-M09 into a cleanly installable and testable package candidate for
`octave-mplapack 0.1.0`.

# Non-goals

- SVD or eigenvalue routines
- Complex arithmetic or non-MPFR backends
- Debian packages or PPA publication

# Design constraints

The package must have no hard-coded MPLAPACK prefix, no dependency on the
MPLAPACK source/build tree, and no accidental binary64 implementation of
multiprecision operations. Keep the first baseline intentionally narrow.

# Implementation tasks

- Integrate the private native module into Octave package install/load.
- Provide clear dependency diagnostics and reproducible rebuild behavior.
- Run the full constructor, precision, conversion, arithmetic, GEMM, and GESV
  suites from clean source.
- Document the supported 0.1.0 behavior and known limits.

# Required tests

Verify clean package installation, loading, the complete workflow above,
automated QA, a clean rebuild, dependency diagnostics, backend linkage,
precision semantics, and absence of generated artifacts afterward.

# Gate

`G10` passes when the complete workflow and all required properties succeed
from a clean source tree. It establishes the first 0.1.0 candidate. This gate
is planned and is not passed by M00.

# Expected commit

`M10: establish first functional baseline`
