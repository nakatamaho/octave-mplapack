# M10 — Dense matrix inspection

# Goal

Make dense `mp` results inspectable through normal read-only Octave syntax:

```octave
pkg install .
pkg load mplapack

mpdigits(100);

A = mp({"1", "2"; "3", "4"});
B = mp({"5", "6"; "7", "8"});
C = A * B;

b = mp({"1"; "2"});
x = A \ b;

A(2, 1);
double(A);
disp(A);
```

# Scope

Add precision-preserving read-only indexing, `end`, matrix `double`, and
matrix `disp` to the M09 package while preserving the native dense payload.

# Non-goals

- Matrix assignment or logical indexing
- SVD or eigenvalue routines
- Complex arithmetic or non-MPFR backends
- Debian packages or PPA publication

# Design constraints

The package must have no hard-coded MPLAPACK prefix, no dependency on the
MPLAPACK source/build tree, and no accidental binary64 implementation of
multiprecision operations. Keep the first baseline intentionally narrow.

# Implementation tasks

- Implement native index selection and deep-copy slices.
- Add `end`, precision-preserving matrix `double`, and canonical matrix display.
- Run the full M00-M09 regression suite and installed-package QA.
- Document supported inspection operations and known limits.

# Required tests

Verify element, slice, linear, repeated, reordered, empty, and `end` indexing;
invalid-index errors; source-precision preservation; matrix double/display;
sanitizers; clean package installation; lifecycle behavior; and all M00-M09
regressions.

# Gate

`G10` passes when all read-only inspection gates and M00-M09 regressions pass
from a clean source tree and installed package. Matrix assignment remains
unsupported.

# Expected commit

`M10: add dense matrix inspection`
