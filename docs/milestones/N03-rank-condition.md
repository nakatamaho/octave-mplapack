# N03 — rank / cond / rcond

N03 completes dense arbitrary-precision numerical rank and condition-number
inspection for real and complex `mp` matrices.

## Contract

The public API is:

```octave
rank(A)
rank(A,tol)
cond(A)
cond(A,1)
cond(A,2)
cond(A,Inf)
cond(A,"fro")
rcond(A)
[d,c] = det(A)
```

Rank uses MPFR/MPC singular values and a default threshold formed from
`max(size(A))`, the largest singular value, and `Rlamch_mpfr("E")` at the
operation precision. An explicit real MPFR tolerance is promoted as part of
the same one-operation precision contract.

`cond(A)` and `cond(A,2)` use `Rgesvd`/`Cgesvd`; `cond(A,"fro")` uses the
singular values; and `cond(A,1)`, `cond(A,Inf)`, and `rcond(A)` use
`Rgetrf`/`Rgecon` or `Cgetrf`/`Cgecon` on operation-owned copies. The
determinant second output is the 1-norm reciprocal estimate. No explicit
inverse or binary64 complex fallback is used.

## Gates

```text
G-N03-RANK
G-N03-RANK-PRECISION
G-N03-COND2
G-N03-COND1
G-N03-CONDINF
G-N03-CONDFRO
G-N03-RCOND
G-N03-SINGULAR
G-N03-REAL
G-N03-COMPLEX
G-N03-PRECISION
G-N03-REGRESSION
```

The native sanitizer test covers real and complex rank, all condition paths,
singular and empty edges, and the 512/1024/2048-bit precision transition.
The public wall covers the same API, determinant metadata, rectangular rank
and 2-norm condition, input immutability, ambient precision, the complete
M00–M23 real wall, C00–C12 including C11L, and clean archive/package QA.
