# /goal ― Complete Complex `mp` Implementation C00C12

## Goal

Implement the complete first-generation **dense arbitrary-precision complex** support for `nakatamaho/octave-mplapack`, from native storage through complex BLAS/LAPACK integration, while preserving the frozen real-only v0.1 release candidate as an immutable checkpoint.

This goal is a **multi-milestone controller**:

```text
C00 -> C01 -> C02 -> C03 -> C04 -> C05 -> C06
    -> C07 -> C08 -> C09 -> C10 -> C11 -> C12
```

Continue automatically from one milestone to the next whenever the current milestone is `PASS`.

Do not ask the user to manually issue another prompt between normal milestones.

If a proven upstream defect is found in `gmpfrxx_mkII` or MPLAPACK, create the minimal upstream topic branch/fix, validate it, record the exact commit, rebuild the controlled dependency, and resume the blocked complex milestone.

Do not begin Debian/PPA packaging in this goal.

---

# 0. Immutable real checkpoint

The real-only v0.1 checkpoint is immutable:

```text
REAL_V0_1_RC_COMMIT =
0bef79cddd3fdd70abafdf38bc1a4ab492652d33

REAL_V0_1_ARCHIVE =
mplapack-0.1.0.tar.gz

REAL_V0_1_ARCHIVE_SHA256 =
35d004adf831c79fe470ff890ce3698dfe7e6f624ea31c174b1d60a03d110db6
```

Never rewrite, amend, retag, or mutate this checkpoint.

The complex development line is separate.

Use the real checkpoint for:

```text
regression comparison
behavior comparison
historical provenance
possible emergency real-only release
```

---

# 1. Required repository layout

Preferred workspace:

```text
work/
├── gmpfrxx_mkII/                  # upstream dependency; writable for real upstream fixes
├── mplapack/                      # upstream MPLAPACK; writable for real upstream fixes
├── octave-mplapack/               # complex implementation happens here
└── octave-mplapack-ppa/           # parked; DO NOT modify during C00-C12
```

Discover actual repository locations if the layout differs.

Do not hard-code user-specific absolute paths.

Use repository identity:

```bash
git remote -v
git rev-parse --show-toplevel
```

---

# 2. File placement inside `octave-mplapack`

Place this master goal at:

```text
octave-mplapack/
└── docs/
    └── goals/
        └── COMPLEX-C00-C12-goal.md
```

Use/create:

```text
octave-mplapack/
├── docs/
│   ├── goals/
│   │   ├── COMPLEX-C00-C12-goal.md
│   │   └── COMPLEX-C00-C12-status.md
│   │
│   ├── complex-architecture.md
│   ├── complex-api.md
│   ├── complex-precision.md
│   ├── complex-backends.md
│   ├── complex-compatibility.md
│   ├── complex-release-checklist.md
│   │
│   └── milestones/
│       ├── C00-complex-scaffold.md
│       ├── C01-complex-scalar.md
│       ├── C02-complex-matrix.md
│       ├── C03-complex-structural.md
│       ├── C04-complex-elementwise.md
│       ├── C05-complex-gemm.md
│       ├── C06-complex-square-solve.md
│       ├── C07-complex-rectangular-solve.md
│       ├── C08-complex-cholesky.md
│       ├── C09-complex-qr.md
│       ├── C10-complex-pivoted-qr.md
│       ├── C11-mixed-real-complex-closure.md
│       └── C12-complex-release-closure.md
│
├── reports/
│   └── complex/
│       ├── C00-report.md
│       ├── C01-report.md
│       ├── C02-report.md
│       ├── C03-report.md
│       ├── C04-report.md
│       ├── C05-report.md
│       ├── C06-report.md
│       ├── C07-report.md
│       ├── C08-report.md
│       ├── C09-report.md
│       ├── C10-report.md
│       ├── C11-report.md
│       └── C12-report.md
│
├── test/
│   ├── complex/
│   │   ├── native/
│   │   ├── public/
│   │   └── probes/
│   └── ...
│
├── src/
├── inst/
└── tools/
```

If release/package policy would ship `reports/`, explicitly exclude `reports/` from release archives.

Do not reorganize historical M00-M23 files only for style.

---

# 3. Controller state / resume

Maintain:

```text
docs/goals/COMPLEX-C00-C12-status.md
```

with:

