# SVT matrix definitions, exactness, and references

All indices in formulas below are mathematical indices, explicitly zero- or
one-based. Translate to Octave without changing the convention. Case sizes and
parameters are in `cases.json`. Do not substitute gallery defaults. Formula
variants and chosen parameters are suite adaptations unless an equation number
from a paper is explicitly identified.

## C0. Shared Hadamard mixing

For a power of two n construct Sylvester H by H1=[1] and
H(2n)=[H,H;H,-H]. Let G be H with rows cyclically shifted downward once.
Then H*H'=G*G'=n*I exactly. Define

    mix(B) = H*B*G'/n.

This is two-sided orthogonal equivalence, NOT an eigenvalue similarity. Avoid
forming sqrt(n) in the input constructor. For diagonal d>=0 the singular values
are d. Known projectors of an index group J are

    P_U = H(:,J)*H(:,J)'/n;
    P_V = G(:,J)*G(:,J)'/n.

These are exact dyadics when the significand bound covers the integer sums.
Do not require individual bases of a repeated group to match H or G columns.
Quarter-turn diagonal phases D_L,D_R preserve singular values and transform
projectors by D*P*D'. Global scale 2^s multiplies singular values by 2^s.

An exactness proof needs a common power-of-two denominator and an absolute bound
on all integer partial sums. Equality between two floating calculations is a
useful regression check, not a replacement for this proof.

## S1. NRO block matrices: two, three, and graded levels

Primary source [NRO11], Section 5. Use m a power of four in the required profiles.
Let w_j be nonnegative powers of two or zero and B=H_m*diag(w). Define

    A = [I_m, B; zeros(m), I_m].

All entries are 0, 1, or signed powers of two. All required native inputs are
exactly representable, including the scaled controls within their exponent range.
The inverse is exactly [I,-B;0,I], and det(A)=1. These are constructor invariants,
not permission to replace an SVD or a tested inverse solve by the formula.

Since (H_m/sqrt(m)) is orthogonal, beta_j=sqrt(m)*w_j are the singular values of B.
Each beta generates two singular values of A:

    a_j = (sqrt(beta_j^2+4)+beta_j)/2;
    b_j = 2/(sqrt(beta_j^2+4)+beta_j).

Use the second formula for the small value, never cancellation of square roots.
For beta=0, a=b=1 exactly. The singular values must be sorted together only in
the reference array. Reference projectors are optional except in focused tests.

Proof: apply left/right block orthogonal factors from a B SVD and a permutation;
the problem becomes independent [[1,beta],[0,1]] blocks. Their singular values
are a and 1/a. This stable reference formula is an algebraic consequence of the
paper's block construction, not a transcription of a published test parameter.

Required variants:

- two-level: w_j=2^b for all j;
- three-level: first m/2 weights 2^b, remaining weights zero;
- graded: w_j=2^(g*(j-1)), j=1..m.

Smoke: m=4,b=12,g=4. Demo: m=16,b=40,g=3. Thus the two-level demo is 32-by-32,
has entries only 0,1,+/-2^40, beta=2^42 and condition approximately 2^84.
Do not demand native failure. The three-level case has true unit singular values
as well as reciprocal extreme groups; multiplicities are intended.

Test A*inverse_formula=I exactly at sufficient precision, full rank by proof,
reciprocal pairing, and no input conversion error in native. Add the b=0 small
case. Do not assert that any arbitrary specified spectrum can be realized by
bounded integer entries: the paper's freedom is constrained.

## S2. Jacobi--Stirling second-kind matrix

Primary source [JS14]. Fix z=1. For mathematical i,j=0..n-1 define J(i,j)=JS_i^j(1),
with J(0,0)=1, J(i,0)=0 for i>0, J(0,j)=0 for j>0, and

    J(i,j) = J(i-1,j-1) + j*(j+1)*J(i-1,j),  1<=j<=i.

