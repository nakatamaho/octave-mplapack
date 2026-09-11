# V-S / V-A: complete conservative verification baselines

## 0. Scope, method identity, and proof inputs

These are original conservative implementations of the requested verification
**targets**. They are not full implementations of [R22], [R01], [F21], [RO24],
[M14], or [M21]. Use the method IDs below and
`paper_algorithm_reproduction=false`. In particular the explicit Kronecker graph
checker can be much more expensive than the cubic algorithms in the papers.
It is restricted to the small jobs in the manifest, not a performance comparison.

A checker consumes exact represented target data (or a proved enclosure of one
fixed target), finite approximate candidates, a query and a precision contract.
It must not consume trusted exact roots, multiplicities, eigenvectors, or a
"known correct" status from a matrix constructor. Those are independent tests.
All arithmetic in a proof predicate is outward arithmetic from ARITHMETIC.md.

Norm notation: ||.||inf is induced matrix infinity norm, |Z|max is maximum entry
modulus, and vectorization uses column-major order. Norms/inequalities in formulas
below mean rigorous upper/lower evaluations, not ordinary rounded quantities.

## 1. V-S1: counted all-spectrum inclusion

Method: `neigt_similarity_gershgorin_v1`.

Inputs: target A, point candidate basis X, point inverse candidate R, point central
matrix T. Usually X is returned V, T is returned D; a separately logged QR/Schur
candidate is also allowed. No inverse is trusted without the residual test.

Compute enclosing E=I-RX and F=AX-XT. Let

```text
e >= ||E||inf
c >= ||R F||inf
require e < 1
eta = upper(c/(1-e)).
```

**Proof.** RX=I-E is nonsingular, so R and X are nonsingular.
`C=X^(-1) A X=T+(I-E)^(-1) R F`, hence ||C-T||inf<=eta.
Thus all eigenvalues of A are in the n disks

```text
center_i = T(i,i)
radius_i = upper(sum_{j!=i} abs(T(i,j)) + eta).
```

Keep the stronger row-norm perturbation bound eta here; do not accidentally claim
an elementwise eta bound gives a row bound eta rather than n*eta.

Build an overlap **supergraph**: omit an edge only after proving
`lower(abs(center_i-center_j)) > upper(radius_i+radius_j)`.
Otherwise include the edge. Each connected component is a union of disks and is
certifiably separated from all other components. It contains exactly as many
roots, counting algebraic multiplicity, as its number of indexed disks.

Counting proof: for C(t)=diag(T)+t*(C-diag(T)), 0<=t<=1, every Gershgorin disk
stays inside its indexed outer disk. No eigenvalue can pass between the separated
outer components. At t=0 the roots are the indexed centers. This proves exact
component counts and coverage of all n roots, including multiplicities.

Singleton components enclose one simple eigenvalue. A k-component does NOT prove
k equal roots, semisimplicity or defect. Duplicate candidate centers merge rather
than furnishing duplicate certificates for the same root. Broad full-spectrum
coverage is valid but may fail the usefulness gate.

For an interval enclosure of a fixed A, take the supremum bounds over that
rectangle; the same proof holds uniformly. Store target provenance explicitly.

Tests: exact diagonal, repeated diagonal, real complex-pair block, upper Jordan,
permuted candidates, X singular, R=0, wrong T, deliberately duplicated candidate
roots, touching disks, conservative overlap from uncertain distance, all n counts.
No nonrigorous condition estimate substitutes for e<1.

## 2. Shared certified similarity enclosure

For later checkers obtain a rectangular enclosure of the fixed
C=X^(-1) A X by the preceding residual formula:
C lies in T plus a complex entrywise modulus uncertainty <=eta. Rectangles
[-eta,eta]+i[-eta,eta] are conservative. Real inputs remain real intervals.
A directly enclosed inverse times A times X is also allowed, with its own proof.
Never use bare `X\(A*X)` as an exact C in a certificate.

## 3. V-S2: a verified invariant graph

Method: `neigt_riccati_graph_v1`.

Partition a certified C enclosure after k candidate columns, h=n-k:

```text
C = [C11 C12; C21 C22],  1<=k<n.
```

Seek a graph [I_k;Z] with h-by-k Z satisfying

