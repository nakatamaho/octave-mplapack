# Matrix cases: exact definitions, spectra, and independent checks

All indices below are one-based unless stated otherwise. `cases.json` fixes the
parameters. These are literature-derived deterministic fixtures, not claimed
reproductions of the papers' numerical tables. All model entries are integers or
dyadic rationals. Exact representability still requires enough significand bits.

## 0. Shared exact algebra

N_n has N(i,i+1)=1, all other entries zero. H is the recursively generated Sylvester
Hadamard matrix: H_1=[1], H_2m=[H_m,H_m;H_m,-H_m]. H*H'=n*I exactly.
R is the reversal permutation matrix. Use exact small integers and powers of two.

Use the exact inverse pair X=(I+N')*(I+N), Y=(I+N)^(-1)*(I+N')^(-1).
Inverses are finite sums of powers of the strictly triangular parts. A=Y*J*X.
Do not substitute a numerical inverse for this exact construction.

For a real/complex exact dyadic product or sum, determine a sufficient evaluation
precision before computing it. Put scalar terms over their common power-of-two
denominator. If all integer terms have bit lengths <=b and there are t terms,
`b+ceil_log2(max(1,t))+2` bits suffice for their sum. A product needs the sum of
operand integer bit lengths plus a sign guard. Apply this to both matrix-product
stages, including intermediates, then cancel powers of two only after the audit.

The implementation may conservatively overestimate these guards. It must record
them, reject insufficient exact-model precision, and verify equality after exact
promotion. Cross-precision agreement by itself is not an exactness proof.

For a normal work-precision construction below its guard, round an already exact
model once, mark `rounded_model`, and preserve the changed matrix. Do not perform
multiple low-precision polynomial/generator operations then call the resulting
input the once-rounded model. OO generation is its own specified RN procedure.

## 1. OO53_REAL, OO53_PAIR, OO128_CLOSE [S1]

Use GENERATOR-OO.md, including realized-spectrum storage and fixed generation
precision. The exact triple-product generator is mandatory, not a generic fallback.

## 2. Exact similarities [S2]

Use the inverse pair from Section 0. Fill unassigned diagonal entries after each
cluster with 4,5,6,... in order, all distinct and separated from the target clusters.
Use these J variants:

- `SIM_SIMPLE`: leading block [1,1;0,1+d], d=2^-a. Other entries diagonal.
  All roots are simple; this is near-defective but diagonalizable.
- `SIM_REPEAT`: leading block I_2. Other entries diagonal. The repeated root is
  **semisimple**, algebraic and geometric multiplicities both 2.
- `SIM_JORDAN`: leading block [1,1;0,1]. Other entries diagonal. Root 1 has
  algebraic multiplicity 2 and geometric multiplicity 1.
- `SIM_TWO_JORDAN`: leading two Jordan blocks of size 2 at 1 and 1+d, d=2^-a;
  remaining entries diagonal 4,5,... . Keep two-cluster and merged-cluster queries.

Spectrum and Jordan multiplicities follow directly from J. The invariant subspace
for a whole selected block is range(Y(:,J_indices)). A simple right vector is
Y*v_J, a left column is X'*w_J; preserve complex conjugation if complex controls
are added. For SIM_SIMPLE, a 2x2 triangular solve yields exact dyadic/rational
vectors; the checker may instead use symbolic projectors or a high-precision
reference. Never claim Y's coordinate columns individually diagonalize its
non-diagonal 2x2 simple block.

Model projectors are **orthogonal** projectors onto those ranges, constructed by
high-precision QR for ordinary comparison. Their numerical evaluation is not a
certificate; Tier V proves its own bounds without assuming the model answer.
An oblique spectral projector Y(:,J)*X(J,:) is a different object, though exactly
idempotent and commuting with A for a union of full J blocks. Label it separately.

Tests: exact AX? Use `X*A=J*X` and `A*Y=Y*J` exactly. Verify small characteristic
polynomials at integer arguments independently, along with the nilpotency order
of the target block. A zero eigengap must not be treated as a simple-root failure
of the solver. A full eigenbasis cannot exist in the Jordan cases.

## 3. Tridiagonal Toeplitz and symmetric control [S3, NPT13]

```text
A = tridiag(1, 3, 2^(-2*b))
D = diag(2^(b*j), j=0..n-1)
B = tridiag(2^-b, 3, 2^-b)
D^(-1)*A*D = B
```

Construct B directly, not by a numerically computed inverse. Test A*D=D*B exactly.
For theta_k=k*pi/(n+1),

