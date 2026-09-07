# N00-N07-D02 status

Status: **N06 PASS — generalized eig QA complete**

The D01R1 frozen package identity remains unchanged. The development line is
now `mplapack-interop` 0.3.0-dev. N00, N01, N02, N03, N04, and N05 are
complete; N07 and D02 remain pending.

## N00 identity

```text
Repository: nakatamaho/octave-mplapack
Branch: topic/d01r1-mplapack-interop
Current source before N00 commit: 9384236f6c7f360e86e8a3616e1c0bdb36873b57
N00 commit: dbe320fa4ed7f1d5541991796ab2df20e2687ec2
N01 implementation commit: 91a034d2f1acdf739b7ec3b30cc5e333ee6de4f1
N02 implementation commit: 9f05418f3fc700914727e00b4321ee3ecd061dfe
N03 implementation commit: ab8ed68fb4e04c821bb50a0e08e578474ee1cfcd
N04 implementation commit: 455b5df72c65bb4475c6436429dae005910eb88f
N05 implementation commit: 61e8afa0c6af780f30948347f51c95b60d397d1a
N06 implementation commit: pending final commit below
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
NEXT: N06 — generalized eig(A,B)
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

N03 was the preceding completed milestone. Its implementation and report were
committed and pushed before continuing automatically to N04. The D01R1
0.2.1 tag and archive remain unchanged.

## N04 — structured symmetric/Hermitian `eig`

### Implementation

```text
real symmetric input: exact represented symmetry check, MPFR Rsyevd
complex Hermitian input: exact represented Hermitian check, MPC/MPFR Cheevd
lambda = eig(A): real mp eigenvalue column vector
[V,D] = eig(A): real mp diagonal D
[V,d] = eig(A,"vector"): real mp eigenvalue column vector d
real symmetric eigenvectors: real mp
complex Hermitian eigenvectors: complex mp
general and generalized eig: rejected and deferred to N05/N06
```

The native backend uses operation-owned destructive copies and one MPFR or
composed MPFR/MPC precision scope at the stored input precision. It performs
no binary64 fallback and never routes real input through the complex kernel.
Repeated-eigenvalue QA checks residuals and orthogonality rather than
non-unique eigenvector entries. High-dynamic-range 1024/2048-bit fixtures,
ambient precision, exact detection, and input immutability are covered.

### Gates

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

### Regression evidence

```text
tools/check-tree.sh: PASS
tools/check-format.sh: PASS for current N04 files
native Rsyevd/Cheevd sanitizer test: PASS
public N04 structured eig tests: PASS
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex Cgetrf: PASS
1024-bit / 2^-700 canary: PASS
2048-bit / 2^-1500 canary: PASS
ambient precision and scope restoration: PASS
input immutability and exact rejection: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
```

The complete N04 wall passed before the N04 implementation, report, and status
were committed and pushed. The D01R1 0.2.1 tag and archive remain unchanged.

## N05 — general standard `eig` and mandatory Grcar QA

### Implementation

```text
real nonsymmetric input: MPFR Rgeevx
complex non-Hermitian input: MPC/MPFR Cgeevx
structured exact symmetric/Hermitian input: retained N04 Rsyevd/Cheevd dispatch
lambda = eig(A): complex mp eigenvalue column for the general path
[V,D] = eig(A): complex mp right vectors and diagonal matrix
[V,d] = eig(A,"vector"): complex mp right vectors and eigenvalue column
[V,D] = eig(A,"matrix"): explicit matrix form
[V,D,W] = eig(A): complex mp right/diagonal/left outputs
eig(A,"balance"): explicit Rgeevx/Cgeevx balancing path
eig(A,"nobalance"): explicit Rgeevx/Cgeevx nobalance path
```

Real LAPACK conjugate-pair columns are converted explicitly to complex MPC
storage. General real outputs are therefore complex `mp` even when the
eigenvalues are all real. Every destructive call uses an operation-owned copy,
one stored-precision MPFR or MPFR/MPC scope, checked workspace/INFO, and
uniform-precision work arrays. No real input is routed through a complex
kernel and no builtin binary64 fallback exists.

The compatibility firewall now rejects only deferred generalized `eig(A,B)`
for this area. The permanent Grcar fixture exercises default/balance
equivalence, explicit balance/nobalance, right and left residuals, and
128/256/512-bit precision progression. Near-Jordan, nearly repeated, badly
scaled, 1024-bit `2^-700`, 2048-bit `2^-1500`, ambient precision, and input
immutability cases are covered.

### Gates

```text
G-N05-BACKEND:             PASS
G-N05-REAL-GENERAL:       PASS
G-N05-COMPLEX-GENERAL:    PASS
G-N05-BALANCE:            PASS
G-N05-NOBALANCE:          PASS
G-N05-RIGHT-EIGENVECTORS: PASS
G-N05-LEFT-EIGENVECTORS:  PASS
G-N05-GRCAR:              PASS
G-N05-NEAR-DEFECTIVE:     PASS
G-N05-PRECISION:          PASS
G-N05-REGRESSION:         PASS
```

### Regression evidence

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
ambient precision and scope restoration: PASS
input immutability and native lifetime tests: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
clean archive extraction build: PASS
package install/load/smoke/help/examples/unload/uninstall/reinstall: PASS
deterministic source archive contents: PASS
full tools/local-ci.sh: PASS (exit code 0)
```

