# Dense matrix concatenation

M13 adds `horzcat` and `vertcat` for the dense real `mp` type, so ordinary
Octave bracket expressions produce one native `mp` value:

```octave
C = [A, B, C2];
D = [A; B; C2];
```

The implementation validates all operands and the complete result shape before
allocating one column-major `MpfrMatrixStorage`.  Scalar operands are treated
as `1x1` values, while dense double operands are converted directly from their
incoming binary64 values.  No broadcasting or numerical arithmetic is used.

## Precision

The result precision is the greatest stored precision of all participating
`mp` operands.  Empty `mp` matrices participate in this maximum even when
they contribute no elements.  A double operand does not increase the result
precision.  Lower-precision `mp` values are copied directly into the result at
the selected precision; this embeds the represented value but does not recover
information that was rounded away in the source.

Concatenation is structural.  It does not call MPLAPACK, enter an MPFR
precision scope, or read or modify `mpbits()` / the current-thread MPFR
default.  Public inputs remain immutable and the result owns independent
storage.

## Supported forms and limitations

Horizontal and vertical concatenation accept arbitrary argument counts and
real `mp` scalars/matrices or real dense double scalars/matrices.  Empty-shape
behavior follows Octave's two-dimensional concatenation rules.  General
`cat(dim, ...)`, N-D values, complex or sparse operands, and indexed assignment
remain outside M13; M14 adds limited value-semantic indexed assignment.
Matrix concatenation never creates an Octave object array
of scalar `mp` wrappers.