```text
lambda_k = 3 + 2^(1-b)*cos(theta_k)
v_jk = 2^(b*(j-1))*sin(j*theta_k)
w_jk = 2^(-b*(j-1))*sin(j*theta_k)
```

At reference precision evaluate MP pi/sin/cos, not native constants. Independent
symmetric eig(B) is a reference cross-check. Set any exact symmetry endpoints
consistently. Compute norms and overlaps of the analytic vectors in MP, then
compare the individually normalized computed vectors up to a phase/sign when
resolved. The analytic overlap is (n+1)/2 before column normalization.

For b=4, the normwise matrix-condition upper bound is 1025/511, although the
similarity scaling condition is 2^(4*(n-1)). Do not call that latter number the
condition of each eigenvalue. Compute individual left/right conditions explicitly.
The symmetric representation is a different coordinate system with different
sensitivity and pseudospectrum. Original-coordinate output must stay labeled.

## 4. Forsythe split, scaled, and zero [S4]

For r=2^-a, eps=r^n:

```text
F = I+N; F(n,1)=eps
P = N; P(n,1)=1
F_scaled=I+r*P
D=diag(1,r,...,r^(n-1))
F*D=D*F_scaled
lambda_k=1+r*exp(2*pi*i*k/n), k=0..n-1
```

F_scaled is normal; construct it directly. Evaluate the circle in MP and set exact
real endpoints explicitly. Circle error means matching `(lambda-1)/r` to the
unit-circle roots, not ordinary relative error near 1.

`FORSYTHE_ZERO` is F=I+N with eps=0. It is a genuine size-n Jordan block.
No condition-number or unique-eigenvector success target applies. The whole-space
projector I is a trivial oracle and **cannot satisfy** the mandatory nontrivial
cluster-validation job by itself. Use SIM_JORDAN for that job.

In stress only, an eps below the native exponent range can underflow. Record it as
a changed input, not as an MP failure or exact-input native solve.

## 5. Hadamard-similar upper bidiagonal [A1]

```text
T(i,i)=i; T(i,i+1)=s
A=H*T*H'/n
lambda_k=k
```

n is a power of two. Do not solve T instead of A. The condition reference is

```text
kappa_k = sqrt(sum_{j=0}^{k-1} s^(2*j)/(j!)^2)
        * sqrt(sum_{j=0}^{n-k} s^(2*j)/(j!)^2).
```

Evaluate by MP multiplicative recurrences, not native factorials. Underlying right
and left vectors of T have v_i=s^(k-i)/(k-i)! for i<=k and
w_i=(-s)^(i-k)/(i-k)! for i>=k, both zero elsewhere; w'*v=1.
Use the exact product bit guard; mandatory cases are native-exact as well.

`HAD_COMPLEX`: Z=diag(1,i,-1,-i,...) and A_complex=Z*A*Z'. Spectrum and individual
conditions are unchanged. All components remain dyadic. Test the complex left
identity, not a transpose-only version. This case is demo-only in the core manifest.

## 6. Frank orientations [A2]

```text
F0(i,j)=n+1-max(i,j) when j>=i-1; otherwise 0
F1=R*F0'*R
```

This explicitly fixes the reflected orientation. Compare with local gallery
variants only after inspecting their definition; do not change these formulas to
match a different flag convention. They are two orientations of one family.
Both are exact integer Hessenberg matrices with the same spectrum.

Independent symmetric reference: K has zero diagonal and
K(j,j+1)=K(j+1,j)=sqrt(mp(j)). If z is an eigenvalue of K, use

```text
f(z)=((z+sqrt(z*z+4))/2)^2                 when z>=0
f(z)=(2/(sqrt(z*z+4)-z))^2                when z<0.
```

The characteristic polynomial satisfies P0=1, P1=x-1,
Pn=(x-1)P(n-1)-(n-1)*x*P(n-2). This follows from the probabilists' Hermite
recurrence under z=(x-1)/sqrt(x). Check small determinants independently:

```text
n=2: [1,-3,1]
n=3: [1,-6,6,-1]
n=4: [1,-10,21,-10,1]
n=5: [1,-15,55,-55,15,-1]
```

Check positivity, reciprocal pairing, and the odd-order central root 1. Use maximum
relative as well as absolute error. A small determinant error alone is not enough.

## 7. Wilkinson companion and coefficient diagnostics [A3]