```text
REAL_V0_1_RC_COMMIT
COMPLEX_START_COMMIT
current milestone
last PASS milestone
octave-mplapack branch/tip
MPLAPACK tested commit
gmpfrxx_mkII tested commit
upstream fixes
blockers
full regression status
```

On restart:

1. read status;
2. inspect all repository HEADs;
3. verify recorded commits exist;
4. detect completed milestones;
5. continue from the first incomplete milestone.

Do not duplicate already accepted work.

---

# 4. Branch policy

Preferred main controller branch:

```text
topic/complex-c00-c12
```

If repository policy strongly prefers one branch/PR per milestone, use:

```text
topic/c00-complex-scaffold
...
topic/c12-complex-release-closure
```

and merge accepted milestones in sequence.

For upstream fixes:

```text
gmpfrxx_mkII:
topic/octave-mplapack-complex-<issue>

mplapack:
topic/octave-mplapack-complex-<issue>
```

Do not mix unrelated upstream fixes.

Do not force-push published history.

---

# 5. Starting state

Inspect all three development repositories:

```bash
git status --short
git branch --show-current
git rev-parse HEAD
git log --oneline --decorate -40
git remote -v
```

Identify:

```text
COMPLEX_START_COMMIT
```

as the accepted post-M23 development base.

Keep separate:

```text
REAL_V0_1_RC_COMMIT
COMPLEX_START_COMMIT
```

The complex line may start from the merged M23 state if later commits are report/metadata only.

---

# 6. Development version

After C00 baseline validation, move the development package version to:

```text
0.2.0-dev
```

unless project policy already defines another post-v0.1 development suffix.

Do not tag `v0.2.0`.

D00 after C12 freezes final dependency/release versions.

---

# 7. M20 architecture is normative

M20 decisions are the default architecture:

```text
complex scalar:
    mpfrxx::mpc_class

complex dense matrix:
    contiguous column-major std::vector<mpfrxx::mpc_class>

public class:
    one public class `mp`

payload kinds:
    real scalar
    real dense matrix
    complex scalar
    complex dense matrix

one complex object:
    one precision p

real component:
    p

imag component:
    p

mixed result:
    any complex participant -> complex

mixed precision:
    p_op = max(all participating mp precisions)

real -> complex:
    exact represented real + exact +0i at p_op

implicit complex -> real demotion:
    forbidden
```

Do not redesign these without a concrete blocker.

Any change to M20 decisions must be:

```text
evidence-backed
documented
tested
called out in the milestone report
```

---

# 8. Known complex backends

M20 audited:

```text
complex scalar:
    mpfrxx::mpc_class

GEMM:
    Cgemm

square solve:
    Cgesv

Cholesky:
    Cpotrf

QR:
    Cgeqrf
    Cungqr

pivoted QR:
    Cgeqp3

rectangular solve candidates:
    Cgelsy
    Cgelss
    Cgelsd
```

Each numerical milestone must re-audit the exact installed declaration and exact controlled source path.

---

# 9. Uniform complex precision contract

Normative rule:

```text
ONE COMPLEX MPLAPACK INVOCATION = ONE p_op
```

For one invocation:

```text
all COMPLEX components = p_op
all COMPLEX arrays      = p_op
all participating REAL  = p_op
all REAL workspace      = p_op
all COMPLEX workspace   = p_op
executing-thread MPFR/MPC context = p_op
```

Mixed component precision inside one public complex value is unsupported.

Mixed precision inside one complex MPLAPACK call is unsupported.

---

# 10. C00 must resolve MPFR/MPC scope composition

M20 left:

```text
MPC override can diverge from MPFR scope
```

as an open issue.

C00 must establish one project policy so numerical code cannot accidentally run with:

```text
MPFR default = p_op
MPC default/override != p_op
```

Preferred architecture:

```text
one RAII complex precision/rounding scope
```

or a verified composition of the existing MPLAPACK MPFR scope and the gmpfrxx_mkII MPC context.

Nested scopes and exception/error restoration must work.

---

# 11. Upstream-fix policy

If a milestone exposes an upstream defect in `gmpfrxx_mkII` or MPLAPACK, do not hide it downstream.

Examples:

```text
wrong default precision
mixed component precision
unsafe mpc_class copy/move
worker precision leak
Cgemm temporary precision defect
Cgesv/Cpotrf/Cgeqrf/Cgeqp3 precision defect
workspace precision defect
backend result wrong outside Octave wrapper
```

Required workflow:

