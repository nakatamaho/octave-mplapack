# Exact `mp` serialization

T07 provides versioned persistence for real and complex `mp` values through
Octave's `saveobj`/`loadobj` hooks and the native payload boundary.

The schema is `octave-mplapack-mp`, version `1`, with these fields:

```text
schema
version
kind = real-scalar | complex-scalar | real-matrix | complex-matrix
rows
columns
precision_bits
elements = column-major cell array of canonical text
```

Each finite element is emitted by the native MPFR/MPC storage at its stored
precision.  Zero sign, infinity, NaN classification, and the real and
imaginary components of complex values are encoded independently.  The text
encoding is independent of MPFR limb layout, host endianness, word size, and
C++ ABI; no pointers, raw `mpfr_t` bytes, `double(mp(...))`, or `eval` are
used.  NaN payload bits are not a public contract, but NaN classification and
component sign behavior are preserved by the supported MPFR/MPC encoding.

The normal user workflow is:

```octave
pkg load mplapack
mpbits (1024);
A = mp ({'1.234567890123456789', '-0'; 'Inf', 'NaN'});
save ('result.mat', 'A');
clear A;
load ('result.mat');
```

Binary and text save formats are tested.  The package must be loaded before
loading an `mp` file so the `mp` methods and native type are available.  A
loaded legacy user-class object carries only the validated plain schema until
the native bridge first consumes it; the bridge then reconstructs the exact
MPFR/MPC payload and retains its recorded precision.

Malformed schema versions, dimensions, element counts, precision values, and
element text are rejected before native reconstruction.  Future schema
versions are rejected rather than guessed.