Upper-triangular entries are zero. The leading 5-by-5 fixture is

    1 0  0   0 0
    0 1  0   0 0
    0 2  1   0 0
    0 4  8   1 0
    0 8 52  20 1

The matrix is unit lower triangular and det=1. Do not discard the leading 1-by-1
block without changing the case ID. The literature sometimes calls matrices with
all nonnegative minors "totally positive"; this suite uses "totally nonnegative"
for triangular matrices with structural zero minors. Do not assert strict positivity
of every minor of this triangular matrix.

Use additions/multiplications on MP integers. A conservative exactness budget is

    p_min = 3 + sum(ceil_log2(1+r*(r+1)), r=1..n-1).

Here ceil_log2 is computed on exact small integer arguments by comparisons, not a
rounded logarithm at a power-of-two boundary. A row-sum/product bound controls
all positive intermediates. Prove the bound and verify equality with a wider
construction. Test n=1 and small known rows. Smoke n=8; demo n=16.

Reference: high-precision SVD, then V1-certified intervals for the actual exact
matrix. A structured HRA comparator may corroborate but is not required. Do not
claim the generic dense driver implements the paper's bidiagonal-factor method.

## S3. Unsigned Lah matrix

Primary source [LAH19]. For i,j=1..n,

    L(i,j) = binomial(i-1,j-1) * i! / j!  for j<=i, else 0.

Generate by L(1,1)=1 and

    L(i,j)=L(i-1,j-1)+(i+j-1)*L(i-1,j),

with out-of-range entries zero. Do not evaluate factorials in binary64. The first
four rows are [1], [2,1], [6,6,1], [24,36,12,1]. Unit lower triangular, det=1.
A conservative budget is `p_min=3+sum(ceil_log2(2*i),i=2..n)`; a maximum-entry
recurrence gives the proof. Smoke n=8; demo n=20.

Do not infer exact construction merely because values have no printed fraction.
A rounded lower-triangular matrix may remain exactly full rank while its small
singular values change. Its unit diagonal does establish full rank; it does not
establish spectral accuracy. Reference and HRA attribution rules are as for S2.

## S4. Diagonally dominant path pair

Relevant class theory: [DD11]. The selected path formulas are suite adaptations.
For tau=2^-b and rho>0 dyadic define the n-by-n tridiagonal A:

    A(1,1)=1+tau;        A(1,2)=-1;
    A(i,i-1)=-rho;       A(i,i)=1+rho+tau; A(i,i+1)=-1 (2<=i<n);
    A(n,n-1)=-rho;       A(n,n)=rho+tau.

Use rho=1 for the symmetric case, rho=1/2 for the nonsymmetric case. Each row's
diagonal dominance margin is tau. For b>=1, p>=b+2 suffices for exact input.
Smoke n=8,b=32; demo n=24,b=160. The p=128 demo is intentionally below the guard:
it solves the explicitly labeled rounded tau=0 input. Native tau loss is also
intentional. Build and compare the exact high-precision model separately.

For rho=1, A is SPD and its ascending singular values are

    tau + 4*sin(k*pi/(2*n))^2, k=0..n-1.

Set k=0 to exactly tau. Generate pi/trigonometric quantities in MP, not native.
The positive-term form avoids cancellation in 2-2*cos. These numerical sine
values are analytic-reference evaluations, not certified transcendental intervals;
certify the spectrum independently with V1. The exact minimum tau is a strong
special check.

For rho=1/2, do NOT assert sigma_min=tau. A*ones=tau*ones determines an eigenvalue,
not a singular value. Use high-precision SVD plus a certified reference.

For tau=0 the leading j-by-j principal determinants, j<n, are exactly 1 by the
tridiagonal determinant recurrence; the full determinant is zero. Thus the frozen
rounded matrix has exact rank n-1. This justifies an exact zero reference in this
specific case, not in other rounded cases. For tau>0 strict row diagonal dominance
proves nonsingularity. A density or triangularity shortcut must not replace svd.

