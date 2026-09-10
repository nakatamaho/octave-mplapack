# SVT verification baselines: contracts, proofs, and adversarial tests

## V0. What is and is not being implemented

The three Tier V papers motivate three targets: all singular values and clusters
[RL23], compatible factor enclosures [RO24], and matrix/inverse norms [R11]. This
file specifies original, conservative baselines for those targets, with complete
proof obligations. It does **not** reproduce those papers' full algorithms,
entrywise sharpness, operation counts, interval-data support, or all edge cases.
Use `paper_algorithm_reproduction=false` in reports and artifacts.

Approximate values/factors come from the existing public SVD. Verification uses
separate outward arithmetic. No result is certified merely by precision doubling,
a small nonrigorous norm, an assumed residual bound, or high-relative-accuracy
theory for another input representation.

First implementation scope: finite point real/complex dense matrices with m,n>=1; economy
SVD with k=min(m,n); finite nonnegative descending approximate singular values.
Complex intervals are rectangles in real/imaginary parts. Positive clusters are
supported; exact mathematical rank supplied by a constructor is separate metadata.
Zero-dimensional SVD inputs return UNSUPPORTED_EMPTY (interval helper arrays may
still be empty). Generic interval-input families and generic null-space dimension certification
are outside this baseline. Never advertise those as implemented.

## V0.1 Audited scalar contract

For every real scalar operation used by the verifier, establish from local source:

    r = RN_q(x op y), op in {+, -, *, /}, or r = RN_q(sqrt(x)),

with correctly rounded round-to-nearest at recorded q bits, exact interpretation
of represented inputs, and no hidden binary64 path. Comparisons, sign, and abs of
a finite scalar must be exact. Verify scalar extraction retains precision. q>=64.
No compiled rounding-mode API or process-wide hardware rounding change is needed.
MPFR's correctly rounded operation guarantee is the underlying source [MPFR].
The package's use of that guarantee must still be audited locally.

The certifier has a bounded arithmetic domain, not an unchecked exponent claim.
For this task require q<=4096, finite primitive results either zero or between
2^-8192 and 2^8192 in magnitude, and a backend range supporting at least
2^-32768 through 2^32768 without subnormalization. Check exact powers and reciprocal
identities at startup, inspect range/subnormalization behavior, and record the
contract. Do not change the user's MPFR exponent range. Detect NaN, infinity,
unexpected zero, zero padding radius, and out-of-contract results; return an
explicit failure status, never a certificate. This range covers all required
fixtures and their proof calculations, but must be checked at runtime.

## V0.2 A rigorous enclosure from an RN operation

Let u=2^-q, computed exactly in MP, and let r be the nonzero result of one audited
RN primitive on exact represented scalar operands. Form

    t = 8*u*abs(r)                         # exact power-of-two scaling
    lo = RN_q(r-t)
    hi = RN_q(r+t).

The multiplication by 8u is an exponent shift and must be exact in range. The
subtractions/additions forming endpoints are performed at q, with no later cast.
Return [lo,hi]. This is NOT a heuristic "add a few epsilons to the final answer".
It encloses each individual primitive before interval propagation.

Proof under the stated contract: if z is the exact primitive result,

    abs(z-r) <= u/(1-u)*abs(r) <= 2*u*abs(r).

Rounding either endpoint contributes at most
`u*(1+8*u)*abs(r) <= 2*u*abs(r)`. Consequently lo<=r-6u|r|<=z and
hi>=r+6u|r|>=z. q>=64 is more than sufficient for these inequalities.
Audit endpoint range and exact scaling rather than assuming them.

When r=0, return [0,0] ONLY after proving exact zero from the operands:
addition x=-y; subtraction x=y; multiplication one operand zero; division zero
numerator and nonzero denominator; sqrt input zero. Otherwise an unexpected zero
is a range/contract failure. Never give a nonzero unknown result a [0,0] interval.
A stored finite scalar itself becomes the point interval [x,x] without padding.

This proof is specific to the real scalar primitives and the stated range. Do
not apply it directly to a complex multiply, norm, dot product, or matrix product
whose internal rounding path was not modeled.

## V0.3 Endpoint operations and verified norms

Implement private structs with lower/upper real mp arrays at known q. Support
point, add, subtract, multiply, divide when zero is excluded, square, sqrt for a
nonnegative domain, conjugation, transpose, and matrix product. For multiplication
and division combine all endpoint candidates with outward primitive enclosures.
For square of an interval crossing zero, the lower bound is exactly zero, not
the lower endpoint squared. Division across zero is INCONCLUSIVE/invalid domain,
not an infinite interval fed into later claims. Explicitly handle empty arrays.

