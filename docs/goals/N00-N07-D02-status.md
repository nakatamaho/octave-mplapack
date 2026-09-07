# N00-N07-D02 status

Status: **N03 PASS — arbitrary-precision rank/condition APIs complete**

The D01R1 frozen package identity remains unchanged. The development line is
now `mplapack-interop` 0.3.0-dev. N00, N01, N02, and N03 are complete;
N04-N07 and D02 remain pending.

## N00 identity

```text
Repository: nakatamaho/octave-mplapack
Branch: topic/d01r1-mplapack-interop
Current source before N00 commit: 9384236f6c7f360e86e8a3616e1c0bdb36873b57
N00 commit: dbe320fa4ed7f1d5541991796ab2df20e2687ec2
N01 implementation commit: 91a034d2f1acdf739b7ec3b30cc5e333ee6de4f1
N02 implementation commit: 9f05418f3fc700914727e00b4321ee3ecd061dfe
N03 implementation commit: pending status/report commit
Development version: 0.3.0-dev
Frozen predecessor: mplapack-interop 0.2.1 / v0.2.1
Historical predecessor commit: b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6
```

## Dependency identity used by the gates

```text
gmpfrxx_mkII: 1.4.1 / 32a7fb797202cdf92312ed9d133f96fdbcda590a
gmpfrxx SHA256: 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4
MPLAPACK: 3.0.1 / c21a9f56224308afda9e7424ca9928d4cf840f7a
MPLAPACK archive SHA256: f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1
MPLAPACK runtime: libmplapack_mpfr.so.3
```

The implementation was built and tested against the installed prefixes
derived from these archives. No source-worktree include or library path was
used by the N00 gates.

## N00 implementation

The public `@mp/norm` wrapper and native `norm` dispatch support real and
complex vectors and matrices with the accepted Octave forms:

```text
vectors: default/2, 1, 2, Inf, -Inf, 0, Fro, and positive finite p
matrices: 1, 2, Inf, and Fro
```

Real standard matrix paths use MPLAPACK Rlange and Rnrm2; complex standard
matrix paths use Clange and RCnrm2. Matrix 2-norms use singular-values-only
Rgesvd/Cgesvd helpers. Inputs are copied before destructive LAPACK calls.
MPFR/MPC precision scopes are operation-owned and no builtin binary64 complex
fallback is used.

Unsupported matrix p forms and invalid requests are rejected explicitly.
Special values, empty values, scalar values, precision preservation, and
ambient-precision behavior are covered by the native and public tests.

## Gates

```text
G-N00-API:        PASS — @mp/norm and native dispatch are present and documented
G-N00-REAL:       PASS — real vector/matrix norms use the MPFR backend
G-N00-COMPLEX:    PASS — complex vector/matrix norms use the MPC/MPFR backend
G-N00-MATRIX:     PASS — supported matrix norms and explicit deferrals behave correctly
G-N00-VECTOR:     PASS — vector p forms, finite p, and special values pass
G-N00-2NORM:      PASS — Rgesvd/Cgesvd and Rnrm2/RCnrm2 paths pass
G-N00-PRECISION:  PASS — 512-bit, 1024-bit, 2048-bit, and ambient precision pass
G-N00-SPECIAL:    PASS — empty, Inf, NaN, zero, and invalid-request tests pass
G-N00-REGRESSION: PASS — complete local CI and required regression wall pass
```

## Regression evidence

```text
tools/check-tree.sh: PASS
tools/check-format.sh: PASS
native make -C src check-norm: PASS
public norm smoke and invalid-request probes: PASS
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
package install/load/smoke/help/examples/unload/uninstall/reinstall: PASS
clean rebuild and retest: PASS
full tools/local-ci.sh: PASS (exit code 0)
```

The full N00 wall used `SOURCE_DATE_EPOCH=0` and explicitly selected the
installed D01R1 gmpfrxx/MPLAPACK prefix. The development package archive was
tested as `mplapack-interop-0.3.0-dev`; no release tag or 0.3.0 archive was
created by N00.

## Scope and deferrals

N00 adds only `norm`; N01 adds only `det` and `inv`; N02 adds only `svd`.
Symmetric and general eigenvalue routines, generalized eigenvalue routines,
and final closure remain assigned to N04-N07. No Debian, PPA,
Launchpad, registry, or binary-distribution work was started.

## Result

```text
N00 PASS — NORM API AND BACKEND COMPLETE
N01 PASS — DETERMINANT AND INVERSE COMPLETE
N02 PASS — SVD COMPLETE
N03 PASS — RANK / COND / RCOND COMPLETE
NEXT: N04 — symmetric/Hermitian eig
```

## N01 — `det` / `inv`

### Implementation

```text
det real: Rgetrf, pivot parity, U diagonal product
det complex: Cgetrf, pivot parity, U diagonal product
inv real: Rgetrf, checked Rgetri workspace query, Rgetri
inv complex: Cgetrf, checked Cgetri workspace query, Cgetri
singular determinant: exact MPFR/MPC zero
singular inverse: mplapack:mp:SingularMatrix
det second reciprocal-condition output: explicitly deferred to N03
```

All destructive calls use operation-owned copies. Real inputs remain on real
MPLAPACK kernels, complex inputs remain on MPC kernels, and no builtin
binary64 fallback was introduced.

