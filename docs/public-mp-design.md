# Public `mp` design

## Purpose

M03 exposes the immutable M02 native scalar through a normal GNU Octave
class.  It deliberately establishes only scalar construction and `1 x 1`
shape.  Dense storage, matrix construction, indexing, conversion, precision
control, and arithmetic remain later milestones.

## Octave 11.1 class audit

The selected mechanism is an Octave 11.1 `classdef` value class stored in
`inst/@mp/mp.m`.  Octave 11.1 supports class definitions in `@` directories,
private and hidden properties, value-class copy semantics, ordinary method
dispatch, and explicit `horzcat`/`vertcat` methods.  These capabilities support
the public operators while allowing the early scalar milestones to reject
object-array concatenation before native dense storage was introduced in M07.

The installed extension headers provide `octave_value::is_classdef_object()`,
`octave_value::class_name()`, `octave_value::classdef_object_value()`, and
`octave_classdef::get_property()`.  The private native bridge can therefore
verify a scalar `mp` object and retrieve its private payload without exposing
a public accessor.  The compatibility-sensitive header is
`octave/ov-classdef.h`; this use is localized to the bridge and targets Octave
11.1.

An old-style `class(struct, "mp")` wrapper was not selected because its
backing fields do not provide the same property-level encapsulation.  A
`handle` subclass was also rejected: public values are immutable value
objects, and M02 already provides safe reference-counted ownership of the
native representation.

## Public wrapper

The public class name is `mp`.  Each object contains one private, hidden
property holding either the canonical `mplapack_mpfr_scalar_internal` value or,
from M07, one `mplapack_mpfr_matrix_internal` value.  Users receive
neither a raw pointer nor an integer handle, and ordinary property access is
denied.  The native bridge performs checked class, shape, property, and native
type validation for internal QA.

The class is a value class.  Ordinary assignment and `mp(existing_mp)` may
share the immutable Octave and native representations.  This is safe because
M02 payloads cannot be mutated at the Octave boundary; explicit native clones
remain available for lifecycle QA.

The private property directly retains the DLD-aware M02 value, so public
assignment, cells, structs, function passage, ordinary clear, and interpreter
shutdown preserve the same module-lifetime guarantees.  Installed-package QA
keeps a public object alive across `pkg unload`, reloads the package, verifies
the payload, and also destroys a public object while the package is unloaded.

## Construction and precision

The production native bridge has separate text and binary64 construction
paths.  Text reaches `mpfr_set_str` in base 10 directly.  A `double` reaches
`mpfr_set_d` directly and is never formatted as decimal text.  Both paths use
the explicit round-to-nearest mode `MPFR_RNDN`, so constructor semantics do not
depend on the mutable MPFR process default rounding mode.

M03 established the project-owned default precision component at 128 bits.
M04 changes its fresh-session initial value to 512 bits and exposes the same
component through `mpbits` and `mpdigits`.  Every new native scalar receives
the current bit precision explicitly; changing the default never mutates an
existing value and never changes MPFR's process-global default.

The component is process-local and uses atomic access, not thread-local
precision policy.  Its state survives ordinary clear and package unload/reload
within one Octave process, while a new process starts at 512 bits.

## Encapsulation and display

The property is private and hidden.  M05 `char` returns a canonical decimal
representation produced directly from the native MPFR value, and `disp` uses
the same text without revealing the property or internal type.  Explicit
`double` conversion calls MPFR's binary64 conversion directly.  Internal test
commands may inspect precision, exact equality, signed zero, infinity, and NaN
after checked extraction of the private payload; they are not listed in
`INDEX`.

## Scalar and matrix boundary

M03 objects always have scalar payloads and report `1 x 1`.  M07 deliberately
lifts the numeric-array, text-cell, and empty-matrix constructor firewalls.
The classdef wrapper remains one object; public shape methods query the private
native payload rather than relying on a classdef object array.

Public dense `mp` matrices are not represented as Octave arrays or cells of
independent scalar `mp` wrapper objects.  M07 provides one uniform-precision,
column-major, contiguous native payload and shape-preserving empty matrices.
All `1 x 1` input normalizes to the established scalar payload.  Concatenation
and cell-of-`mp` assembly remain firewalls, as do indexing and indexed
assignment.

## Special values

Binary64 positive and negative infinity, NaN, and signed zero are preserved
by direct MPFR construction.  The decimal text syntax is locale-independent,
uses `.` as the decimal point, and is passed to the backend in base 10.  Text
special values `Inf`, `-Inf`, and `NaN` are accepted by the installed backend
parser and covered by tests.  Empty text, malformed decimals, and comma decimal
separators are rejected.

## Known limitations

- Public precision applies to subsequent construction only; per-object public
  precision mutation is not provided.
- Matrix indexing, conversion, arithmetic, transpose, multiplication, and
  linear solve are not implemented in M07.
- Comparisons remain unimplemented.
