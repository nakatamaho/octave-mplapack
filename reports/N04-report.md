# N04 report — structured symmetric/Hermitian `eig`

## Result

```text
N04 PASS — structured symmetric/Hermitian arbitrary-precision eig complete
```

N04 adds the dense standard eigenproblem for exactly represented real
symmetric and complex Hermitian `mp` matrices. Real input uses MPLAPACK MPFR
`Rsyevd`; complex input uses MPC/MPFR `Cheevd`. The public forms are
`eig(A)`, `[V,D]=eig(A)`, `[V,D]=eig(A,"matrix")`, and
`[V,d]=eig(A,"vector")`.

Eigenvalues and diagonal output are real `mp`. Real symmetric eigenvectors are
real `mp`, and complex Hermitian eigenvectors are complex `mp`. Detection is
exact in the stored MPFR/MPC representation, including zero imaginary
diagonal entries for Hermitian matrices. General and generalized eigenvalue
problems remain explicit N05/N06 deferrals.

## Precision and ownership

The backend queries and allocates `Rsyevd`/`Cheevd` workspaces at the stored
operation precision, enters the corresponding MPFR or MPFR/MPC scope, and
passes only an operation-owned copy to the destructive LAPACK routine. The
precision contract is checked at each backend boundary. No builtin binary64
complex arithmetic or real-to-complex routing is used.

## Gates

```text
G-N04-DETECTION:         PASS
G-N04-REAL-SYMMETRIC:    PASS
G-N04-COMPLEX-HERMITIAN: PASS
G-N04-VECTOR:            PASS
G-N04-MATRIX:            PASS
G-N04-RESIDUAL:          PASS
G-N04-ORTHOGONALITY:     PASS
G-N04-DEGENERATE:        PASS
G-N04-PRECISION:         PASS
G-N04-REGRESSION:        PASS
```

## Regression evidence

```text
native sanitized Rsyevd/Cheevd test: PASS
public structured eig tests: PASS
exact rejection of nonsymmetric/non-Hermitian/generalized inputs: PASS
real residual and orthogonality: PASS
complex residual and orthogonality: PASS
repeated and nearly repeated fixtures: PASS
1024-bit / 2^-700: PASS
2048-bit / 2^-1500: PASS
ambient precision and input immutability: PASS
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex Cgetrf: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
clean package archive extraction and lifecycle: PASS
deterministic source archive: PASS
```

## Scope audit

No numerical backend outside the structured standard eigenproblem was added.
The D01R1 `mplapack-interop` 0.2.1 tag and archive remain unchanged. No
Debian, PPA, Launchpad, registry, binary distribution, or release tag work was
begun.