```text
1. produce a minimal native reproducer
2. prove defect outside public octave-mplapack dispatch
3. identify owning upstream repository
4. create bounded topic branch
5. implement minimal upstream fix
6. add upstream regression
7. run relevant upstream CI/tests
8. rebuild/reinstall controlled dependency
9. rerun external probe
10. record exact fix commit
11. resume current milestone
```

No downstream numerical workaround for an upstream bug.

---

# 12. Dependency provenance

Maintain:

```text
docs/complex-backends.md
```

with:

```text
gmpfrxx_mkII repository/commit
MPLAPACK repository/commit
installed headers
pkg-config identities
runtime SONAMEs
upstream fixes introduced by C00-C12
```

These are development commits, not final Debian versions.

D00 freezes final dependency releases.

---

# 13. Real regression wall

Every C00-C12 milestone preserves M00-M23 real behavior.

Hard invariants:

```text
real * real                 -> Rgemm
real square \ real          -> Rgesv
real rectangular \ real     -> Rgelss
real chol                   -> Rpotrf
real qr                     -> Rgeqrf/Rorgqr
real pivoted qr             -> Rgeqp3/Rorgqr
real lu                     -> Rgetrf
real transpose/ctranspose   -> accepted M12 behavior
```

Do not route real operations through complex kernels.

---

# 14. No binary64 fallback

Unsupported/incomplete complex operations must fail cleanly.

Never:

```text
convert complex mp -> builtin complex double
perform builtin operation
convert back
```

unless the operation is explicitly `double()`.

Expand fallback-firewall QA throughout the C-series.

---

# 15. Value semantics

Public `mp` remains value-semantic.

Destructive complex BLAS/LAPACK calls use operation-owned copies.

Test output lifetime after:

```octave
B = f(A);
clear A;
```

for every major path.

---

# C00 ― Complex Scaffold, Payloads, Precision Context

## Mission

Implement the internal complex foundation:

```text
mpc_class ownership
complex scalar storage
complex matrix storage
four-kind payload dispatch
uniform precision
MPFR/MPC scope composition
copy/move/lifetime
special values
```

No broad public complex arithmetic yet.

## Storage

Add repository-consistent equivalents of:

```text
MpfrComplexScalarStorage
MpfrComplexMatrixStorage
```

Matrix:

```text
contiguous
column-major
std::vector<mpfrxx::mpc_class>
one stored precision p
```

Provide checked:

```text
rows
columns
leading_dimension
data()
precision
```

## Complex scope

Implement/adopt one RAII abstraction that saves/restores the complete current-thread complex operation context:

```text
MPFR precision/default
MPC precision override/default
relevant rounding mode
```

Set round-to-nearest for both components.

Nested scopes must work.

## Probes

Test:

```text
128
256
512
1024
2048
```

for:

```text
default construction
explicit precision
copy
move
vector allocation
signed real zero
signed imag zero
Inf
NaN
thread-local independence
nested scope restoration
exception-path restoration
```

## Gates

```text
G-C00-TYPE
G-C00-STORAGE
G-C00-PRECISION
G-C00-TLS
G-C00-LIFETIME
G-C00-SPECIAL
G-C00-REAL-REGRESSION
```

All PASS -> `C00 PASS`.

---

# C01 ― Complex Scalar Constructor and Conversion

## Mission

Make complex scalar `mp` first-class.

## Mandatory public support

```octave
mp(complex_double)
```

using direct binary64 real/imag conversion.

Add one exact arbitrary-precision construction path.

Preferred after API audit:

```octave
mp(real_text, imag_text)
```

or an equally unambiguous explicit form.

No binary64 intermediate for exact text.

## `double`

```octave
double(z)
```

returns builtin complex double through component-wise round-to-nearest conversion.

## `char`

Define a deterministic round-trip-safe scalar grammar:

```text
locale independent
source-precision safe
unambiguous
Inf/NaN aware
signed-zero aware as representable
```

## `disp`

Human-readable, arbitrary precision, no double conversion.

## Preserve real kind

Real constructors remain real payloads.

## Precision canaries

1024-bit:

```text
real = 1 + 2^-700
imag = 2^-700
```

2048-bit:

```text
real = 1 + 2^-1500
imag = -2^-1500
```

## Gates

```text
G-C01-CONSTRUCT
G-C01-DOUBLE
G-C01-CHAR
G-C01-DISP
G-C01-PRECISION
G-C01-SPECIAL
G-C01-REAL-PARITY
```

