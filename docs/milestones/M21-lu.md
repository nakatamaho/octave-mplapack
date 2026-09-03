# Goal

Add dense real arbitrary-precision LU factorization with MPLAPACK MPFR
`Rgetrf`, including Octave-compatible packed, two-output, permutation-matrix,
and permutation-vector forms for rectangular and singular matrices.

# Scope

M21 adds `lu(A)`, `[L,U]=lu(A)`, `[L,U,P]=lu(A)`, and
`[L,U,p]=lu(A,"vector")` for dense real `mp` scalars and two-dimensional
matrices.  It preserves the stored operand precision and existing M00-M20
numerical paths.

# Non-goals

Sparse LU/UMFPACK interfaces, complex LU, complete or threshold pivoting,
`luupdate`, determinant/inverse/rank/condition APIs, and triangular solve
optimizations are deferred.

# Design constraints

`Rgetrf` is the production backend and receives only an operation-owned,
column-major MPFR copy.  `IPIV` is replayed into a final 1-based row
permutation; it is never exposed directly as `p`.  One operation uses one
`p_op = precision(A)` under `MplapackMpfrPrecisionScope`, and all factors and
structural values are independent native storage.

# Implementation tasks

Audit the installed `Rgetrf` signature, pinned call chain, IPIV and INFO
semantics, and runtime linkage.  Add the native factor bridge, public
`@mp/lu` dispatch, packed/canonical factor extraction, permutation outputs,
precision probes, and installed-package QA.

# Required tests

Run the installed Rgetrf probe and native sanitized LU tests.  Exercise square,
tall, wide, multi-pivot, singular, scalar, and empty inputs; all output modes;
1024/2048-bit tails; precision-dependent and high-ambient pivot canaries;
immutability; reconstruction (`P*A=L*U`, `A(p,:)=L*U`, `A=L*U`); interoperability;
package lifecycle; and the complete M00-M20 regression suite.

# Gate

M21 passes only when the upstream, packed, two-output, three-output, vector,
pivot-precision, precision, singular, Octave-compatibility, immutability,
reconstruction, interoperability, and robustness gates all pass.  The final
root-level `m21-report.md` records the evidence and exact gate result.

# Expected commit

Prefer separate reviewable commits for the Rgetrf audit/probe, native bridge,
public API, and QA/documentation.  Do not modify MPLAPACK or begin M22.
