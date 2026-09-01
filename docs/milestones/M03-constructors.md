# M03 — Public scalar constructor and wrapper

# Goal

Expose the M02 native scalar as a public `mp` value and support construction
from scalar decimal text, scalar real double, and an existing scalar `mp`:

```octave
mp("1.25")
mp(1.25)
mp(mp("1.25"))
```

# Scope

Public class encapsulation, direct decimal parsing, exact preservation of
incoming binary64 values, deterministic internal 128-bit default precision,
scalar `1 x 1` dimensions, signed zero and special values, and clear rejection
of invalid, complex, matrix, cell, empty, and concatenation inputs.

# Non-goals

- Arithmetic operations
- Complex or MPC-valued construction
- Treating double and decimal text inputs as equivalent
- Public precision control
- Conversion or numeric display
- Dense, cell, numeric, or empty matrix construction

# Design constraints

String input must reach MPFR without an intermediate binary64 value. Double
input must preserve the binary64 value Octave supplies. Construction must use
the current project-owned default precision without mutating existing objects.
The internal native type remains private.  Dense `mp` matrices must not be
represented as arrays or cells of scalar wrapper objects.

M02 established that the dense representation is an M07 decision.  The early
roadmap's matrix constructor work is therefore deliberately moved to M07
rather than forcing a container design in M03.

# Implementation tasks

- Add a public classdef scalar wrapper with private native payload ownership.
- Add separate scalar text and binary64 native construction paths.
- Establish the reusable internal 128-bit default precision component.
- Preserve signed zero, infinity, and NaN through supported constructor paths.
- Reject complex, matrix, cell, empty, and concatenation inputs.
- Keep conversion, arithmetic, indexing, and matrix representation absent.

# Required tests

Cover public class identity, private payload encapsulation, scalar dimensions,
copy/container/function lifetime, invalid inputs, decimal parsing, exact
binary64 conversion, signed zero, finite extremes, infinity, NaN, and package
unload/shutdown safety.  Demonstrate that `mp("0.1")` and `mp(0.1)` differ,
while `mp("0.125")` and `mp(0.125)` agree.  Prove concatenation does not create
an object-array matrix.

# Gate

`G03` passes when the public scalar wrapper preserves M02 ownership, the two
constructor paths obey the normative precision contract, scalar identity and
dimensions are correct, matrix behavior remains absent, and installed-package
QA passes.

# Expected commit

`M03: add public scalar mp constructors`