All PASS -> `C01 PASS`.

---

# C02 ― Complex Dense Matrix, Inspection, Indexing, Display

## Mission

Make dense complex matrices first-class public `mp`.

## Construction

Support builtin complex double matrices.

Convert binary64 real/imag components directly at destination precision.

Do not invent an unverified exact text-cell complex grammar.

## Indexing

Mirror accepted real behavior:

```octave
A(i,j)
A(:,j)
A(i,:)
A(I,J)
A(k)
A(:)
end
```

Scalar extraction -> complex scalar.

Slices -> complex matrix.

Preserve precision.

## Assignment

Implement complex->complex assignment with M14 value semantics.

Real/complex storage-kind promotion is closed in C11.

No growth/deletion/logical assignment unless real API already supports it.

## `double`

Builtin complex double matrix.

## `disp`

Direct arbitrary-precision component formatting.

## Empty

Audit:

```text
0x0
0xN
Mx0
```

## Gates

```text
G-C02-CONSTRUCT
G-C02-STORAGE
G-C02-INDEX
G-C02-ASSIGN
G-C02-DOUBLE
G-C02-DISP
G-C02-EMPTY
G-C02-LIFETIME
G-C02-REAL-REGRESSION
```

All PASS -> `C02 PASS`.

---

# C03 ― `real`, `imag`, `conj`, Transpose, Ctranspose

## Mandatory semantics

```octave
real(Z)   -> real mp, same precision/shape
imag(Z)   -> real mp, same precision/shape
conj(Z)   -> complex mp, same precision/shape
Z.'       -> transpose only
Z'        -> transpose + conjugation
```

Real `mp` keeps accepted M12 behavior.

Conjugation must correctly flip imaginary signed zero.

## Gates

```text
G-C03-REAL
G-C03-IMAG
G-C03-CONJ
G-C03-TRANSPOSE
G-C03-CTRANSPOSE
G-C03-SIGNED-ZERO
G-C03-REAL-PARITY
```

All PASS -> `C03 PASS`.

---

# C04 ― Complex Element-wise Arithmetic

## Operations

```text
+
-
.*
./
unary +
unary -
```

## Result-kind table

```text
real op real       -> real
real op complex    -> complex
complex op real    -> complex
complex op complex -> complex
```

## Precision

```text
p_op = max(all participating mp precisions)
```

Builtin double/complex double contributes represented binary64 values but does not create a higher arbitrary precision.

Allocate destination explicitly at `p_op`.

Avoid ambient-default temporaries.

## Broadcasting

Use the accepted real M11 2-D singleton expansion model.

## Special values

Audit Inf/NaN/signed-zero/division-by-zero.

## Gates

```text
G-C04-SCALAR
G-C04-MATRIX
G-C04-MIXED-KIND
G-C04-MIXED-PRECISION
G-C04-BROADCAST
G-C04-SPECIAL
G-C04-REAL-REGRESSION
```

All PASS -> `C04 PASS`.

---

# C05 ― Complex Matrix Multiplication via `Cgemm`

## Dispatch

```text
real * real       -> existing Rgemm
real * complex    -> Cgemm
complex * real    -> Cgemm
complex * complex -> Cgemm
```

## Promotion

Normalize complex-participating operands to one `p_op`.

Real values promote with exact `+0i`.

Builtin complex double converts directly from binary64 components.

## Uniform boundary

At Cgemm:

```text
A/B/C
alpha/beta
temporaries
current-thread complex context
```

all use `p_op`.

Audit exact installed signature/source/threading.

If optimized workers lack precision setup:

```text
C05 BLOCKED ― COMPLEX GEMM WORKER PRECISION CONTRACT
```

Fix upstream.

## Precision canaries

Mandatory:

```text
1024 / 2^-700
2048 / 2^-1500
```

real and imaginary tails.

## Gates

```text
G-C05-UPSTREAM
G-C05-DISPATCH
G-C05-CGEMM
G-C05-PRECISION
G-C05-MIXED
G-C05-SHAPES
G-C05-IMMUTABILITY
G-C05-REAL-RGEMM-PARITY
```

All PASS -> `C05 PASS`.

---

# C06 ― Complex Square Solve via `Cgesv`

Extend square `A\B` with complex participation.

## Dispatch

```text
real square A + real B -> Rgesv
any complex participant -> Cgesv
```

