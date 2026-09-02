# Dense matrix indexed assignment

M14 adds limited in-bounds parenthesis assignment for dense real `mp` values:

```octave
A(i,j) = x;
A(:,j) = v;
A(i,:) = v;
A(I,J) = B;
A(k) = x;
A(:) = scalar_or_rhs;
```

Assignment has value semantics.  `mp` payloads are immutable, so each
successful assignment validates its indices and right-hand side, deep-copies
the complete left-hand side, applies the updates to the copy, and returns a
new public `mp` value.  Consequently an alias remains unchanged:

```octave
B = A;
B(1,1) = mp ("9");
```

does not modify `A`.

## Precision

`MpfrMatrixStorage` remains uniformly precisioned.  For an `mp` left-hand
side and `mp` right-hand side, the result precision is the maximum of their
stored precisions.  A builtin double right-hand side leaves the left-hand
side precision unchanged.  Higher-precision right-hand sides therefore widen
the complete copied result; lower-precision values are embedded exactly as
already represented and never recover discarded source information.  The
current `mpbits()` value and current-thread MPFR default do not participate.

Copies and insertions use direct MPFR operations (`mpfr_set` and
`mpfr_set_d`), preserving incoming binary64 semantics for double values.  No
MPLAPACK routine or precision scope is used.

## Supported and deferred behavior

Indices use the M10 finite positive integer, colon, range, and `end` rules.
Scalar right-hand sides expand over a selected region.  Non-scalar right-hand
sides must follow the verified Octave shape rules; vector orientation is
accepted for row/column selections.  All successful operations preserve the
left-hand-side shape and column-major ordering.

M14 is intentionally in-bounds only.  Matrix growth, deletion with an empty
right-hand side, logical assignment, general vector linear assignment,
complex/sparse/N-D assignment, and chained/cell/field assignment remain
unsupported and fail explicitly.