```text
F(Z)=C21+C22*Z-Z*C11-Z*C12*Z=0.
M=C11+C12*Z.
```

In column-major vectorization let

```text
K = kron(I_k,C22) - kron(transpose(C11),I_h)
```

The transpose here is **nonconjugating**, even for complex matrices.
Form a finite point R_s approximating inverse(mid(K)) using public solves. K's
interval construction encloses the exact linear coefficient, not a central guess.
Set rigorous bounds

```text
e = ||I-R_s*K||inf
c = ||R_s*vec(C21)||inf
g = ||R_s||inf * k*h * max_entry_modulus(C12).
```

Find an exact positive dyadic t satisfying both

```text
upper(c+e*t+g*t*t) < t
upper(e+2*g*t) < 1.
```

Require e<1. One initial trial is the next power of two above 2*c/(1-e), with a
positive tiny dyadic floor when c=0. Candidate improvements, not unlimited radius
inflation, address failures. Use at most eight successive factor-two radius trials, starting from this
value; the positive floor is 2^(-floor(q/2)). Stop if the contraction bound reaches
one. Record all trials. A new candidate basis may restart this bounded schedule;
changing the input, query cluster or acceptance target is forbidden.

**Proof.** Define on the closed complex polydisk |Z|max<=t:

```text
Phi(z)=-R_s*vec(C21)+(I-R_s*K)*z+R_s*vec(Z*C12*Z).
```

Each entry of Z*C12*Z sums k*h terms, giving the g*t^2 bound. The difference of
quadratic terms for two Z values is bounded by 2*g*t times their vector infinity
distance. The two strict inequalities give a self-map and contraction. Banach's
theorem supplies a unique fixed point in this polydisk. e<1 makes R_s*K, and hence
R_s, nonsingular, so a fixed point solves F(Z)=0, not merely R_s*F(Z)=0.

With the exactly nonsingular X from Section 2,

```text
Y1 = X(:,1:k)+X(:,k+1:n)*Z
A*Y1=Y1*M.
```

Y1 has full column rank because [I;Z] does. Return interval boxes for Z, Y1 and M.
A modulus bound t may be embedded in a rectangle [-t,t]+i[-t,t] **after** the
polydisk contraction proof; do not replace a polydisk by that larger rectangle
in its Lipschitz argument without changing the bound.

### 3.1 Identify a spectral cluster, not just an invariant subspace

The exact graph similarity gives

```text
[I 0;-Z I] * C * [I 0;Z I] = [M C12;0 D2]
D2=C22-Z*C12.
```

Enclose M and D2 with intervals. Enclose their spectra by interval Gershgorin
disks with exact point centers and outward diagonal/off-diagonal radii.
If all chosen enclosing regions for M and D2 are certifiably disjoint, the target
has exactly k roots in the M region and Y1 spans its unique spectral invariant
subspace. Return CERTIFIED_CLUSTER. Without that separation return only
CERTIFIED_INVARIANT_BASIS with `not_identified`, not a counted isolated cluster.

A highly nonnormal Jordan block can have large Gershgorin disks even when its
roots form a tiny cluster. Therefore a second **mandatory** region bound is:
for any point c0 and integer j>=1,

```text
abs(lambda(M)-c0)^j <= ||(M-c0*I)^j||inf.
```

Enclose the matrix power and choose an exact dyadic radius rho with
`rho^j >= upper_norm`. Use j=block_dimension in the required defective jobs.
No transcendental root is needed: exponent search on powers of two gives a
rigorous, possibly factor-two conservative radius. This is a containing disk,
not proof all roots equal c0. Apply it to D2 blocks as useful as well.
The query center c0 is not assumed to be an eigenvalue; a wrong center simply
produces a poor region. Region separation still must be proved.

### 3.2 Orthogonal-projector error bounds

Let X1=X(:,1:k), X2=X(:,k+1:n),

```text
g1 >= ||X1'*X1-I||F; require g1<1
alo <= sqrt(1-g1), strictly positive
b >= ||X2||2 * sqrt(h*k)*t.
```