## Precision

```text
p_op = max(all participating mp precisions)
```

Use operation-owned uniformly p_op complex A/B.

Pivot type = installed `mplapackint`.

Multiple RHS mandatory.

Singular behavior must match established square-solve semantics.

## Gates

```text
G-C06-UPSTREAM
G-C06-CGESV
G-C06-MIXED
G-C06-PIVOT
G-C06-SINGULAR
G-C06-MULTIRHS
G-C06-PRECISION
G-C06-IMMUTABILITY
G-C06-REAL-RGESV-PARITY
```

All PASS -> `C06 PASS`.

---

# C07 ― Complex Rank-Revealing Rectangular Solve

Extend rectangular `A\B` to complex participation.

## Mandatory candidate audit

Compare:

```text
Cgelsy
Cgelss
Cgelsd
```

using the exact controlled dependency.

Test:

```text
full-column-rank overdetermined
full-row-rank underdetermined
rank zero
rank one
inconsistent rank deficient
multiple RHS
precision-sensitive rank
workspace complexity
REAL workspace precision
COMPLEX workspace precision
thread/worker precision
```

M20 suggested Cgelsy first, but select from evidence.

## Semantics

Target:

```text
minimum norm
rank deficient supported
one p_op
rank classification controlled by stored operand precision
ambient independent
```

## RCOND / threshold

Must derive from `p_op`.

Never use:

```text
DBL_EPSILON
hard-coded decimal
ambient mpbits()
```

## Workspace

All REAL and COMPLEX workspace/state participating in arithmetic must use `p_op`.

## Gates

```text
G-C07-CANDIDATE-AUDIT
G-C07-UPSTREAM
G-C07-FULL-RANK
G-C07-RANK-DEF
G-C07-MIN-NORM
G-C07-RANK-PRECISION
G-C07-WORKSPACE
G-C07-MIXED
G-C07-IMMUTABILITY
G-C07-REAL-RGELSS-PARITY
```

All PASS -> `C07 PASS`.

---

# C08 ― Hermitian Cholesky via `Cpotrf`

Extend:

```octave
chol(A)
chol(A,"upper")
chol(A,"lower")
[R,p] = chol(...)
```

to complex.

## Selected triangle

Preserve M17:

```text
upper -> only upper triangle authoritative
lower -> only lower triangle authoritative
```

Selected complex triangle defines a Hermitian matrix.

Do not enforce agreement of the ignored triangle.

## Contract

Upper:

```text
R' * R = H_upper(A)
```

Lower:

```text
L * L' = H_lower(A)
```

where `'` is conjugate transpose.

Audit complex diagonal imaginary-component behavior against Cpotrf and builtin Octave.

Preserve one/two-output non-PD semantics where compatible.

## Gates

```text
G-C08-UPSTREAM
G-C08-HERMITIAN
G-C08-SELECTED-TRIANGLE
G-C08-UPPER
G-C08-LOWER
G-C08-NONPD
G-C08-STATUS
G-C08-PRECISION
G-C08-IMMUTABILITY
G-C08-REAL-CHOL-PARITY
```

All PASS -> `C08 PASS`.

---

# C09 ― Non-pivoted Complex QR via `Cgeqrf` / `Cungqr`

Extend M18 forms:

```octave
R = qr(A)
[Q,R] = qr(A)
R = qr(A,"econ")
[Q,R] = qr(A,"econ")
R = qr(A,0)
[Q,R] = qr(A,0)
```

## Critical semantics

One output is R.

One-output path does not construct Q.

Preserve full/economy shapes.

Complex orthogonality:

```text
Q' * Q = I
```

not `Q.'*Q`.

R structural lower zeros are exact complex zero.

Audit Cgeqrf/Cungqr workspace and threading.

## Gates

```text
G-C09-UPSTREAM
G-C09-FULL
G-C09-ECON
G-C09-ONE-OUTPUT
G-C09-WORKSPACE
G-C09-ORTHOGONALITY
G-C09-RECONSTRUCTION
G-C09-PRECISION
G-C09-REAL-QR-PARITY
```

All PASS -> `C09 PASS`.

---

# C10 ― Pivoted Complex QR via `Cgeqp3`

Extend M19 forms:

```octave
[Q,R,P] = qr(A)
[Q,R,P] = qr(A,"matrix")
[Q,R,p] = qr(A,"vector")
[Q,R,P] = qr(A,"econ")
[Q,R,p] = qr(A,0)
```

