# N05 report — general standard `eig`

## Result

```text
N05 PASS — general standard arbitrary-precision eig complete
```

N05 adds dense general standard eigenproblems for real nonsymmetric and
complex non-Hermitian `mp` matrices. Real input uses MPLAPACK `Rgeevx`; complex
input uses `Cgeevx`. Exactly represented symmetric/Hermitian inputs continue
to use the N04 `Rsyevd`/`Cheevd` structured path.

The public API supports eigenvalue-only, matrix, vector, balance, nobalance,
and three-output right/diagonal/left forms. Real general outputs are complex
`mp`, including real eigenvalues, so LAPACK conjugate pairs are not narrowed
to a real or binary64 representation. Left vectors satisfy `W'*A = D*W'`.

## Precision and ownership

Workspace queries, `INFO`, precision scopes, and all MPFR/MPC work arrays are
checked at the stored input precision. Destructive driver calls receive
operation-owned copies. No real input is routed through a complex kernel and
no builtin binary64 complex fallback exists.

## Targeted evidence

```text
tools/check-format.sh: PASS
native Rgeevx/Cgeevx sanitizer test: PASS
public real/complex general eig tests: PASS
balance/nobalance and Grcar tests: PASS
right/left residuals: PASS
near-defective and badly scaled fixtures: PASS
1024-bit / 2^-700 and 2048-bit / 2^-1500: PASS
ambient precision and input immutability: PASS
```

## Gates

```text
G-N05-BACKEND:             PASS — Rgeevx/Cgeevx native dispatch
G-N05-REAL-GENERAL:       PASS — real nonsymmetric input remains on Rgeevx
G-N05-COMPLEX-GENERAL:    PASS — complex non-Hermitian input uses Cgeevx
G-N05-BALANCE:            PASS — explicit balance path and Grcar residual
G-N05-NOBALANCE:          PASS — explicit nobalance path and Grcar residual
G-N05-RIGHT-EIGENVECTORS: PASS — A*V = V*D
G-N05-LEFT-EIGENVECTORS:  PASS — W'*A = D*W'
G-N05-GRCAR:              PASS — default/balance equivalence and matching residuals
G-N05-NEAR-DEFECTIVE:     PASS — near-Jordan, nearly repeated, badly scaled
G-N05-PRECISION:          PASS — stored precision, ambient precision, 1024/2048-bit
G-N05-REGRESSION:         PASS — complete local CI and required regression wall
```

## Complete regression evidence

```text
tools/check-tree.sh: PASS
tools/check-format.sh: PASS
native Rgeevx/Cgeevx sanitizer test: PASS
public N04/N05 eig tests: PASS
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex Cgetrf: PASS
1024-bit / 2^-700 canary: PASS
2048-bit / 2^-1500 canary: PASS
low/high ambient precision and scope restoration: PASS
operation-owned input and native lifetime tests: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
clean archive extraction build: PASS
isolated package lifecycle and reinstall: PASS
deterministic source archive contents: PASS
full tools/local-ci.sh: PASS (exit code 0)
```

The N05 implementation, report, status, and gate updates are committed and
pushed on `topic/d01r1-mplapack-interop`. The D01R1 `mplapack-interop` 0.2.1
tag and archive remain unchanged. No Debian, PPA, Launchpad, registry,
binary-distribution, or release-tag work was begun.
