# M03 — Constructors and dimensions

# Goal

Support planned construction from strings, doubles, string cell matrices, and
double matrices:

```octave
mp("1.25")
mp(1.25)
mp({"1", "2"; "3", "4"})
mp([1, 2; 3, 4])
```

# Scope

Direct decimal parsing, exact preservation of incoming binary64 values during
conversion, matrix dimensions, deliberate empty behavior, and clear rejection
of invalid or complex input.

# Non-goals

- Arithmetic operations
- Complex or MPC-valued construction
- Treating double and decimal text inputs as equivalent

# Design constraints

String input must reach MPFR without an intermediate binary64 value. Double
input must preserve the binary64 value Octave supplies. Construction must use
the current default precision without mutating existing objects.

# Implementation tasks

- Add scalar string and double conversion paths.
- Add cell-string and double-matrix construction with preserved dimensions.
- Define empty matrix behavior and validate every cell.
- Reject complex and unsupported inputs with stable diagnostics.

# Required tests

Cover all four constructor forms, dimensions, empty inputs, invalid cell
contents, complex rejection, decimal-string parsing, and preservation of the
incoming binary64 value. Demonstrate the `mp("0.1")` versus `mp(0.1)`
distinction.

# Gate

`G03` passes when supported constructors obey the normative precision contract,
preserve dimensions, and reject unsupported input clearly. This gate is
planned and is not passed by M00.

# Expected commit

`M03: implement mp constructors and dimensions`
