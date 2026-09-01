# M08 — Matrix multiplication

# Goal

Implement `C = A * B` using MPLAPACK's MPFR real GEMM path.

# Scope

Dense real `mp` matrix multiplication, dimension validation, mixed precision,
and backend-path evidence.

# Non-goals

- High-level Octave-loop matrix multiplication
- Silent conversion to double
- Other BLAS operations or numerical backends

# Design constraints

Use the intended MPLAPACK MPFR GEMM routine directly on native storage. The
result follows documented mixed-precision semantics, and tests must distinguish
the backend path from an ordinary double implementation.
M06 deliberately leaves even scalar `*` unsupported so `mtimes` receives one
coherent scalar-and-matrix public contract here.

# Implementation tasks

- Bind the appropriate MPLAPACK MPFR real GEMM entry point privately.
- Validate dimensions and arrange leading dimensions correctly.
- Allocate the result at `max(lhs precision, rhs precision)`.
- Add reproducible evidence that the intended backend routine executes.

# Required tests

At minimum run:

```octave
A = mp({"1", "2"; "3", "4"});
B = mp({"5", "6"; "7", "8"});
C = A * B;
```

Also cover exact small matrices, high-precision nontrivial values, dimension
errors, mixed precision, input preservation, and evidence that the MPLAPACK
MPFR GEMM routine is exercised.

# Gate

`G08` passes when `mtimes` is correct at multiprecision, invokes MPLAPACK MPFR
GEMM, and passes all dimensional and mixed-precision tests. This gate is
planned and is not passed by M00.

# Expected commit

`M08: implement MPLAPACK MPFR matrix multiplication`