For complex arithmetic use real rectangular formulas and individually enclosed
real operations. Conjugating a rectangle negates/reverses its imaginary endpoints.
Matrix multiply is an explicitly enclosed sum of products. A standard MP GEMM
followed by a final padding operation is forbidden in the proof path.

For a real/complex interval residual R enclosing an exact matrix, bound ||R||F
by an outward sum of squared upper bounds on abs of its real and imaginary
components, followed by an outward square root. This is also an upper bound on
||R||2. Never use an ordinary computed norm as a certified upper bound.

For a point matrix X a lower bound on ||X||2 is the maximum of certified lower
bounds on the Euclidean norms of its columns (or rows). An upper bound is its
verified Frobenius norm. Tighter certified bounds may be obtained through V1, but
ordinary svd(X) without verification cannot supply them.

All subsequent mathematical upper/lower bounds in this file are evaluated with
these enclosing operations. Branch on lower/upper endpoints in the safe direction.
For example, a separation test uses Delta_lower > 2*epsilon_upper, not rounded
midpoints. Intersect with known nonnegativity only where justified mathematically.
Do not clip negative singular values returned by the approximate solver.

## V1a. All singular values via polar correction and Weyl

Inputs: exact represented A, U, V, and diagonal S=diag(s), with m-by-n A,
k=min(m,n), U:m-by-k, V:n-by-k. s is nonnegative and descending. Widen these exact
represented values to q before taking point intervals. Do not recompute the SVD
inside the checker. Record and serialize their identities.

Compute certified upper bounds

    gU >= ||U'*U-I||F
    gV >= ||V'*V-I||F
    r  >= ||A-U*S*V'||F.

Require gU<1 and gV<1. Otherwise return INCONCLUSIVE with the failed conditions.
Define upper bounds

    dU = gU/(1+sqrt(1-gU))
    dV = gV/(1+sqrt(1-gV))
    vN = sqrt(1+gV)
    epsilon = r + s(1)*(dU*vN+dV).

All quantities here denote enclosing upper evaluations, not bare RN formulas.
The all-zero s case is valid; do not divide by s(1).

