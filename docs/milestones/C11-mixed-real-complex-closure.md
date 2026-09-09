# C11 — Mixed Real/Complex API Closure

## Mission

Close the first-generation mixed public surface for real and complex `mp`
values while retaining real result kinds for real-only operations.

## Promotion and operations

Binary `+`, `-`, `.*`, `./`, `*`, and `\` now promote any complex participant
to the MPC path. The result precision is the maximum stored precision of the
participating `mp` values. Real-only operands remain on the existing MPFR
paths, and a complex result is never demoted merely because its imaginary
components are zero. Builtin real and complex doubles are converted directly
from their binary64 components at the operation precision.

## Concatenation

Mixed horizontal and vertical concatenation accepts real and complex `mp`
operands in either order, plus builtin real/complex double operands when an
`mp` operand supplies the arbitrary precision. The result is a single MPC
matrix at the maximum participating `mp` precision. Structural copying uses
operation-owned destination storage and does not consult ambient precision.

## Assignment and structure

Indexed assignment of a complex scalar/matrix or builtin complex value into a
real `mp` matrix promotes the copied result to complex. Assignment into a
complex matrix accepts real `mp` and builtin real RHS values without
demotion. Source values remain unchanged, and a higher-precision RHS widens
the copied result only when the selection is nonempty. Complex reshape was
added alongside the existing transpose, conjugate-transpose, indexing,
display, and component operations.

## Precision and ownership

All mixed arithmetic and structural paths derive `p_op` from stored operands,
allocate destination storage explicitly at that precision, and preserve
ambient MPFR/MPC state. No mixed complex path falls through builtin binary64
complex arithmetic for the numerical result, and no real-only operation is
routed through a complex kernel.

## Gates

`G-C11-PROMOTION`, `G-C11-PRECISION`, `G-C11-ARITHMETIC`, `G-C11-MTIMES`,
`G-C11-MLDIVIDE`, `G-C11-CONCAT`, `G-C11-ASSIGN`, `G-C11-STRUCTURAL`,
`G-C11-BUILTIN-DOUBLE`, `G-C11-NO-DEMOTION`, and
`G-C11-REAL-REGRESSION`: PASS.

## Required QA

Native ASan/UBSan/LSan coverage includes mixed complex concatenation and the
existing real regression wall. Public tests cover mixed precision and kind
promotion, builtin complex participation, Cgemm/Cgesv/Cgelsy mixed paths,
concat in both directions, real-to-complex assignment, structural
interoperability, ambient precision, output lifetime, and no-demotion.
Complete public M01–M23 plus C01–C11 and full native real+complex walls pass.

## Result

C11 PASS. Proceed to mandatory C11L: complex LU via `Cgetrf`.
