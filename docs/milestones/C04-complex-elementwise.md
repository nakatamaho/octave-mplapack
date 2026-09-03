# C04 — Complex element-wise arithmetic

## Mission

Add complex `+`, `-`, `.*`, `./`, unary `+`, and unary `-` with the accepted
real M11 singleton-expansion model.

## Semantics

- real/real results remain real;
- any complex operand produces a complex result;
- the operation precision is the maximum precision of participating `mp`
  operands;
- builtin real and complex doubles are converted directly at the operation
  precision;
- special values and division by zero are deterministic and non-crashing.

The complex kernel uses direct MPC operations under an operation-local precision
scope. Real-only operands remain on the existing MPFR path.

## Gate

`G-C04-SCALAR`, `G-C04-MATRIX`, `G-C04-MIXED-KIND`, `G-C04-MIXED-PRECISION`,
`G-C04-BROADCAST`, `G-C04-SPECIAL`, and `G-C04-REAL-REGRESSION`.

## Required QA

Native ASan/UBSan/LSan coverage and public tests cover 128/512/1024/2048-bit
precision, ambient precision, scalar and matrix broadcast, builtin complex
mixing, special values, empty shapes, and the complete M01-M23 real wall.

## Expected commit

`C04: add complex element-wise arithmetic`