## A1. Pascal pair

Relevant source [PAS13], plus [TN05] for SVD use of the nonnegative factor data.
For 1<=i,j<=n:

    Q(i,j)=binomial(i-1,j-1) if j<=i, otherwise 0;
    P(i,j)=binomial(i+j-2,i-1).

Generate binomial values through Pascal addition, not native nchoosek/factorial.
Prove and test P=Q*Q' exactly at sufficient precision. Both det=1. Q is unit lower
triangular and P is symmetric positive definite. Budget p_min=n+2 for Q, 2*n+2
for P is conservative. Smoke n=8; demo n=24.

The Pascal paper explicitly demonstrates eigenvalues, inverses and systems; the
SVD fixture here also relies on the general TN SVD framework. Do not call the SVD
run a numerical table reproduced from the Pascal paper.

Numerical cross-check: sorted singular values of P equal the squares of those of
Q mathematically. Compare with sufficient precision or enclosing arithmetic.
This exact cross-family identity does not authorize forming A'*A as a generic
SVD oracle. V1 remains the certification path.

## A2. Dyadic Vandermonde

Relevant source [TN05]. For positive increasing nodes x_i=i/2^d with n<2^d,

    V(i,j)=x_i^(j-1), 1<=i,j<=n.

Build successive powers in work MP arithmetic. Sufficient exactness budget:
`p_min=2+(n-1)*ceil_log2(n)`. Common dyadic denominators and integer powers give
this bound. Smoke n=8,d=4; demo n=16,d=5. Verify distinct nodes and determinant
product positivity algebraically; do not impose a determinant-based accuracy gate.
Native rounding may change entries; do not assert a rank without proof.
Reference: consistent high precision followed by V1 certification. A TN algorithm
fed exact/accurate factor parameters is a different computation from dense svd(V).

## A3. Graded bidiagonal and mixed partner

For a>=1 define

    B(i,i)=2^(-a*(i-1));
    B(i,i+1)=2^(-a*(i-1)-1), i<n;
    A=mix(B).

The raw B entries each have a one-bit significand. For mixed A a common denominator
2^(a*(n-1)) applies, and the sum of absolute B entries is <=3. All Hadamard product
partial sums are bounded by this sum. Thus p_min=a*(n-1)+4 is sufficient for exact
construction; division by n is exact exponent scaling. Smoke n=8,a=4; demo n=16,a=8.

The exact singular spectra of raw/mixed forms agree. Compare them through certified
references, not by substituting one work solve for the other. [LAPACK-LASQ1] describes
bidiagonal HRA, not an unconditional guarantee for dense reduction. An existing
accessible LASQ1 comparator is optional; do not add a binding for this task.

## A4. Lauchli, tall and wide

For mu=2^-b define T=[ones(1,n);mu*eye(n)], shape (n+1)-by-n, and W=T'.
All nonzero entries are exactly representable in the required ranges. Spectrum:

    sqrt(n+mu^2), followed by n-1 copies of mu.

Smoke n=4,b=20; demo n=8,b=100. Right projector of the repeated small group in T
is I-ones(n)/n; left projector is blockdiag(0,I-ones(n)/n). W swaps them. Generate
these projectors exactly. The extra full-SVD null direction is not an additional
listed singular value in economy mode.

Named negative control: construct native T'*T and compare it to the MP model
ones(n)+mu^2*I. Log raw eigenvalues; never use sqrt(abs(eig(...))) as an oracle.
No claim that direct native SVD must fail: preserving mu rather than mu^2 is the
point. In demo, also test a quarter-turn-phased version of T, defined below.

## A5. Known spectra, close/repeated groups, and exact rank

Use mix(diag(d)) from C0.

- geometric: n=8,a=4 smoke; n=16,a=8 demo; d_j=2^(-a*(j-1)).
  Budget p_min=a*(n-1)+ceil_log2(n)+2.