p_n(z)=product(z-j,j=1..n)=z^n+c1*z^(n-1)+...+cn. Form the Frobenius matrix
with first row -[c1,...,cn], ones on the first subdiagonal, all other entries zero.
Build coefficients using exact integer recurrence, with sufficient precision.
A conservative generation guard is n*ceil_log2(n+1)+2. A high-precision Horner
check at integer roots needs at least 2*n*ceil_log2(n+1)+32 bits for exact
intermediates. Do not use `mp(poly(1:n))` or `poly(eig(A))` as exact construction.

Frozen native companion coefficients may differ from the exact polynomial.
For a computed root z, report the rootwise **complex coefficientwise** backward
error indicator

```text
eta_poly(z) = abs(p(z)) / sum_{j=0}^n abs(c_j)*abs(z)^(n-j), c_0=1.
```

It permits relative perturbations of all nonzero coefficients, including c0; it
is not the constrained-monic or real-coefficient backward error. Zero coefficients
stay zero under this definition. The denominator-zero case is explicitly handled.
Use a safely evaluated Horner denominator. Polynomial backward error does not
replace eigenvalue forward error or mean the dense eig uses companion QR/QZ [AMRVW18].
Evaluate both model and frozen-input coefficient indicators with explicit labels.

## 8. Grcar [A4]

G(i,j)=1 when 0<=j-i<=3; G(i,j)=-1 when i-j=1; otherwise 0.
Exact 0,+/-1 input. Use general high-precision eig references at two precisions,
and independent verification where required. No analytic spectrum is asserted.

Optional ordinary Toeplitz perturbation diagnostics may project w*v' onto the
Toeplitz linear space using its diagonal means and a declared Frobenius metric.
Such a metric is not automatically the structured spectral-norm condition number
from [R06]. The mandatory new feature is V-S3, not a loosely labeled contour plot.

## 9. Morimoto--Katori--Shirai model 1 [A5, MKS25]

For 1<=m<=n, delta>0 dyadic:

```text
A=N^m+delta*ones(n)
ell=floor((n-1)/m)+1
q(z)=z^ell-delta*sum_{j=0}^{ell-1} (n-m*j)*z^(ell-1-j)
char_A(z)=z^(n-ell)*q(z).
```

Use the polynomial form, never a rational formula singular at z=1. Its constant
coefficient is -delta*(n-m*(ell-1))!=0. Hence zero has **exact algebraic
multiplicity n-ell**. In the mandatory m=3 cases it is defective. Distinguish the
geometric multiplicity m-1 (m<n) from algebraic multiplicity.

Reference: construct q's dyadic coefficients exactly and solve the much smaller
companion problem at two reference precisions; append exact model zeros only to
the reference, never to the computed eig output. Validate q's characteristic
identity at exact integer arguments for small n, using an independent determinant.
Check q and q' have no common factor for enabled nonzero-root simple fixtures,
using exact polynomial Euclidean arithmetic or an equivalent resultant check.
If that guard fails, use a declared cluster rather than inventing simple roots.

On the generalized zero-eigenspace the nilpotency order is at most ell. One way
to see the bound: A^ell has range in span{1,N^m*1,...,N^(m*(ell-1))*1}; A on
that controllability space has characteristic q with no zero root, so this space
has zero intersection with the generalized zero-eigenspace. Thus A^ell annihilates
that zero-eigenspace. This justifies the conservative leakage exponent used by the
engineering gate; the gate itself is not a universal theorem about an eigensolver.

Main examples: smoke n=12,m=3,delta=1/8; demo n=32,m=3,delta=1/8. Their nonzero
polynomial degrees are 4 and 11, and zero multiplicities 8 and 21. Verification
uses a separate small n=6,m=3 case to keep the graph checker tractable.

## 10. Markov and positive Perron controls [A6]

n=2h. Let C_h be the row cyclic permutation, C(i,i+1)=1 with wraparound.
Q=blockdiag((1-a1)I+a1*C_h, (1-a2)I+a2*C_h), a1=1/4, a2=1/8.
Let r_j=2^-j for j=1..n-1 and r_n=2^(-(n-1)). Thus sum(r)=1, r>0.
For eps=2^-a define

```text
P=(1-eps)*Q+eps*ones(n,1)*r'
```

All entries are positive and P*1=1 exactly **for the exact model**. P is not
assumed normal. Its spectrum consists of

```text
1; 1-eps;
(1-eps)*(1-a_b+a_b*exp(2*pi*i*k/h)), b=1,2, k=1..h-1.
```

Derivation: rank-one teleportation preserves the induced map on the quotient by
span(1), while replacing one eigenvalue 1-eps by 1. The other block-constant mode
has eigenvalue 1-eps. All other modes have modulus strictly below 1-eps. Thus the
model's modulus spectral gap is eps; require h>=2.