Production:

```text
Cgeqp3
Cungqr
```

## Permutation

Unchanged:

```text
Q*R = A*P
Q*R = A(:,p)
```

P/p remain builtin real structural data.

Initialize JPVT all zero.

Audit exact complex JPVT mapping.

## Precision pivot canary

Create a complex norm fixture where lower/higher stored precision changes pivot order.

Ambient precision must not change it.

Real 3-output QR remains Rgeqp3.

## Gates

```text
G-C10-UPSTREAM
G-C10-PERMUTATION
G-C10-MATRIX-P
G-C10-VECTOR-P
G-C10-ECON
G-C10-PIVOT-PRECISION
G-C10-RECONSTRUCTION
G-C10-ORTHOGONALITY
G-C10-REAL-RGEQP3-PARITY
```

All PASS -> `C10 PASS`.

---

# C11 ― Mixed Real/Complex Closure

Close the first-generation mixed public surface.

## Mandatory promotion

```text
real mp op real mp       -> real
real mp op complex mp    -> complex
complex mp op real mp    -> complex
complex mp op complex mp -> complex

p_op = max(all participating mp precisions)
```

## Operations

At minimum:

```text
+
-
.*
./
*
\
```

## Concatenation

```octave
[A_real, B_complex]
[A_real; B_complex]
[A_complex, B_real]
```

returns one complex matrix.

```text
p_cat = max(all participating mp precisions)
```

## Assignment

```octave
B = A_real;
B(i,j) = complex_rhs;
```

B becomes complex.

A remains unchanged.

```text
p_assign = max(lhs,rhs mp precisions)
```

Complex LHS + real RHS remains complex.

## Structural interoperability

Complex reshape/indexing/transpose/ctranspose/disp/double all compose.

## Builtin mixing

Audit real/complex builtin double participation through direct binary64 component conversion.

## No demotion

Never downgrade a complex result just because current imaginary values are zero.

## Gates

```text
G-C11-PROMOTION
G-C11-PRECISION
G-C11-ARITHMETIC
G-C11-MTIMES
G-C11-MLDIVIDE
G-C11-CONCAT
G-C11-ASSIGN
G-C11-STRUCTURAL
G-C11-BUILTIN-DOUBLE
G-C11-NO-DEMOTION
G-C11-REAL-REGRESSION
```

All PASS -> `C11 PASS`.

---

# C11L ― Mandatory Complex LU via `Cgetrf`

Complex LU is mandatory in this goal. Reproduce M21 semantics through
MPLAPACK `Cgetrf`:

```text
packed one-output
two-output A=L*U
three-output P*A=L*U
vector A(p,:)=L*U
rectangular
singular factors
source-precision pivoting
```

Do not implement complex LU as an incidental side change; C11L is a required
milestone between C11 and C12.

---

# C12 ― Real + Complex Release Closure

No new major numerical feature.

## Finalize docs

```text
docs/complex-api.md
docs/complex-compatibility.md
docs/complex-release-checklist.md
docs/complex-backends.md
```

## Supported surface inventory

Record exact implemented forms for:

```text
complex scalar
complex matrix
double
char scalar
disp
indexing
assignment
real
imag
conj
transpose
ctranspose
+ - .* ./
*
square \
rectangular \
chol
qr
pivoted qr
mixed real/complex
concat
assignment
complex lu status
```

## Compatibility firewall

Probe unsupported complex functions:

```text
eig
svd
det
inv
rank
cond
norm
power
unimplemented transcendentals
ordered comparison
logical
sparse
```

Require:

```text
clean unsupported behavior
no binary64 fallback
no crash
no recursion
```

## Full regression

Run:

```text
M00-M23 real regression
C00-C11L complex regression
all upstream probes
```

## Precision regression

Mandatory 1024/2048 tail coverage across:

```text
scalar round trip
element-wise
Cgemm
Cgesv
rectangular solve
Cpotrf
Cgeqrf/Cungqr
Cgeqp3
mixed real/complex
```

plus all existing real canaries.

## TLS/thread regression

Alternate:

```text
256
1024
2048
512
```

with low/high ambient defaults.

Run thread-local probes where supported.

## Sanitizers

```text
ASan
UBSan
LSan
```

## Package lifecycle

Build/install/unload/reinstall the normal Octave package and run real+complex smoke.

