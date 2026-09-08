# T07 report — exact MP serialization

## Result

`T07 PASS — EXACT MP SERIALIZATION CLOSED`

T07 started from T06 commit
`e6a4daba2f47bdfc85eae08473db418d6348b729` on
`topic/t00-t14-continuation` and was tested with GNU Octave 11.1.0 against
the installed MPLAPACK MPFR 3.0.1 stack.

## Implementation

The `mp` public type uses the Octave legacy user-class hook path required by
Octave 11.1.  The normal native payload remains private and is never made
public.  `saveobj` replaces it with a plain versioned schema struct before
Octave writes the object; after loading, the bridge validates and lazily
reconstructs the native MPFR/MPC payload.  `loadobj` also performs the same
validated reconstruction for direct hook use and restores the ambient
precision with an unwind-protected scope.

The schema is `octave-mplapack-mp`, version 1.  It records kind, two-dimensional
shape, uniform stored precision, and column-major canonical element text.
Finite canonical text is generated from MPFR at the element's stored
precision; real and imaginary complex components are encoded independently.
Special values and signed zeros are retained.  The decoder validates schema,
kind, dimensions, element count, precision range, and every text token.  It
does not execute serialized data and contains no binary64 fallback.

The native implementation is in `src/mp_native_serialization.cc/.h`; the
Octave bridge schema/export/import commands are in `src/octave_bridge.cc`.

## Focused evidence

`test/t07_serialization.tst` passed:

- binary round trips at 128, 512, 1024, and 2048 bits;
- `2^-700` and `2^-1500` construction canaries;
- real and complex values, signed zero, Inf, NaN, and independent complex
  components;
- rectangular, row/column-preserving, and empty real/complex shapes;
- text-format round trips;
- direct `saveobj`/`loadobj` use;
- malformed future-version, zero-precision, and element-count states;
- ambient-precision restoration after loading.

An independent second Octave process loaded a binary file produced by the
first process and recovered a 2048-bit, 2x2 `mp` matrix while its ambient
precision remained 128 bits.

## Save-format audit

Octave 11.1 does not invoke `saveobj` for classdef objects and attempts to
serialize them as structs.  The public representation was therefore moved to
the legacy `@mp` user-class form, preserving the existing private-payload
behavior through the package `properties`/`subsref` boundary.  This is an
Octave persistence compatibility repair, not a numerical algorithm change.
Binary and text formats are supported and tested; package availability is
required when loading the class and native payload.

## Required real regression wall

`test/run_tests.m` passed M00–M23, C00–C12 including C11L, N00–N08,
S00–S08, and T00–T07.

## Contract audit

The schema is text-based and independent of host endianness, word size, MPFR
limb layout, and C++ ABI.  No raw `mpfr_t` memory, pointer identity, builtin
binary64 arithmetic, real/complex demotion, or existing real-only routing was
introduced.
