# M09 — Linear solve

# Goal

Implement `x = A \ b` for dense square real systems through MPLAPACK MPFR
LAPACK.

# Scope

Dense square real `A`, one right-hand side, and multiple right-hand sides are
supported through the MPLAPACK real MPFR `Rgesv` routine.

# Non-goals

- A replacement Gaussian-elimination implementation in the binding
- Sparse, rectangular least-squares, or complex systems
- Arbitrary LAPACK routine wrappers

# Design constraints

The solver must operate on native MPFR storage without binary64 conversion.
Input mutation or preservation must be deliberate and documented, and singular
status must become a clear Octave-level result or diagnostic.
Scalar left division uses the existing native MPFR arithmetic path, while
matrix solves use operation-owned copies and the MPLAPACK MPFR backend.

M07 supplies deep native copies with independent contiguous buffers, checked
`mplapackint` dimensions, column-major layout, and verified leading
dimensions.  M09 must mutate only those operation-owned work copies so public
inputs remain immutable.

# Implementation tasks

- Bind the selected MPLAPACK MPFR solve routine privately.
- Validate square matrices and right-hand-side dimensions.
- Manage solver work copies and pivot storage safely.
- Translate singular and argument statuses accurately.
- Record evidence that the backend solver executes.

# Required tests

Cover exact small systems, high-precision systems, multiple precision settings,
dimension errors, singular matrices, input preservation unless documented
otherwise, optional multiple right-hand sides, and backend invocation evidence.

# Gate

`G09` passes when `mldivide` correctly solves the supported systems through the
MPLAPACK MPFR LAPACK path with documented status and ownership behavior.

# Expected commit

`M09: implement MPLAPACK MPFR linear solve`
