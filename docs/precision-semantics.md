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
to each new native scalar.  Normal construction does not use MPFR's mutable
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

The project does not call `mpfr_set_default_prec` to represent this state.
The MPLAPACK scalar wrapper linked since M02 performs a one-time initialization
of its own MPFR thread-local environment (512 bits when its optional
environment overrides are absent) and contains internal save/restore routines,
so `mpfr_set_default_prec` remains a backend symbol in the module.  This is not
read as the project default.  Standalone and Octave tests verify that M04
setters and conversions leave MPFR's default unchanged, and that explicit-
precision construction does not track later project-default changes.

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

The initial operation rule is:

```text
result precision = max(lhs precision, rhs precision)
```

A later milestone may change this only for a strong documented reason, with
explicit tests and migration notes for any user-visible change.