**Proof.** The thin polar factors Q_U=U(U'*U)^(-1/2), Q_V analogously, exist and
have orthonormal columns. They are proof objects, not matrices the implementation
needs to compute. If lambda is an eigenvalue of U'*U then lambda>=1-gU>0 and

    abs(sqrt(lambda)-1)=abs(lambda-1)/(sqrt(lambda)+1).

Summing squares yields ||U-Q_U||F<=dU. Similarly ||V-Q_V||F<=dV and ||V||2<=vN.
With A0=Q_U*S*Q_V',

    U*S*V'-A0 = (U-Q_U)*S*V' + Q_U*S*(V-Q_V)',

so ||A-A0||F<=epsilon. A0 has exactly the k singular values s. Weyl's singular
value inequality gives abs(sigma_i(A)-s_i)<=epsilon for every ordered i.

Return outward intervals

    lower_i=max(0, lower(s_i-epsilon));
    upper_i=upper(s_i+epsilon).

This encloses every singular value, including clustered or zero ones; no matching
heuristic or simple-root assumption is needed. It does not prove that an interval
containing zero represents an exact zero. Distinguish valid broad intervals from
resolved positive lower bounds and useful relative widths.

Method ID: `svt_polar_weyl_v1`.

## V1b. Positive singular-cluster projector bounds

Use the same A0 and epsilon. Let J select a positive cluster among the approximate
s values. Internal equality is permitted. In the Hermitian dilation

    H(A0)=[0,A0;A0',0],

the target set is BOTH +s_j and -s_j for j in J. Its complement includes both
signs of every other s and |m-n| structural zero eigenvalues. Zero s outside J
also count as zeros. Compute a rigorous lower bound Delta on separation between
the target and complement spectra. Do not omit negative or structural zero values.
If the complement is empty in the full square case, the true and polar projectors
are the full identity. Set b_sub=0 in that trivial-space branch, but still add the
raw-factor polar-correction terms below; do not return zero error for nonorthogonal
raw columns.

Require every V1a lower endpoint in J to be strictly positive, and, when a
complement exists, Delta>2*epsilon. Otherwise return
INCONCLUSIVE for the subspace claim while preserving V1a's valid value intervals.
For rJ=|J| define

    b_sub = 2*sqrt(rJ)*epsilon/(Delta-epsilon).

**Proof.** The dilation perturbation has spectral norm <=epsilon. The gap condition
identifies a true invariant subspace of the same dimension 2*rJ, separated from
its complement by at least Delta-epsilon relative to the A0 target values. The
residual in an orthonormal target basis has Frobenius norm <=sqrt(2*rJ)*epsilon.
In the exact complementary eigenbasis, the Sylvester equation divides each entry
by an eigenvalue separation >=Delta-epsilon. Thus the Frobenius sine-of-angle
bound is <=sqrt(2*rJ)*epsilon/(Delta-epsilon). Equal-dimensional orthogonal
projectors differ in Frobenius norm by sqrt(2) times that sine norm. The signed
cluster projector is blockdiag(P_U,P_V), giving the stated b_sub for each block.
This proof includes multiplicity inside the cluster, not a zero outer gap.

Bounds for the projectors formed from the RAW returned columns, rather than the
uncomputed polar columns, are

    bU = b_sub + (sqrt(1+gU)+1)*dU;
    bV = b_sub + (sqrt(1+gV)+1)*dV.

This follows by expanding U_J*U_J'-Q_UJ*Q_UJ' and bounding the factors. Return
bU and bV as upper bounds to the corresponding uniquely identified true cluster
projectors. Do not silently normalize/reorthogonalize U/V before measuring them.

Known dyadic model projectors provide strong independent tests for the close and
repeated Hadamard group and the Lauchli small group. Rotating a repeated pair by
an exact orthogonal matrix must not invalidate the group claim. A wrong column
outside the group must be detected by tests.

Method ID: `svt_dilation_projector_v1`.

## V2. Entrywise boxes for compatible simple SVD factors

This baseline supports positive, simple, separated singular values. It does NOT
supply a unique basis at multiplicity, full rectangular null-space bases, or the
sharp entrywise bounds/complexity of [RO24]. Reports must state this limitation.

For each positive s_i, define Delta_i as the separation of +s_i from every other
eigenvalue of H(A0): all +s_j with j!=i, all -s_j including -s_i, and structural
zeros. Require Delta_i>2*epsilon and the certified sigma_i lower bound positive.
Define

    z_i = 2*epsilon/(Delta_i-epsilon);
    radius_U_i = dU + z_i;
    radius_V_i = dV + z_i.

Return componentwise boxes centered on the RAW columns U(:,i), V(:,i), using the
respective column radius for each real component. In the complex case use that
radius on both real and imaginary components; the enclosing rectangle is allowed
to be conservative. Singular-value boxes are those from V1a. Off-diagonal S
entries are exactly zero in the certified factorization.

**Proof of compatibility.** The normalized dilation eigenvector of A0 is
`y0=[Q_U(:,i);Q_V(:,i)]/sqrt(2)`. Its residual for H(A) has norm <=epsilon. Spectral
separation bounds the sine of its angle to the true one-dimensional eigenspace by
epsilon/(Delta_i-epsilon). There exists a single phase making vector distance
<=sqrt(2)*epsilon/(Delta_i-epsilon). Rescaling either block by sqrt(2) gives z_i.
Adding polar correction gives the radii above. The same phase applies to BOTH
true u_i and true v_i, so the pair still satisfies A*v_i=sigma_i*u_i and
A'*u_i=sigma_i*v_i. This proves existence of a compatible SVD inside the boxes;
it does not independently choose unrelated phases for left and right vectors.

For all positive simple singular values certified simultaneously, the true
columns can be chosen orthonormal and the phases preserve the factorization.
For a multiple/unsupported index return `UNSUPPORTED_MULTIPLICITY` for individual
factor identification and retain any V1 cluster certificate. Do not claim the SVD
itself fails to exist. Do not use known exact factors in the checker; they are
independent test data only.

Mandatory small factor test: A=Q_L*diag(3,1)*Q_R' with Q_L=[1,0;0,1;0,0] and
Q_R=I_2, plus a quarter-turn complex diagonal phase variant. Add the nontrivial
Hadamard geometric case. Apply arbitrary common +/- signs or unit complex phases
to each returned U/V pair and require validity to persist. Changing only V's
phase must increase the residual and must not yield an incorrectly tight certificate.

Method ID: `svt_dilation_factor_boxes_v1`.

## V3. Spectral norm, inverse norm, and nonsingularity

For a point A, V1a provides an interval for ||A||2 via its largest singular value.
The direct verified column-lower/Frobenius-upper bounds are a separate conservative
route. Do not confuse a norm interval with a bound on every factor entry.

For square A and an approximate inverse X (computed through existing public solve
`A \ I` at recorded work precision), compute

    R=I-A*X, with r>=||R||F>=||R||2 verified.

Require r<1. This proves A and X are nonsingular because A*X=I-R is nonsingular.
Obtain verified xlo<=||X||2<=xhi, with xhi>0. Then

    xlo/(1+r) <= ||inverse(A)||2 <= xhi/(1-r).

**Proof.** inverse(A)=X*(I-R)^(-1) and ||(I-R)^(-1)||2<=1/(1-r).
Conversely X=inverse(A)*(I-R), whose norm is <=||inverse(A)||2*(1+r).
Thus a positive lower bound on sigma_min(A) is

    (1-r)/xhi.

When xlo>0, an upper bound is `(1+r)/xlo`; otherwise return no finite upper bound
from this route. Use outward evaluations in both directions. Do not use an
ordinary approximation of ||X||2 in a claimed bound.

No test based on det(A) or a small ordinary residual may replace r<1. If r>=1,
report INCONCLUSIVE, not "singular". For rectangular A this inverse method is
UNSUPPORTED; do not substitute a pseudoinverse argument without a new proof.

Known inverse formulas for NRO are checks, not a substitute for the main solve.
The exact equation-(82) inverse is a useful independent small positive test.
A singular input cannot satisfy this sufficient condition when the arithmetic is
correct. That negative test is mandatory.

Method ID: `svt_neumann_inverse_v1`.

## V4. Exact certificate serialization

The numerical certificate targets exact represented binary values. A decimal string
that round-trips at q is not necessarily an outward decimal real endpoint. Use a
canonical exact encoding:

    {"sign": -1|0|1, "mantissa_hex": "...", "exponent2": integer}
    value = sign * integer(mantissa_hex,16) * 2^exponent2.

Zero has sign=0, mantissa_hex="0", exponent2=0. Nonzero mantissas are positive
odd integers, leading hex zeroes omitted; use lower-case hex. Complex entries
contain separate exact real/imaginary encodings. Include original storage bits,
shape, column/row traversal order, method version, and canonical-byte hash.

Implement extraction from public MP operations only. One possible exact procedure:
find e such that 2^e<=abs(x)<2^(e+1) by bounded binary search on integer exponents;
scale exactly into [1,2); extract q binary digits by comparison with 1, exact
subtraction, and doubling; assert no remainder after the known significand length;
trim trailing zero bits and adjust exponent e-q+1; group bits into hex using only
small native integers. The range contract bounds the exponent search. No private
payload, decimal widening, or double-valued mantissa is allowed.

Decode by repeated exact multiply-by-16 and add-small-digit at enough precision,
then exact binary scaling. Reject insufficient target precision rather than round
a certificate endpoint silently. Round-trip test real, complex, signed zero,
values below 2^-1074, and q up to the declared evaluation precision. Scalar value
identity, not display identity, is the acceptance criterion.

Human-readable decimal fields are optional companions labeled approximate displays.
Reloaded exact certificate targets must be used for a checker replay test. Never
trust an input hash without also binding shape/precision/method metadata.

## V5. Required adversarial tests and proof audit

Each proof operation must be covered by unit tests and source review. Numerical
sampling is a bug detector; the proof above is what justifies enclosure.

1. Scalar endpoints: signs, cancellation, zero, division by 3, perfect/nonperfect
   square roots, tiny representable results, and invalid/range cases at q=64,128,256.
   For bounded rational tests compare by exact cross multiplication at a provably
   sufficient integer/dyadic precision, not merely another floating approximation.
   For sqrt compare squared endpoints exactly against the positive rational target.
2. Interval corner tests: all multiplication sign combinations; intervals crossing
   zero; excluded-zero division; complex conjugation; complex matrix residuals.
   Independently constructed rational/dyadic matrix examples must be enclosed.
3. V1: exact identity/zero/simple diagonal, dense known spectra, tall/wide economy,
   negative/nonfinite/missorted input rejection, bad Gram matrices, deliberately
   perturbed factors. A wide valid interval is not the same as an invalid result.
4. V1 cluster: exact repeat, close pair, permutations, internal rotations, and an
   exterior-gap collapse. The gap condition must fail closed when uncertainty
   reaches a complementary value. Never reject internal equality alone.
5. V2: compatible common phases, wrong single-sided phase, exact multiplicity,
   insufficient gap, tall full-column-rank real/complex cases. Use interval comparisons
   to show known exact factors admit the common phase/basis required by the theorem.
6. V3: exact NRO inverse, computed good inverse, poor inverse such as zero X, singular
   rank-four input, and explicit rectangular rejection. No false nonsingularity.
7. Exact serialization and replay; default/path restoration after injected failures;
   immutable inputs; all proof comparisons in MP/enclosing arithmetic.

A developer-review checklist must restate every precondition and identify the code
that enforces it. A failed arithmetic-contract audit blocks certificate claims.
No report may replace a missing proof/implementation with "MPFR is accurate enough".