### N01 gates

```text
G-N01-DET:          PASS
G-N01-DET-PIVOT:    PASS
G-N01-INV:          PASS
G-N01-WORKSPACE:    PASS
G-N01-SINGULAR:     PASS
G-N01-PRECISION:    PASS
G-N01-IMMUTABILITY: PASS
G-N01-REAL-COMPLEX: PASS
G-N01-REGRESSION:   PASS
```

### N01 regression wall

```text
native N01 sanitizer test: PASS
public N01 det/inv tests: PASS
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex Cgetrf: PASS
1024-bit / 2^-700 canary: PASS
2048-bit / 2^-1500 canary: PASS
ambient precision and scope restoration: PASS
input immutability and singular diagnostics: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
clean 0.3.0-dev archive rebuild/retest: PASS
package install/load/smoke/help/examples/unload/uninstall/reinstall: PASS
full tools/local-ci.sh: PASS (exit code 0)
```

N01 implementation is committed as
`91a034d2f1acdf739b7ec3b30cc5e333ee6de4f1` on
`topic/d01r1-mplapack-interop` and pushed. The D01R1
0.2.1 tag and archive remain unchanged. The next milestone is N03.

## N02 — `svd`

### Implementation

```text
real one-output singular values: existing N00 Rgesvd helper
complex one-output singular values: existing N00 Cgesvd helper
real factors: Rgesvd full/economy U, diagonal S, V from VT transpose
complex factors: Cgesvd full/economy U, diagonal real S, V from VT conjugate transpose
full shapes: U m-by-m, S m-by-n, V n-by-n
economy shapes: U m-by-k, S k-by-k, V n-by-k, k=min(m,n)
numeric 0 option: accepted as deprecated economy spelling
empty and scalar shapes: covered without invalid zero-size LAPACK calls
```

All LAPACK inputs are operation-owned copies. Real values stay on `Rgesvd`,
complex values stay on `Cgesvd`, the S output is real `mp` for complex input,
workspace queries and INFO are checked, and no binary64 fallback exists.

### N02 gates

```text
G-N02-BACKEND:        PASS
G-N02-ONE-OUTPUT:     PASS
G-N02-FULL:           PASS
G-N02-ECON:           PASS
G-N02-REAL:           PASS
G-N02-COMPLEX:        PASS
G-N02-RECONSTRUCTION: PASS
G-N02-ORTHOGONALITY:  PASS
G-N02-WORKSPACE:      PASS
G-N02-PRECISION:      PASS
G-N02-REGRESSION:     PASS
```

### N02 regression wall

```text
native sanitized SVD test: PASS
public real/complex SVD tests: PASS
full/economy/numeric-0 shape tests: PASS
scalar and empty shape tests: PASS
reconstruction and orthogonality/unitarity: PASS
input immutability: PASS
1024-bit / 2^-700 canary: PASS
2048-bit / 2^-1500 canary: PASS
ambient precision and scope restoration: PASS
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex Cgetrf: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
clean archive extraction build and lifecycle: PASS
full tools/local-ci.sh: PASS (exit code 0)
```

N02 implementation is committed as
`9f05418f3fc700914727e00b4321ee3ecd061dfe` on
`topic/d01r1-mplapack-interop` and pushed. The D01R1 0.2.1 tag and archive
remain unchanged. N03 is now complete; the next milestone is N04.

## N03 — `rank` / `cond` / `rcond`

### Implementation

```text
rank(A): MPFR/MPC singular values with stored-precision default threshold
rank(A,tol): explicit real MPFR tolerance, promoted to p_op
cond(A), cond(A,2): Rgesvd/Cgesvd singular-value ratio
cond(A,1): Rgetrf/Rgecon or Cgetrf/Cgecon 1-norm estimator
cond(A,Inf): Rgetrf/Rgecon or Cgetrf/Cgecon infinity-norm estimator
cond(A,"fro"): Frobenius singular-value identity for square matrices
rcond(A): Rgetrf/Rgecon or Cgetrf/Cgecon 1-norm reciprocal estimator
det(A) second output: same 1-norm reciprocal estimator
```

Rank uses `max(size(A))*sigma_max*Rlamch_mpfr("E")`, with all terms formed
at the one operation precision. Condition and reciprocal-condition paths use
operation-owned destructive copies. Real input remains on real MPLAPACK
kernels, complex input remains on complex MPLAPACK kernels, condition outputs
are real MPFR values, and no binary64 fallback or explicit inverse is used.

The initial N03 native test exposed that the frozen MPLAPACK `Rgecon`
implementation consumes four contiguous real work blocks, not three. The
operation was corrected to allocate 4n real work values; the corresponding
complex `Cgecon` path uses its audited 2n complex plus 2n real work arrays.
This was a release-contract integration defect in the new estimator path and
was repaired before the full gate.

### N03 gates

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

### N03 regression wall

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
isolated package lifecycle: PASS
deterministic source archive contents: PASS
full tools/local-ci.sh: PASS (exit code 0)
```

N03 is the current completed milestone. Its implementation and report are
committed and pushed before continuing automatically to N04. The D01R1
0.2.1 tag and archive remain unchanged.
