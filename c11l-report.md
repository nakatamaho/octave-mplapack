# C11L RESULT

Repository: `octave-mplapack`  
Branch: `topic/complex-c00-c12`  
Starting commit: `ef584c0` (C11 report/status tip)  
Final implementation commit: `3bad050af108a6ca8739c97b91120e3053800ecc`

## Dependency identity

- gmpfrxx_mkII: `32a7fb797202cdf92312ed9d133f96fdbcda590a` (`main`);
- MPLAPACK: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`
  (`topic/octave-mplapack-complex-mpfr-scope`);
- pkg-config: `mplapack_mpfr 3.0.1`;
- runtime SONAME: `libmplapack_mpfr.so.3`.

## Scope

- implemented mandatory complex dense LU through MPC `Cgetrf`;
- implemented packed one-output, two-output `A=L*U`, three-output `P*A=L*U`,
  and vector `A(p,:)=L*U` forms;
- implemented square, tall, wide, empty, and singular factor behavior;
- preserved real-only `lu` on the existing MPFR `Rgetrf` path;
- preserved builtin real structural permutation outputs and public `mp`
  value semantics.

## Gates

`G-C11L-UPSTREAM`, `G-C11L-PACKED`, `G-C11L-TWO-OUTPUT`,
`G-C11L-MATRIX-P`, `G-C11L-VECTOR-P`, `G-C11L-RECTANGULAR`,
`G-C11L-SINGULAR`, `G-C11L-PIVOT-PRECISION`, `G-C11L-PRECISION`,
`G-C11L-IMMUTABILITY`, `G-C11L-LIFETIME`, and
`G-C11L-REAL-RGETRF-PARITY`: PASS.

## QA

- native complex `Cgetrf` sanitizer gate: PASS;
- 1024/2048-bit precision tails and 512/1024-bit pivot-order canaries: PASS;
- ambient precision, immutability, lifetime, empty shapes, rectangular
  factors, and singular partial factors: PASS;
- full native real+complex sanitizer wall: PASS;
- complete public M01–M23 plus C01–C11L wall: PASS.

## Upstream fixes

MPLAPACK commit `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d` remains the only
upstream fix required by the complex implementation. It installs and exposes
`mplapack_mpfr_precision.h` through the public MPFR interfaces. No new
gmpfrxx_mkII or MPLAPACK fix was required by C11L.

## Result

`C11L PASS`