If b<alo, range(Y1) differs from range(X1) by the spectral-norm sine-of-angle bound
b/(alo-b). Consequently the Frobenius orthogonal-projector difference is at most
sqrt(2*k)*b/(alo-b). The **raw** X1*X1' has an additional Frobenius discrepancy
<=g1 from the orthogonal projector onto range(X1). Return their sum as the bound
relative to raw columns. If using a nonorthogonal X1 with g1>=1, the existence
certificate may still hold; prepare a better candidate for this projector claim.

Proof: `(I-P_X1)*Y1=(I-P_X1)*(X2*Z)` and sigma_min(Y1)>=alo-b; apply the
pseudoinverse to an orthonormal basis of range(Y1). For equal-dimensional spaces,
projector norm equals the sine norm; Frobenius is <=sqrt(2*k) times that norm.
This is a geometric range bound, not a Hermitian eigenvalue-gap theorem applied
to a nonnormal matrix.

Tests: semisimple repeat, true Jordan cluster with separated complement, nearby
clusters merged, wrong selected dimension, zero outer separation, bad transpose
in a complex K, nonzero C12 quadratic term, wrong radius and singular R_s.
The nilpotent power bound must be checked independently on exact small blocks.

## 4. V-S3: pseudospectrum points and cells via verified SVD

Methods: `neigt_svd_pseudospectrum_point_v1`, `neigt_svd_pseudospectrum_cell_v1`.
Use the closed complex-perturbation 2-norm definition:

```text
z belongs to sigma_eps(A) iff sigma_min(z*I-A) <= eps, eps>0.
```

Freeze B=zI-A as an exact matrix expression. If zI-A is not exactly representable
at candidate precision, retain the expression enclosure and do not silently
replace its certificate target by its rounded candidate. The proof residual
must enclose the exact difference, either by exact higher-precision construction
with a bit guard or by interval expression evaluation from exact z,A.

Reuse the audited SVT polar/Weyl verifier, or implement this required baseline:
for returned SVD candidates U,s,V of the rounded approximation to B, verify

```text
gU >= ||U'*U-I||F < 1; gV >= ||V'*V-I||F < 1
r  >= ||B-U*diag(s)*V'||F
s is finite, nonnegative and descending
fU = gU/(1+sqrt(1-gU)); fV=gV/(1+sqrt(1-gV))
delta = r+s(1)*(fU*sqrt(1+gV)+fV).
```

Polar factors Q_U,Q_V have ||U-Q_U||F<=fU and ||V-Q_V||F<=fV, and
`B0=Q_U*diag(s)*Q_V'` has exactly s as singular values. The displayed delta bounds
||B-B0||2. Weyl's singular-value inequality therefore gives
`lower=max(0,lower(s(end)-delta))`, `upper=upper(s(end)+delta)`.
No Gram matrix B'*B is used as an eig oracle. The Gram matrices of candidate
U/V are proof data, not normal-equations SVD.

If upper<=eps -> CERTIFIED_INSIDE; if lower>eps -> CERTIFIED_OUTSIDE; otherwise
INCONCLUSIVE. Do not force a boundary point to one side by a tolerance.
For a closed cell centered at z0 with every point within a certified distance d,
1-Lipschitz continuity of sigma_min(zI-A) gives [max(0,lower-d),upper+d].
Classify the whole cell using the same predicates. A rectangle with halfwidths
hx,hy may conservatively use d=hx+hy. A finite grid is not a boundary certificate.

Mandatory checks include an inside point at an exactly known simple/Jordan root,
an outside point selected beyond a verified norm bound, an inside and outside
cell, Grcar point probes, and an intentionally straddling scalar interval sent to
the classification helper. Store all B/candidate/proof identities. Underlying SVD
preparation calls are counted separately from core eig timings.

## 5. V-A1: compatible eigenfactors and Schur/block-Schur boxes

Methods: `neigt_eigenfactor_boxes_v1`, `neigt_interval_qr_schur_v1`,
`neigt_interval_qr_block_schur_v1`.

### 5.1 Compatible full simple eigenfactorization

For each simple isolated root use the graph checker with k=1 and an appropriately
permuted point candidate basis. Obtain a column enclosure for a true e_i and a
scalar enclosure for lambda_i. Require n mutually disjoint certified eigenvalue
regions, so the actual e_i are linearly independent and are compatible columns of
one E satisfying A E=E Lambda.