No Debian package.

## Version

Remain development:

```text
0.2.0-dev
```

D00 freezes final versions.

## Final gates

```text
G-C12-API
G-C12-DOCS
G-C12-FIREWALL
G-C12-REAL-REGRESSION
G-C12-COMPLEX-REGRESSION
G-C12-PRECISION
G-C12-TLS
G-C12-SANITIZERS
G-C12-PACKAGE-LIFECYCLE
G-C12-UPSTREAM-PROVENANCE
```

All PASS:

```text
C12 PASS ― REAL-COMPLEX-API-CLOSED
DEPENDENCY-FREEZE-READY
```

---

# 16. Complex constructor grammar must be frozen by C12

C01 must settle a documented exact complex constructor/char grammar.

Do not leave public exact complex construction dependent on an undocumented parser.

If a single-string grammar is risky, prefer an explicit two-component text constructor.

Correctness and round-trip safety take priority over syntactic mimicry.

---

# 17. Octave differential QA

Use builtin Octave complex double for structural/API semantics:

```text
shape
output count
option parsing
empty behavior
transpose/ctranspose
chol status
qr shapes
permutation representation
```

Do not use builtin double as the high-precision numerical oracle.

Use MPFR/MPC and algebraic invariants for numerical gates.

---

# 18. High-precision QA rule

Never gate arbitrary-precision correctness only with:

```text
double()
1e-12
DBL_EPSILON
```

Use:

```text
p_op
MPFR/MPC values
dimension-scaled precision-aware bounds
exact fixtures
```

---

# 19. Special values

Audit throughout:

```text
real +0/-0
imag +0/-0
Inf
NaN
```

Require:

```text
no crash
no lifetime defect
no precision leak
documented deterministic behavior
```

Do not over-specify NaN pivot ordering.

---

# 20. Empty matrices

Every complex public area deliberately covers:

```text
0x0
0xN
Mx0
```

Do not assume real empty dispatch is automatically correct for complex payloads.

---

# 21. Scalar normalization

Where project convention normalizes 1x1 real matrix results to scalar payloads, apply the analogous complex scalar normalization consistently.

Audit before assuming.

---

# 22. Threading / optimized backend policy

M20 identified optimized complex worker precision as high risk.

For every enabled optimized complex path:

```text
audit worker entry
audit p_op establishment
audit default temporaries
```

If only reference `libmplapack_mpfr` is tested, document that.

Do not claim optimized complex support unless audited.

---

# 23. Dependency modification boundary

Allowed during C00-C12:

```text
gmpfrxx_mkII
mplapack
octave-mplapack
```

only for real correctness needs of complex implementation.

Forbidden:

```text
octave-mplapack-ppa
Debian packaging
Launchpad upload
PPA version strings
```

---

# 24. Upstream fix record

For every upstream fix, append to `docs/complex-backends.md`:

```text
Repository
Problem
Reproducer
Topic branch
Fix commit
Tests
First milestone requiring it
```

C12 records final tested dependency commits.

D00 freezes versions/tags/archives.

---

# 25. MPLAPACK 3.0.1 is the planned release version.

However, do not freeze the 3.0.1 release commit/tag before the
complex C00-C12 implementation has completed.

If complex implementation discovers required gmpfrxx_mkII or MPLAPACK
fixes, those fixes should be completed and fully regressed before the
MPLAPACK 3.0.1 release commit is frozen.

D00 owns the final 3.0.1 commit/tag/archive/SHA256 decision.

---

# 26. Do not package gmpfrxx_mkII yet

Likewise determine the exact required/fixed gmpfrxx_mkII commit through C00-C12.

No Debian package/version yet.

D00 will freeze:

```text
gmpfrxx_mkII commit/tag/version/archive/SHA256
MPLAPACK commit/tag/version/archive/SHA256
octave-mplapack commit/version/archive/SHA256
```

before PPA work.

---

# 27. Controller progression

After each milestone:

```text
PASS
 -> commit report/status
 -> push if workflow permits
 -> continue automatically

proven upstream defect
 -> fix upstream
 -> validate
 -> update provenance
 -> resume same milestone

downstream defect
 -> fix octave-mplapack
 -> rerun milestone

unresolved external blocker
 -> stop with exact BLOCKED classification
```

Do not stop merely because a test fails initially.

---

# 28. Minimal user round trips

Do not ask for confirmation between C00-C12.

