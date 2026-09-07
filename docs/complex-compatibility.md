# Complex compatibility and limits

The tested public runtime is GNU Octave 11.1.0 with the dense `mp` class and
the controlled reference `mplapack_mpfr` backend. Supported syntax follows
the forms listed in [`complex-api.md`](complex-api.md).

Mixed operations promote when at least one operand is an `mp` value and any
complex participant selects the MPC implementation. A builtin complex double
may participate in mixed arithmetic, multiplication, solve, concatenation,
and assignment; it is converted into the operation precision. A pair of raw
builtin complex doubles remains an Octave operation and is outside this
package's arbitrary-precision contract.

The following complex operations are intentionally rejected by the package's
compatibility firewall. They must fail cleanly without conversion to a
binary64 result, crash, or recursive dispatch:

- generalized `eig(A,B)` (standard non-Hermitian `eig(A)` is supported by
  N05; structured Hermitian `eig` remains on the N04 `Cheevd` path);
- `sin`, `exp`, `sqrt`, and other unimplemented transcendentals;
- power (`^` and `.^`), ordered comparisons, equality/logical operations,
  sparse conversion, and right division;
- sparse matrices, N-dimensional matrices, growth/deletion assignment, and
  unsupported cell/text matrix forms.

The package does not claim identical error text to builtin Octave. It does
claim stable package-owned rejection behavior for the audited unsupported
surface and no implicit binary64 fallback. Public LU follows real M21 and has
no separate status output; native `Cgetrf INFO` is checked, and singular
partial factors are preserved.

N00 adds arbitrary-precision `norm` for real and complex vectors and dense
matrices. Supported forms and deferred matrix p/options are documented in
[`norm.md`](norm.md); the implementation uses MPFR/MPC-native absolute values,
`Rlange`/`Clange`, `Rnrm2`/`RCnrm2`, and `Rgesvd`/`Cgesvd`.

N01 adds arbitrary-precision `det` and `inv` for dense real and complex
matrices. They use `Rgetrf`/`Rgetri` and `Cgetrf`/`Cgetri`, respectively, with
stored-precision operation scopes, checked workspace queries, exact zero for
singular determinants, and operation-owned destructive copies. N03 completes
the determinant reciprocal-condition output.

N02 adds dense arbitrary-precision `svd` through `Rgesvd`/`Cgesvd`, including
one-output real singular values and full/economy three-output factors. Complex
SVD returns real `S` and native MPC `U`/`V` factors; no binary64 fallback is
used.

N05 adds standard general `eig` through MPFR `Rgeevx` and MPC/MPFR `Cgeevx`.
Real general outputs are represented as complex `mp` so conjugate pairs retain
their imaginary parts. Balance and nobalance forms, right/left residuals, and
the permanent Grcar regression are covered. Generalized eigenproblems remain
deferred to N06.

N03 adds dense arbitrary-precision `rank`, `cond`, and `rcond`. Rank uses
MPFR/MPC singular values and a stored-precision default threshold. The 2-norm
condition path uses those same singular values; 1-norm and infinity-norm
conditions, `rcond`, and the second output of `det` use native
`Rgecon`/`Cgecon` estimators. Frobenius condition numbers are computed from
the singular values. All condition results are real MPFR values, including
for complex inputs, and square-only norm variants reject nonsquare matrices.

N04 adds standard structured `eig` for exactly symmetric real and Hermitian
complex matrices. Real input uses MPFR `Rsyevd`; complex input uses MPC/MPFR
`Cheevd`. Eigenvalues and diagonal output are real `mp`; real eigenvectors are
real `mp`, and complex eigenvectors are complex `mp`. The public path performs
an exact represented symmetry/Hermitian check and rejects general matrices
until N05. Destructive LAPACK calls receive operation-owned copies.

## Lifecycle

The native module is locked while public values or registered native types are
live. Public values remain valid across ordinary clear and package unload/
reload tests. Reinstallation is tested with the same real and complex smoke
operations. The controlled installation uses only the reference MPFR backend;
optimized complex workers are not claimed.
