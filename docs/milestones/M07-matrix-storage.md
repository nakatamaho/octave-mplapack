# M07 — Matrix storage hardening

# Goal

Implement and harden dense real matrix storage before MPLAPACK BLAS/LAPACK
kernels are used.

# Scope

Native dense storage, numeric-matrix and textual-cell matrix constructors,
empty matrix representation, matrix shape, row/column ordering, leading
dimensions, indexing, ownership, copy semantics, resize policy, transposition,
and interaction with MPLAPACK array arguments.

# Non-goals

- GEMM or GESV itself
- Full `subsref` and `subsasgn` unless required by the M10 workflow
- Sparse or complex matrices

# Design constraints

Prefer a layout that avoids unnecessary transposition or repacking for
MPLAPACK. Every MPFR element has deterministic lifetime management, matrix
dimensions are explicit, and copies and resizing cannot leak or double-free.
Dense matrices must not be Octave arrays or cells of independent scalar `mp`
wrapper objects.

# Implementation tasks

- Select and document storage order, indexing, and leading dimensions.
- Implement numeric matrix, textual cell matrix, and deliberate empty matrix
  construction on the selected native representation.
- Harden allocation, copy/move, destruction, and resize behavior.
- Define transpose and conjugate-transpose behavior for real matrices.
- Prove direct compatibility with intended MPLAPACK array arguments.

# Required tests

Test rectangular, square, scalar, and empty dimensions; indexing used
internally; copies; moves if present; transpose; repeated allocation and
destruction; and MPLAPACK-compatible layout assumptions under memory QA.

# Gate

`G07` passes when dense real storage is documented, memory-safe, dimensionally
correct, and ready for direct MPLAPACK kernels. This gate is planned and is not
passed by M00.

# Expected commit

`M07: harden dense real matrix storage`
