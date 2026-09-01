# M09 — Linear solve

# Goal

Implement `x = A \ b` for dense square real systems through MPLAPACK MPFR
LAPACK.

# Scope

Dense square real `A`, one right-hand side, and multiple right-hand sides when
naturally supported without architectural distortion. The expected route is
the appropriate MPLAPACK real MPFR `gesv` routine or equivalent.

# Non-goals

- A replacement Gaussian-elimination implementation in the binding
- Sparse, rectangular least-squares, or complex systems
- Arbitrary LAPACK routine wrappers

# Design constraints

The solver must operate on native MPFR storage without binary64 conversion.
Input mutation or preservation must be deliberate and documented, and singular
status must become a clear Octave-level result or diagnostic.
M06 deliberately leaves scalar `\` unsupported so this milestone defines one
coherent public solve contract through the MPLAPACK MPFR backend.

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
MPLAPACK MPFR LAPACK path with documented status and ownership behavior. This
gate is planned and is not passed by M00.

# Expected commit

`M09: implement MPLAPACK MPFR linear solve`