Assemble interval E and Lambda. Verify nonsingularity uniformly over E's enclosure
using an inverse candidate and the Neumann test. Enclose its inverse, then define
W=(E^(-1))'. This proves simultaneous existence of

```text
A*E=E*Lambda; W'*A=Lambda*W'; W'*E=I.
```

The right vectors have the graph's gauge, not automatically unit norm. The left
factor uses dual normalization. These are not automatically boxes about the
original independently normalized W returned by eig. Report exact centers/gauges
and optionally transform its approximate columns before comparing.

Independent signs/phases must not break the proof. Duplicated or non-isolated
roots cannot satisfy the all-simple factor contract. Return individual-vector
non-identifiability as a domain reason and retain any cluster certificate.

### 5.2 Genuine Schur factors on the separated simple case

Evaluate **exact mathematical Gram--Schmidt/QR through interval arithmetic** on
the verified E box in its fixed column order. Each step encloses the exact
projection sums, residual column and positive Euclidean normalization. Every
normalization norm must have a strictly positive lower bound. Complex inner
products conjugate their first argument. Norm squares are computed from sums of
real^2+imag^2, not a possibly nonreal interval self-inner-product guessed real.

For the actual compatible E, this exact procedure defines E=Q R with Q unitary
and R upper triangular with positive real diagonal. Thus
`T=R*Lambda*R^(-1)=Q'*A*Q` is upper triangular and A=Q*T*Q'.
Return interval Q,T. Lower-triangular entries of the true T are zero **by this
algebraic proof**; it is not numerical clipping of a returned Schur factor.
Use the direct interval Q'*A*Q to bound the allowed upper entries and intersect
only the analytically forced lower zeros. Optional interval RLambdaR^-1 is a
cross-check, not mandatory duplicate work.

This certifies an actual Schur decomposition, not merely a small triangular
residual. Interval dependency can make the procedure inconclusive; the required
small separated examples must nevertheless pass their width gates.

### 5.3 Defective cluster: only block Schur is claimed

From one certified graph let H=[Y1,X2], which is nonsingular since
H=X*[I,0;Z,I]. Enclose exact QR of H as above. Its first k columns span the
certified invariant subspace. Therefore T=Q'*A*Q has a zero lower-left (n-k)-by-k
block, although its leading k-by-k block need not be triangular or diagonal.
Return CERTIFIED_BLOCK_SCHUR. No full eigenbasis is asserted for the defective
block. This is mandatory alongside, not a replacement for, the true simple-case
Schur certificate.

Tests: real/complex 4x4 simple factors; coherent phases; wrong one-sided left
normalization; permuted eigenpairs; a 4x4 J2(1)+[4,8] block-Schur case; a repeated
root refusing individual factor identification; interval QR norm reaching zero.

## 6. V-A2: finite generalized pencils without an API assumption

Method: `neigt_verified_finite_pencil_v1`.

Target exact A,B with B nonsingular. Compute point candidates R_B for inverse B
and C0=B\A by public solves; these are auxiliary calculations, not a claimed exact
reduction. Verify

```text
eB >= ||I-R_B*B||inf < 1
fB >= ||R_B*(A-B*C0)||inf
etaB=upper(fB/(1-eB)).
```

Then C=B^(-1)A lies within entrywise modulus etaB of C0. This proves B nonsingular
and the pencil regular with n finite roots. Feed this proved enclosure to V-S1
and V-S2. Their uniform predicates apply to this one exact C. All resulting
claims bind the **original A,B**, not just the rounded C0.

Approximate eig(C0,mode) is a portable candidate source; label it
`solve_reduction_finite_pencil`, not a generalized QZ implementation. If audited
public eig(A,B) exists, it may supply an additional comparator/candidate. Its
absence does not skip these required jobs. No explicit production inverse or
new public binding is needed.

Generalized right/left residuals are A V-B V D and W'*A-D W'*B.
If a left column w_C for C is mapped to the pencil, w=B^(-*)w_C, through a public
solve and a verified enclosure for proof use. The compatible dual normalization
is W'*B*V=I, not W'*V=I. Keep solve and eig timings separate.