- close pair: n=8, d=[4,2,1+delta,1,1/2,1/4,1/8,1/16],
  delta=2^-32 smoke or 2^-100 demo.
- repeated pair: same d with delta=0.
- rank-four: n=8,d=[1,1/2,1/4,1/8,0,0,0,0].
- rank-five: n=8,d=[1,1/2,1/4,1/8,eta,0,0,0],
  eta=2^-32 smoke or 2^-100 demo.

A sufficient bound for close/rank examples is b+ceil_log2(n)+5 where a perturbation
2^-b is present; use an analogous small bound when it is absent. Keep parameters
rational/dyadic, not decimal constants parsed through binary64.

The close/repeated group is J={3,4}. Null groups are J={5,6,7,8} or {6,7,8} for
the rank fixtures. Model rank is known by construction. V1's generic positive
cluster verifier does not certify null-space multiplicity from tiny approximate
singular values; use the exact model-rank proof and known projectors for these
model-specific ordinary tests. Report this distinction.

V2 individual-factor boxes are not identifiable for the repeated pair. A close
but separated pair may become verifiable at high enough precision, but a small
internal gap must explicitly appear in the bounds. Rank and near-rank are not
interchangeable.

## A6. NRO bounded-integer companion-like construction

Primary source [NRO11], Section 4, equations (41), (44), (47), (52), (55), (59).
Use integer nu>=2, set k_i=(-1)^(i-1), i=1..n-1, and k_n=1. Let

    a_1=k_1;
    a_i=k_i-nu*k_(i-1), 2<=i<=n.

The first row of C is [a_1,...,a_n]. For i=2..n set C(i,i-1)=1, C(i,i)=-nu;
all other entries are zero. This is a deterministic selection within the paper's
construction, not a reproduction of every sign/parameter choice in its generator.
All entries satisfy abs(C(i,j))<=nu+1. The input uses only small integers.

The Horner recurrence h=a_1; h=h*nu+a_i for i=2..n ends at k_n=1, hence

    det(C)=(-1)^(n-1).

Check intermediate h=k_i, not a floating near-zero determinant. Smoke n=8,nu=16;
demo n=16,nu=256. These native inputs are exactly representable. A sufficient
input/construction budget is ceil_log2(nu+1)+3. Full rank follows exactly.

Reproduce the separate published equation-(82) 4-by-4 fixture and inverse:

    C = [1 -6 7 -9; 1 -5 0 0; 0 1 -5 0; 0 0 1 -5];
    X = [125 -124 130 -225; 25 -25 26 -45; 5 -5 5 -9; 1 -1 1 -2].

Test C*X=X*C=I exactly. Do not require its rounded printed singular values from
the paper as an oracle. Main references use high-precision SVD and V1-certified
intervals. The explicit inverse fixture also tests V3 against a provable inverse.

## Controls and common exactness checks

Complex demo: multiply the tall Lauchli case by D_L on the left and D_R' on the
right, diagonal entries cycling [1,i,-1,-i]. Construct real/imaginary integer parts
through the audited public complex API. Singular values are unchanged. Transform
known projectors with the same phases and preserve conjugate-transpose semantics.

Scaling demo: multiply NRO two-level by 2^600 and by 2^-600, separately. Model and
native matrices remain representable; metrics are evaluated in MP to avoid native
squaring overflow/underflow. Verify exact unscaled recovery by inverse power-of-two
scaling. Time the actual requested matrix, not an unscaled surrogate.

Stress choices in the manifest are additional experiments, not guaranteed targets.
Construct exact bit budgets before enabling them. Reject inconsistent settings.
Reference maxima are fixed; do not silently double until a desired result appears.

For each constructor test n at its lower supported boundary, dimensions, analytic
rank where available, exactness across two sufficient precisions, alias preservation,
precision cleanup on error, and a deliberately insufficient-precision request.
Do not impose performance thresholds or assert that all ill-conditioned fixtures
must exhibit the same failure mode.