Do not ask "continue?" after PASS.

Use the preferred defaults in this document when a choice is already provided.

Stop only for a genuine blocker that cannot be solved with the available repositories/environment.

---

# 29. Git discipline

Before milestone commits:

```bash
git status --short
git diff --check
```

Do not stage unrelated changes.

Do not commit:

```text
build artifacts
private credentials
PPA secrets
temporary prefixes
```

No force push.

---

# 30. Build/dependency isolation

After an upstream dependency fix:

```text
rebuild/install gmpfrxx_mkII if needed
rebuild/install MPLAPACK against intended gmpfrxx
verify headers/pkg-config/runtime
build octave-mplapack
```

Detect stale `/usr/local`, `/tmp`, or old-prefix selection.

Record exact runtime identity.

---

# 31. Sanitizer policy

Add sanitizer coverage as native paths appear.

At minimum relevant sanitizer runs at:

```text
C00
C02
C05
C06
C07
C08
C09
C10
C11
C12
```

Do not defer memory safety entirely to C12.

---

# 32. Common milestone report

Each report:

```text
# Cxx RESULT

Repository:
Branch:
Starting commit:
Final implementation commit:
Branch tip:
PR:

## Dependency identity
- gmpfrxx_mkII:
- MPLAPACK:
- pkg-config:
- runtime SONAME:

## Scope
- implemented:
- deferred:

## Architecture
...

## Precision
...

## Public semantics
...

## Native/backend audit
...

## QA
- native:
- public:
- 1024:
- 2048:
- ambient low:
- ambient high:
- ASan:
- UBSan:
- LSan:
- full real regression:

## Upstream fixes
...

## Gates
...

Cxx PASS / FAIL / BLOCKED

## Known limitations
...

## Recommended next action
...
```

---

# 33. C12 D00 handoff

C12 final report must record:

```text
REAL_V0_1_RC_COMMIT
COMPLEX_START_COMMIT
COMPLEX_FINAL_COMMIT

gmpfrxx_mkII final tested commit
MPLAPACK final tested commit
octave-mplapack final tested commit

all upstream fixes
supported complex API
unsupported complex API
real regression
complex regression
precision regression
TLS/thread regression
sanitizers
package lifecycle
```

D00 section:

```text
gmpfrxx_mkII commit to freeze:
MPLAPACK commit to freeze:
octave-mplapack commit to freeze:

dependency version numbers:
NOT YET ― D00

Debian/PPA packaging started:
NO
```

---

# 34. Master completion gate

Complete only if:

```text
C00 PASS
C01 PASS
C02 PASS
C03 PASS
C04 PASS
C05 PASS
C06 PASS
C07 PASS
C08 PASS
C09 PASS
C10 PASS
C11 PASS
C12 PASS
```

C11L PASS.

Final:

```text
COMPLEX GOAL PASS
REAL-COMPLEX-API-CLOSED
DEPENDENCY-FREEZE-READY
```

---

# 35. Stop after C12

Do not begin D00 automatically.

Do not begin Debian/PPA packaging.

Do not upload to Launchpad.

Do not modify `octave-mplapack-ppa`.

Do not create final dependency tags/releases.

The next separate goal is:

```text
D00 ― Dependency Release Freeze
```

Then:

```text
PPA1-G -> PPA1-M -> PPA2 -> PPA3 -> PPA4
```

---

# 36. Final master report

Produce:

```text
# COMPLEX C00-C12 RESULT

REAL_V0_1_RC_COMMIT:
COMPLEX_START_COMMIT:
COMPLEX_FINAL_COMMIT:

## Milestones
- C00:
- C01:
- C02:
- C03:
- C04:
- C05:
- C06:
- C07:
- C08:
- C09:
- C10:
- C11:
- C11L:
- C12:

## Final API
...

## Final dependency development heads

### gmpfrxx_mkII
- commit:
- fixes:

### MPLAPACK
- commit:
- fixes:

### octave-mplapack
- commit:
- version:

## Precision contract
...

## Real regression
...

## Complex regression
...

## Sanitizers
...

## Compatibility firewall
...

## Known limitations
...

## D00 handoff
...

COMPLEX GOAL PASS / FAIL / BLOCKED

Release conclusion:
REAL-COMPLEX-API-CLOSED / NOT-CLOSED

Dependency conclusion:
DEPENDENCY-FREEZE-READY / NOT-READY
```

Stop after this report.
