# Public API backend map

This map connects the user-facing Octave API to its native bridge and the
tested numerical backend. It is a DOC00 handoff artifact and must be kept in
step with [`docs/public-api-inventory.md`](public-api-inventory.md) and the
compatibility documents. `p_op` means the single operation precision selected
from the stored operands; all destructive backend calls use operation-owned
copies.

| Public API | Native entry | Real path | Complex path | Copy/precision rule |
|---|---|---|---|---|
| `mtimes` | `__mplapack_core__("mtimes",...)` | `Rgemm` | `Cgemm` | uniform `p_op`; backend buffers are owned by the operation |
| `mldivide` | `__mplapack_core__("mldivide",...)` | `Rgesv`/`Rgelss` | `Cgesv`/`Cgelsy` | factorization input is copied at `p_op` |
| `mrdivide` | `__mplapack_core__("mrdivide",...)` | transpose solve | conjugate-transpose solve | transpose/promote once at `p_op` |
| `chol` | `__mplapack_core__("chol",...)` | `Rpotrf` | `Cpotrf` | selected triangle is copied before destructive call |
| `qr` | `__mplapack_core__("qr",...)` | `Rgeqrf`/`Rorgqr` | `Cgeqrf`/`Cungqr` | reflector and workspace buffers own `p_op` |
| pivoted `qr` | `__mplapack_core__("qr_pivoted",...)` | `Rgeqp3`/`Rorgqr` | `Cgeqp3`/`Cungqr` | permutation is a structural builtin output |
| `lu` | `__mplapack_core__("lu",...)` | `Rgetrf` | `Cgetrf` | public input is never mutated; partial singular factors are preserved |
| `norm` | `__mplapack_core__("norm",...)` | `Rlange`/`Rnrm2`/`Rgesvd` | `Clange`/`RCnrm2`/`Cgesvd` | singular-value-only calls use an owned copy |
| `svd` | `__mplapack_core__("svd",...)` | `Rgesvd` | `Cgesvd` | `U,S,V` are returned as owned uniform-precision values |
| `det`/`inv` | `__mplapack_core__("det",...)`, `("inv",...)` | `Rgetrf`/`Rgetri` | `Cgetrf`/`Cgetri` | factor and inverse buffers are operation-owned |
| `rank` | `__mplapack_core__("rank",...)` | MPFR singular values | MPC singular values | stored-precision default tolerance |
| `cond`/`rcond` | `__mplapack_core__("cond",...)` | singular values/`Rgecon` | singular values/`Cgecon` | estimates are native real MPFR results |
| structured `eig` | `__mplapack_core__("eig",...)` | `Rsyevd` | `Cheevd` | exact represented symmetry/Hermiticity selects path |
| general `eig` | `__mplapack_core__("eig",...)` | `Rgeevx` | `Cgeevx` | balance mode and left vectors are native |
| generalized `eig` | `__mplapack_core__("geig",...)` | `Rsygvd`/`Rggev` | `Chegvd`/`Cggev` | definite or QZ path; alpha/beta retained |
| `hess` | `__mplapack_core__("hess",...)` | `GEHRD`/`ORGHR` | `GEHRD`/`UNGHR` | Householder data and factors own `p_op` |
| `schur` | `__mplapack_core__("schur",...)` | `GEES` | `GEES` | Schur vectors are non-unique; source is copied |
| `qz` | `__mplapack_core__("qz",...)` | `GGES` | `GGES` | generalized factors use owned A/B buffers |
| `expm`/`logm`/`sqrtm` | package matrix-function bridge | MPFR matrix algorithm | MPC matrix algorithm | guarded working precision is function-owned |
| `polyval`/`polyvalm` | package polynomial helpers | MPFR Horner | MPC Horner | coefficients and argument select one `p_op` |
| `roots`/`compan` | package polynomial bridge | native eig | native eig | clustered roots are sensitivity-limited |
| `interp1`/`interp2` | `mp_interp_*` helpers | MPFR interpolation | MPC interpolation | grids, queries, and coefficients retain source precision |
| `fzero`/`fsolve` | `mp_solver_*` helpers | MPFR safeguarded solver | deferred | callback values must be `mp`; tolerances are p-aware |
| `integral`/`quadgk` | `mp_quad_*` helpers | MPFR tanh-sinh | MPC scalar callback | nodes, weights, and error estimates are `mp` |
| `fminbnd`/`fminsearch` | `mp_opt_*` helpers | MPFR golden/Nelder--Mead | deferred | objective and stopping values are `mp` |
| `mprand*`/`mprng` | `mp_rng_*` helpers | direct p-bit MPFR | not a complex API | state is explicit and serializable |
| `saveobj`/`loadobj` | serialization bridge | MPFR text schema | MPC component text schema | stored precision, shape, and special values preserved |
| graphics wrappers | `mp_graphics_args` | final `double` boundary | final `double` boundary | the only documented numerical conversion boundary |

## Value and lifetime invariants

`mp` storage is a native RAII payload owned by the Octave value. Public values
are not passed as writable LAPACK buffers. Each bridge establishes the
matching current-thread MPFR/MPC context for the call, constructs operation
temporaries at `p_op`, and restores that context on return or exception.
New worker threads do not inherit a parent thread's precision automatically;
worker entry must establish its own scope when a worker exists.

## Package-owned algorithms

Polynomial, interpolation, solver, quadrature, optimization, statistics,
sequence, and graphics-adaptation helpers are package-owned code. They must
use MPFR/MPC values directly. The graphics helper is explicitly different:
it converts only final display data to builtin `double`, after numerical
calculation has completed.