N05 is complete and N06 generalized `eig(A,B)` is now complete. The N06
implementation uses the frozen MPLAPACK MPFR/MPC backend and preserves the
one-operation/one-precision contract. The D01R1 0.2.1 tag and archive remain
unchanged.

## N06 implementation

N06 adds dense generalized real and complex eigenproblems. Exactly symmetric
or Hermitian pairs use `Rsygvd`/`Chegvd` for the default definite path; a
non-positive-definite `B` falls back to QZ, and explicit `"qz"` uses
`Rggev`/`Cggev`. Explicit `"chol"` requires the exact structured pair.

The public wrapper supports Octave-compatible `matrix`/`vector` layouts,
one-output diagonal/vector forms, three-output right/eigenvalue/left forms,
mixed real/complex promotion, and rejection of generalized balance options.
The native backend divides `alpha/beta` at the operation precision, preserves
infinite eigenvalues for `beta = 0`, converts real conjugate pairs to complex
MP storage, and keeps all destructive calls on owned copies.

## N06 gates

```text
G-N06-API:                   PASS
G-N06-QZ:                    PASS
G-N06-CHOL:                  PASS
G-N06-REAL:                  PASS
G-N06-COMPLEX:               PASS
G-N06-INFINITE-EIGENVALUES:  PASS
G-N06-RIGHT-EIGENVECTORS:    PASS
G-N06-LEFT-EIGENVECTORS:     PASS
G-N06-MATRIX-VECTOR:         PASS
G-N06-PRECISION:             PASS
G-N06-REGRESSION:            PASS
```

## N06 regression evidence

```text
tools/check-tree.sh: PASS
tools/check-format.sh: PASS
native make -C src check-generalized-eig: PASS
public test/eig_generalized.tst: PASS
full test/run_tests.m: PASS (M00-M23, C00-C12 including C11L, N00-N06)
full tools/local-ci.sh: PASS (exit code 0)
ASan: PASS
UBSan: PASS
LSan: PASS
real/complex definite and QZ residuals: PASS
singular-B infinity and alpha/beta handling: PASS
matrix/vector and three-output left-vector forms: PASS
mixed real/complex pair: PASS
1024-bit 2^-700 and 2048-bit 2^-1500: PASS
ambient precision restoration: PASS
input immutability: PASS
clean package archive extraction/build/install/lifecycle: PASS
deterministic source package archive: PASS
```

N06 is complete. The next milestone is N07 numerical API closure. No D02
release tag or final 0.3.0 archive is created in N06.
