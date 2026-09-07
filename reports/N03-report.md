# N03 report — rank / cond / rcond

## Result

```text
N03 PASS — arbitrary-precision rank and condition APIs complete
```

N03 is implemented on `topic/d01r1-mplapack-interop` and uses the frozen
D01R1 dependency stack: gmpfrxx_mkII 1.4.1 at
`32a7fb797202cdf92312ed9d133f96fdbcda590a`, and MPLAPACK 3.0.1 at the tested
archive source commit `c21a9f56224308afda9e7424ca9928d4cf840f7a`.

## Implemented API

```text
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

Real input remains on MPFR `Rgesvd`/`Rgetrf`/`Rgecon`; complex input remains on
MPC `Cgesvd`/`Cgetrf`/`Cgecon`. Rank and 2-norm condition use the N02
singular-value helpers. The default rank threshold is computed at the
operation precision as `max(size(A))*sigma_max*Rlamch_mpfr("E")`. The
1/Inf condition paths and `rcond` use operation-owned LU copies and the
native GECON estimators. Frobenius condition uses the singular-value identity.
The determinant second output is the 1-norm reciprocal-condition estimate.

All condition values are real MPFR `mp` values, including for complex input.
Structural rank is an ordinary Octave scalar. Empty, singular, rectangular,
explicit-tolerance, input-immutability, low/high ambient precision, and
1024/2048-bit canaries are covered. No explicit inverse and no builtin
binary64 complex fallback are used.

## Gates

```text
G-N03-RANK:           PASS
G-N03-RANK-PRECISION: PASS
G-N03-COND2:          PASS
G-N03-COND1:          PASS
G-N03-CONDINF:        PASS
G-N03-CONDFRO:        PASS
G-N03-RCOND:          PASS
G-N03-SINGULAR:       PASS
G-N03-REAL:           PASS
G-N03-COMPLEX:        PASS
G-N03-PRECISION:      PASS
G-N03-REGRESSION:     PASS
```

## Regression evidence

```text
tools/check-tree.sh: PASS
tools/check-format.sh: PASS
native rank/condition sanitizer test: PASS
public N03 rank/condition tests: PASS
det two-output reciprocal-condition test: PASS
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex Cgetrf: PASS
1024-bit / 2^-700 canary: PASS
2048-bit / 2^-1500 canary: PASS
ambient precision and scope restoration: PASS
input immutability and singular/empty behavior: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
clean 0.3.0-dev archive extraction build: PASS
isolated package install/load/unload/uninstall/reinstall: PASS
deterministic package archive contents: PASS
full tools/local-ci.sh: PASS (exit code 0)
```

## Release-scope audit

N03 changes only the development line, whose version remains `0.3.0-dev`.
The frozen `mplapack-interop` 0.2.1 source tag and archive are unchanged.
No Debian package, PPA, Launchpad, Octave Packages registry, binary artifact,
or release tag was created.

## Implementation commit

The implementation and N03 regression/documentation record are committed and
pushed after the complete local gate. The exact commit is recorded in the
milestone status document.
