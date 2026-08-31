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

## Decimal-digit conversion

`mpdigits(n)` must convert decimal digits to a sufficiently large MPFR bit
precision. The conversion must round upward and must not truncate
`n * log2(10)`. M00 defines no guard-bit policy. If a later milestone adds
guard bits, it must document how many are used, why they are used, and whether
`mpbits()` reports storage precision or requested user precision.

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

## Mixed precision

The initial operation rule is:

```text
result precision = max(lhs precision, rhs precision)
```

A later milestone may change this only for a strong documented reason, with
explicit tests and migration notes for any user-visible change.