Subspace graph Y1,M satisfies A Y1=B Y1 M. Certify a simple real pencil, a complex
pencil, and a defective selected cluster. Reuse the factor enclosure when the
query requests vectors; do not claim full defective diagonalization.

If B is singular or cannot be proved nonsingular, this method returns
UNSUPPORTED_DOMAIN (proved singular input) or INCONCLUSIVE (failed sufficient
test). It does not certify infinite roots or treat failure as proof of singularity.
Test a known singular B and a poor R_B as separate negative cases.

## 7. V-A3: Perron root and normalized vector

Methods: `neigt_collatz_wielandt_v1`, `neigt_positive_pair_contraction_v1`.

Require a point real nonnegative A. Prove irreducibility using the graph of
strictly positive entries, or a strongly connected certified-positive subgraph
for enclosing data. Mandatory matrices are strictly positive. A mere observed
eigenvalue of largest modulus is not the structural proof.

For a point positive trial vector v, interval-evaluate all ratios (Av)_i/v_i.
Collatz--Wielandt gives

```text
min_i lower((Av)_i/v_i) <= rho(A) <= max_i upper((Av)_i/v_i).
```

That certifies the root, not its vector. For the latter, independently verify the
normalized nonlinear eigenpair equations with real unknown y=(x,lambda):

```text
F(y) = [A*x-lambda*x; sum(x)-1]
J(y) = [A-lambda*I, -x; ones(1,n), 0].
```

A center y0 comes from a logged eig candidate, real positive candidate preparation,
and normalization; raw eig outputs stay untouched. Form a point inverse candidate
R for J(y0). For an exact dyadic radius t>0 and real box Y=y0+[-t,t]^(n+1), compute

```text
c >= ||R*F(y0)||inf
e >= ||I-R*J(Y)||inf
require upper(c+e*t)<t and e<1
require lower(x_i in Y)>0 for every i.
```

**Proof.** The map y -> y-RF(y) maps the box into itself and is a contraction by
the real mean-value theorem and the displayed Jacobian bound. e<1 establishes
R nonsingular (at any fixed J in the box). Its unique fixed point solves F=0,
has positive x and unit sum. Irreducible nonnegativity therefore identifies this
positive eigenpair as the Perron pair. Intersect the lambda interval with the
independent Collatz--Wielandt interval; an empty intersection signals an error.

A bounded deterministic radius schedule may start above 2*c with a tiny positive
floor and try four doubled dyadic radii. Log each attempt and failed predicate;
do not silently alter A, the candidate precision, or the acceptance width.
A good root bound with a failed vector contraction is not CERTIFIED_PERRON_PAIR.

Run on P, P', PERRON_POS and its transpose. P' produces the nontrivial stationary
column pi. The model identity P*1=1 may be used as an independently checked exact
matrix property, but rounded native P cannot inherit it. For general positive
similarity matrices use the checker, not forced rho=3/2.

The second eigenvalue/spectral gap is not certified by a Perron-only method.
For that additional check, use V-S1 on the same matrix and count the remaining
roots. Bound moduli of disks outward and keep overlapping/ambiguous gap claims
INCONCLUSIVE rather than claiming mixing-time accuracy.

Negative tests: reducible matrix with two Perron vectors, a negative entry,
positive-root claim with a nonpositive vector box, wrong normalization, R=0,
Jacobian uncertainty crossing singularity, and a native-rounded model that is
not exactly stochastic. None may get an unjustified positive-pair certificate.

## 8. Proof witnesses, replay and failure semantics

Each output includes exact target/candidate IDs, all numerical bounds and radii,
mathematical domain, rounding/range contract ID, method/version, dimensions,
root counts/separation groups where relevant, certificate status and usefulness.
A replay recomputes every predicate; no stored PASS is trusted.

Meaningful failure is mandatory. INCONCLUSIVE means the sufficient conditions
were not proved, not that the mathematical answer is false. UNSUPPORTED_DOMAIN
is confined to explicit exclusions. Missing code, an unknown rounding primitive,
a missing mandatory case or an unexpected exception is ERROR/BLOCKED and prevents
task completion. Counts, subspace existence and individual factor identification
are separate claims; never promote a weaker one to a stronger status.
