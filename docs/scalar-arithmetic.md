# Scalar arithmetic design

## Scope

M06 implements real scalar `+`, `-`, `.*`, `./`, unary `+`, and unary `-`.
Dense values, broadcasting, comparisons, powers, transcendental functions,
and complex arithmetic are outside M06.

## Octave 11.1 dispatch audit

The installed Octave 11.1 runtime was tested before implementation.  For a
classdef `mp` operand it dispatches `mp + mp`, `mp + double`, and `double + mp`
to `@mp/plus.m`; the corresponding binary method behavior applies to the
other M06 operators.  Built-in operands arrive without automatic promotion:
in particular, `single + mp` reaches the method as `single`, so the binding
can reject it deliberately.  Unary operators require distinct `uplus` and
`uminus` methods.

The external methods in `inst/@mp` are class methods and can replace the
private hidden `payload_` property on a result prototype.  M06 uses this only
after the native bridge has returned a validated internal value.  It avoids
the public constructor, text conversion, and the current default precision.
This classdef behavior is a compatibility-sensitive Octave boundary.

## Supported operators

The public operators are scalar `+`, `-`, `.*`, `./`, unary `+`, and unary
`-`.  The native implementation uses direct `mpfr_add`, `mpfr_sub`,
`mpfr_mul`, `mpfr_div`, and `mpfr_neg` calls.

## Operand types

Binary operations accept two scalar `mp` operands or one scalar `mp` and one
real scalar Octave `double`.  Complex, nonscalar, `single`, integer, logical,
cell, and other operands are rejected.  No scalar expansion or public object
array is created.

## Result precision

For `mp`/`mp`, the result precision is the maximum of the two stored operand
precisions.  For `mp`/`double`, the stored `mp` precision is the result
precision.  The current project default never participates in arithmetic
precision selection and is not modified by an operation.

## Mixed `mp` precision

Operands retain their original values and precisions.  A new independent
native result is allocated at `max(lhs precision, rhs precision)` before the
operation is evaluated.

## Double promotion

A binary64 operand is converted directly with `mpfr_set_d` into a temporary
RAII value at the `mp` operand precision.  The conversion does not use decimal
text, the public `mp` constructor, or the current default.  It deliberately
does not raise operation precision to 53 bits.

## Rounding mode

All M06 native operations explicitly use `MPFR_RNDN` (round to nearest, ties
to even).  The MPFR global default rounding mode is neither read as semantics
nor modified.

## Immutability

Octave-facing payloads remain immutable.  Binary operations and unary minus
return newly owned native storage.  Unary plus may share the existing public
value safely because no operation mutates its payload.

## Special values

NaN, infinities, and signed zeros follow the results produced by the direct
MPFR operation under `MPFR_RNDN`.  M06 adds no alternative exception or
normalization policy.

## Division by zero

Scalar `./` follows MPFR semantics.  Signed nonzero values divided by signed
zero produce signed infinities, while zero divided by zero produces NaN.  It
does not raise a project-specific divide-by-zero exception.

## Unsupported matrix operators

`*`, `/`, and `\` remain unsupported.  M06 does not implement scalar aliases
for those operators because their public dispatch is reserved for unified
future matrix semantics.  Powers and comparisons also remain unsupported and
must not fall back through `double(mp)`.

## Relationship to M07/M08/M09

M07 owns native dense storage, matrix constructors, and shape.  M08 owns `*`
through MPLAPACK MPFR GEMM.  M09 owns
`\` through MPLAPACK MPFR LAPACK.  The scalar storage operations introduced
here are reusable primitives but do not constrain dense storage to arrays of
scalar wrappers.