The stationary row is eps*r'*(I-(1-eps)*Q)^(-1); use a linear solve, not an inverse
product, for its numerical reference. It is not equal to r' for these fixtures.
Also compute it independently by a normalized stationary linear system.
Do not use the formula as a certificate without verifying the solve.

`PERRON_POS`: D=diag(2^j,j=0..n-1), A=(3/2)*D*P*D^(-1), constructed by exact
row/column binary scaling. Its Perron root is 3/2; it is positive but not row
stochastic. Spectrum scales by 3/2, right Perron vector is proportional to D*1,
left is proportional to D^(-1)*pi. Verify normalization separately.

A frozen rounded P need not remain **exactly** row-stochastic, even if printed row
sums look like 1. Small positive teleportation entries can survive while subtraction
from large diagonal entries is lost. Never force eigenvalue 1, replace a row sum,
or infer reducibility from rounding without proof. Main MP cases have enough
precision; native cases require input accounting.

## 11. Small verification-only targets

These do not count as core eig rows. All use the same constructors.
- SIM_SIMPLE, SIM_REPEAT, SIM_JORDAN, SIM_TWO_JORDAN at n=6 or 8 as in the V manifest.
- A 4x4 simple complex case Z*(Y*diag(1,2,4,8)*X)*Z', Z=diag(1,i,-1,-i).
- A 4x4 defective case with J2(1), 4, 8; for a nontrivial block Schur certificate.
- Pencils: choose B=I+N (real) or Z*(I+N)*Z' (complex), C a specified small model,
  and A=B*C exactly. The checker receives only A,B and approximate data; the known
  C is validation data, not an unchecked replacement for B^(-1)*A.
- Perron jobs at n=8, eps=2^-24 (smoke) or 2^-40 (demo), on P, P', A, A'.

Exact input identity is mandatory for each job; record any allowed native rounding
as a different target. Proof checkers must not receive a trusted root/multiplicity
field from a generator and use it instead of their own numerical proof predicates.


## 11. Small verification-only fixtures

These do not add measured core eig rows. Record all their solves as auxiliary.
Use the same integer X=(I+N')*(I+N), Y=X^(-1) construction as Section S2, with
independently verified exact products.

- VS2 semisimple/Jordan: n=6; leading I2 or J2(1), complement diag(4,5,6,7).
- VS2 two-Jordan: n=8; leading J2(1) and J2(1+d), complement diag(4,5,6,7).
- VS2 MKS: A=N6^3+(1/8)*ones(6). Zero multiplicity 4; reduced roots
  `(3+sqrt(33))/8` and `(3-sqrt(33))/8`, separated from zero. These roots are
  independent test information, not trusted inputs to the graph proof.
- VS3 inside target: n=4, A=Y*diag_blocks(J2(1),4,8)*X. Exact query z=1.
  Outside target: Grcar(8). Point/cell widths are in verification-jobs.json.
- VA1 real simple: n=4, J=diag(1,2,4,8), A=Y*J*X.
- VA1 complex simple: conjugate the preceding A by the diagonal matrix with
  entries [1,i,-1,-i]. This checks complex coordinates, not nonreal eigenvalues.
  Nonreal eigenvalues are already mandatory in OO53_PAIR and the VA2 complex job.
- VA1 defective: n=4, J=diag_blocks(J2(1),4,8), A=Y*J*X. Leading k=2.
- VA2 real simple: n=6, C=Y*diag(1,2,3,4,5,6)*X; B=I+N; A=B*C.
- VA2 complex simple: n=6, use J=diag_blocks([1,1/2;-1/2,1],3,4,5,6),
  C0=Y*J*X; conjugate C0 and I+N coherently by Z=diag(1,i,-1,-i,1,i),
  giving C=Z*C0*Z', B=Z*(I+N)*Z', A=B*C. The first roots are 1+/-i/2.
- VA2 defective: n=6, C=Y*diag_blocks(J2(1),4,5,6,7)*X; B=I+N; A=B*C.
  Certify the leading k=2 group and count the four complementary roots.
- VA3: the MARKOV and PERRON_POS recipes at n=8 and the profile's epsilon,
  including their transposes. All are strictly positive exact dyadic models.

`diag_blocks` above is mathematical block assembly, not an assumed public function.
Build via existing indexing/concatenation. Known X,Y and J are used for independent
constructor tests only; mandatory positive verification jobs prepare candidates
from the frozen target with numerical routines and prove every checker predicate.
