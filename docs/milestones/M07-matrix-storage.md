# M07 — Native dense matrix storage

# Goal

Implement and harden dense real matrix storage before MPLAPACK BLAS/LAPACK
kernels are used.

# Scope

Native dense storage, numeric-matrix and textual-cell matrix constructors,
empty matrix representation, matrix shape, column-major ordering, leading
dimensions, ownership, copy/move semantics, indexing firewalls, and direct
type compatibility with future MPLAPACK array arguments.

# Non-goals

- GEMM or GESV itself
- Matrix element access or assignment
- Matrix arithmetic, conversion, or final display
- Transpose or reshape
- Sparse or complex matrices

# Design constraints

Prefer a layout that avoids unnecessary transposition or repacking for
MPLAPACK. Every MPFR element has deterministic lifetime management, matrix
dimensions are explicit, and copies and resizing cannot leak or double-free.
Dense matrices must not be Octave arrays or cells of independent scalar `mp`
wrapper objects.

M07 extends the operand-derived precision and immutable-result infrastructure
proven for scalars in M06 to one native dense representation.  It owns matrix
element-wise operations and scalar expansion decisions; M06 introduces none.

# Implementation tasks

- Select and document storage order, indexing, and leading dimensions.
- Implement numeric matrix, textual cell matrix, and deliberate empty matrix
  construction on the selected native representation.
- Harden allocation, copy/move, destruction, and checked dimension behavior.
- Reject indexing and indexed assignment until their public semantics exist.
- Prove direct compatibility with intended MPLAPACK array arguments.

# Required tests

Test rectangular, square, scalar-normalized, and empty dimensions; internal
layout access; copies; moves; repeated allocation and destruction; public
indexing firewalls; and MPLAPACK-compatible layout assumptions under memory
QA.

# Gate

`G07` passes when dense real storage is documented, memory-safe, dimensionally
correct, directly compatible with MPLAPACK MPFR dense pointers, and protected
from premature indexing or matrix operators.  This gate passed on 2026-09-01.

# Expected commit

`M07: add native dense MPFR matrix storage`
