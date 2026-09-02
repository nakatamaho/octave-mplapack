# Goal

Implement dense real `mp` horizontal and vertical concatenation through the
native immutable matrix representation.

# Scope

Support `[A, B, ...]`, `[A; B; ...]`, direct `horzcat`/`vertcat`, mixed real
double operands, mixed stored precisions, scalar operands, and valid empty
two-dimensional shapes.

# Non-goals

- Indexed assignment or general `cat(dim, ...)`
- N-D, sparse, complex, or object-array concatenation
- New arithmetic, transpose, reshape, or MPLAPACK calls

# Design constraints

Validate the complete argument list and result dimensions before allocation.
Choose `p_cat` as the maximum precision of every `mp` operand, including empty
operands, and copy values directly into one column-major destination at that
precision.  Do not broadcast, mutate inputs, use a precision scope, or change
the current precision state.

# Implementation tasks

- Add a reusable native concatenation descriptor and horizontal/vertical copy
  kernel.
- Add public `horzcat` and `vertcat` dispatch for arbitrary operand counts.
- Preserve scalar normalization, empty shapes, binary64 semantics, and deep
  result ownership.
- Add native, public, differential, precision, lifecycle, and sanitizer QA.
- Update architecture, precision, package, and local-CI documentation.

# Required tests

Test ordinary and three-way concatenation, scalar/row/column cases, empty
shapes, mixed `mp` precision, 1024/2048-bit tails, mixed double `0.1` and
`0.125`, operand immutability, nested concatenation, and M00–M12 regressions.
Compare supported shape and error behavior with builtin Octave matrices.

# Gate

M13 passes only when the public bracket syntax returns one `mp` value and the
concatenation, shape, precision, binary64, immutability, interoperability,
robustness, installed-package, and M00–M12 regression gates pass.

# Expected commit

`M13: add dense mp matrix concatenation`
