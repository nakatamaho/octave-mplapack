# Dense matrix inspection

M10 adds a read-only inspection surface for dense real `mp` matrices. The
public `mp` object still contains one private native `MpfrMatrixStorage`
payload; indexing and conversion operate directly on that payload.

## Indexing

Supported forms are `A(i,j)`, `A(:,j)`, `A(i,:)`, `A(I,J)`, scalar linear
indexing `A(k)`, `A(:)`, and the corresponding two-dimensional `end` forms.
Indices are validated as finite, positive, integer-valued, in-bounds numeric
indices. Selection order and repeated indices are preserved. Slices are deep
copies with the source matrix precision, and a `1x1` selection is normalized
to the scalar native payload. General vector linear indexing and logical
indexing remain deferred.

## Conversion and display

`double(A)` creates a builtin real matrix of the same shape. Each element is
converted directly with MPFR round-to-nearest, ties-to-even; no text or
binary64 intermediate is used for the source value. `disp(A)` formats each
element through the canonical scalar MPFR formatter, preserving source
precision and ignoring Octave's `format short`/`format long` settings.

Neither operation changes the project default or current-thread MPFR default.
Matrix `char`, assignment, transpose, concatenation, logical indexing, and
matrix element-wise arithmetic remain outside M10.
