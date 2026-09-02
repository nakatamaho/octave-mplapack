# Precision semantics

This document is normative. Implementations must obey it unless a later
milestone changes the contract with rationale, explicit tests, and migration
notes when user-visible behavior changes.

## Decimal string input

```octave
x = mp("0.1");
```

The decimal text `0.1` is parsed directly at the target MPFR precision. It does
not first pass through IEEE binary64. The result is therefore a high-precision
approximation to the mathematical decimal value 1/10.

## Double input

```octave
x = mp(0.1);
```

The Octave literal is already an IEEE binary64 value before `mp` receives it.
Conversion to MPFR must preserve the numerical value of that binary64 input.
It must not pretend to be equivalent to `mp("0.1")`. Tests must demonstrate
this distinction.

## Canonical precision unit

Bits are the canonical internal precision unit. The primary API is `mpbits()`
and `mpbits(n)`; `mpdigits()` is a convenience API.

M03 initially established the project-owned state at 128 bits.  M04 changes
the fresh-session initial default to 512 bits and exposes that same state
through `mpbits` and `mpdigits`; there is no second setting.  Constructors read
the current value from the internal precision component and pass it explicitly
to each new native scalar or uniform-precision dense matrix.  Normal
construction does not use MPFR's mutable
process-global default.

M03 scalar construction uses explicit MPFR round-to-nearest (`MPFR_RNDN`) for
both decimal parsing and conversion of an incoming binary64 value.  It does
not inherit a caller-modified MPFR process default rounding mode.

## Decimal-digit conversion

`mpdigits(n)` requests at least `n` complete base-10 significant digits for
subsequently constructed values and maps directly to:

```text
bits = ceil(n * log2(10))
```

M04 adds no hidden guard bits.  The conversion is certified with directed MPFR
interval bounds, so it cannot silently truncate or return one bit too few.
`mpdigits()` reports:

```text
digits = floor(bits * log10(2))
```

This is the number of complete decimal digits guaranteed by the current
representational precision; it is not an accuracy claim for an arbitrary
algorithm.  The public getters and successful setters return `uint64` values.

## Default state lifetime

The default is process-local and session-local, not thread-local.  It is stored
in the native precision component with data-race-safe atomic access.  A change
persists across ordinary `clear` and `pkg unload`/`pkg load` in the same Octave
process because the native module remains resident.  It is neither written to
disk nor inherited by another Octave process; every fresh process starts at
512 bits.

`mpbits(n)` and `mpdigits(n)` validate and convert the complete request before
committing the new state.  Failed setters leave the previous value unchanged.
Floating inputs are accepted only in their contiguous exact-integer range;
Octave integer scalar types allow larger exact requests up to the MPFR range.

The project does not call `mpfr_set_default_prec` to represent its state.
Instead, successful `mpbits(n)` and `mpdigits(n)` setters synchronize the
calling thread's gmpfrxx/MPFR default through its public setter.  This default
is an execution context for MPLAPACK MPFR calls, not storage for an existing
value. M08 and M09 temporarily enter `MplapackMpfrPrecisionScope` at the
operand-derived operation precision and restore the caller's default on every
exit. Explicit-precision construction remains independent of later default
changes, and no process-wide precision mutation is used.

## Existing objects

Changing the default precision affects subsequently created `mp` values only.
It must not silently mutate existing values:

```octave
mpbits(128);
a = mp("0.1");

mpbits(512);
b = mp("0.1");
```

Here `a` retains its original precision and `b` uses the new default.

M07 applies the same invariant to matrices.  One matrix has one immutable
precision, every element is explicitly initialized at that precision, and
later default changes do not alter matrix metadata or element values.

M10 applies the same invariant to read-only indexing and conversion. Matrix
elements and slices are copied at the source matrix precision, while
`double(A)` is an explicit MPFR-to-binary64 conversion and `disp(A)` uses the
source values directly. Neither operation uses the current default to choose
an extracted precision or display precision.

M11 applies the invariant to dense element-wise `+`, `-`, `.*`, and `./`, as
well as unary signs. Binary `mp` operands use the maximum stored operand
precision; a mixed binary64 operand uses the `mp` operand precision. Each
destination element is explicitly allocated at that operation precision and
computed with direct MPFR round-to-nearest arithmetic. Two-dimensional
singleton expansion does not materialize expanded operands, and neither the
project default nor the current-thread MPFR default participates in result
precision selection or changes during these operations.

M12 applies the same invariant to structural operations. `transpose`,
`ctranspose`, and `reshape` copy existing MPFR values at the source object's
precision and preserve the column-major linear order for reshape. They do not
perform numerical rounding, use the current-thread MPFR default, or change
the project default.

M13 applies the invariant to concatenation. For `[A, B, ...]` and
`[A; B; ...]`, the result precision is the maximum stored precision of every
participating `mp` operand, including empty matrices; real double operands do
not increase it. Each source value is copied directly into one uniformly
precise destination, preserving the represented lower-precision value without
reconstructing lost information. Concatenation does not use the current
default, MPFR TLS default, or a precision scope.

## Explicit scalar conversion

`char(x)` formats the immutable value using `x`'s stored precision.  The
canonical decimal is guaranteed to reconstruct the same MPFR value when read
at that precision with `MPFR_RNDN`; it is not a precision-independent exact
serialization.  Changing the current default cannot change existing text.

`double(x)` is an explicit, potentially lossy conversion of the stored value
to IEEE binary64 using `MPFR_RNDN`.  It never converts through decimal text.
The presence of this explicit method does not authorize implicit binary64
fallback in arithmetic or generic numeric functions.

## Mixed precision

M06 establishes the scalar `mp`/`mp` operation rule:

```text
result precision = max(lhs precision, rhs precision)
```

For scalar `mp`/`double` arithmetic, result precision is the stored `mp`
precision.  The binary64 operand is converted directly at that precision, so
the current project default never participates in arithmetic result
selection.  All M06 operations explicitly use `MPFR_RNDN`.  A later milestone
may change these rules only for a strong documented reason, with explicit
tests and migration notes for any user-visible change.
