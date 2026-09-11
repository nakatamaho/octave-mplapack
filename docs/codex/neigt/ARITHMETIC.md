# The proof arithmetic and exact serialization contract

## 1. Reuse or implement, but do not assume

Reuse the existing SVT private interval/rectangle layer only after auditing its
proof, actual code, tests, shape conventions, precision, range and serialization.
The presence of an SVT specification is not an implementation. If absent, implement
this self-contained layer under the example tree. No new installed interval API.

Proof primitives are **real scalar** +,-,*,/,sqrt in correctly rounded RN_q,
q>=64; exact abs/sign/comparison, known stored input precision, and no hidden
double evaluation. Confirm the source path to MPFR and its rounding argument.
Runtime probes supplement but do not establish this source-level contract [MPFR].
Complex proofs are rectangles made from these real scalar primitives; do not
assume a whole MPC multiply, GEMM, norm or dot product has one final rounding.

Bounded verifier domain: q<=4096, nonzero ordinary primitive results in
[2^-8192,2^8192] in magnitude, and an unchanged backend range supporting at least
[2^-32768,2^32768] without subnormalization. Exact padding/scaling intermediates
may occupy the wider backend range. Audit this and test exact powers/reciprocal
identities; do not modify global MPFR exponent limits. Detect NaN, infinity,
unexpected zero, zero padding or range violations and fail closed.

The OO generator at 53 bits is a separate RN computation with its own audit. Do
not apply a q>=64 verifier assumption to that generator without acknowledging the
different role. Every certificate runs at the stated q>=64.

## 2. Enclose one RN primitive rigorously

For a nonzero rounded primitive r=RN_q(z), u=2^-q, set

```text
t=8*u*abs(r)                  # exact power-of-two scaling in range
lo=RN_q(r-t)
hi=RN_q(r+t)
```

The exact z is contained: |z-r|<=u/(1-u)|r|<=2u|r|. Each rounded endpoint moves
by at most u*(1+8u)|r|<=2u|r|, leaving at least 6u|r| of outward margin. This is
a per-primitive proof, **not** heuristic final-answer padding.

For r=0 allow [0,0] only with an exact-zero witness from operands: x=-y for +,
x=y for -, an operand zero for *, zero numerator/nonzero denominator for /, or
zero argument for sqrt. Otherwise return a range/contract failure. Point values
become [x,x] without rounding. Exact binary scaling must itself be audited.

For nonnegative sqrt bounds, intersect with nonnegativity only by its proved domain.
An interval crossing a negative square-root domain or zero denominator is not
silently repaired. Distinguish invalid input from an inconclusive proof domain.

## 3. Interval and rectangle operations

Endpoint addition/subtraction; min/max of all four endpoint products/quotients;
zero-excluding division; square with lower=0 when crossing zero; monotone square
root; real/imaginary complex rectangles; conjugation negates and reverses the
imaginary endpoints. Evaluate every endpoint primitive outward as above.

Matrices: explicit enclosed sums of enclosed products, conjugating transpose,
block extraction/assembly, Kronecker product, and left/right point multiplication.
Empty helper arrays are allowed with correct shapes; eigenproblem n=0 is outside
scope. Do not certify a matrix product by padding an ordinary GEMM once.

For complex rectangles, bound modulus by outward sqrt(re^2+im^2), or use the more
conservative upper bound max|re|+max|im|. Lower bounds may use distance of the
rectangle to the origin. Never use center modulus as an enclosing endpoint.

Verified upper matrix infinity norm: maximum of outward row sums of upper moduli.
Verified upper Frobenius norm: outward sum of squared upper real/imaginary
magnitudes, then outward sqrt. It bounds the spectral norm. Distinguish matrix
infinity norm from entrywise max norm and vectorized infinity norm everywhere.
For exact point columns, verified lower Euclidean norms give spectral-norm lower
bounds. Ordinary `norm`/`svd` output is never itself a rigorous norm bound.

All theorem inequalities use enclosing endpoints in the safe direction. Examples:
`upper(e)<1`, `upper(c+e*t+g*t*t)<t`,
`lower(abs(center_i-center_j))>upper(radius_i+radius_j)`.

## 4. Inverse and linear-image enclosures

For a square point or interval X and point inverse candidate R, if
`e=upper(||I-R*X||inf)<1`, every X in the enclosure is nonsingular, as is R.
Use the identity X^(-1)=(I-E)^(-1)*R, E=I-RX.

A conservative entrywise inverse enclosure is centered on R, with each complex
entry allowed modulus at most

```text
theta = e*upper(||R||inf)/(1-e).
```

A tighter per-entry Neumann-sum enclosure is optional, with a proved tail.
For a right-hand side F, `||X^(-1)F||inf <= ||R F||inf/(1-e)` often avoids
unnecessary interval widening. Use the latter in the all-spectrum and pencil
checkers. Never certify nonsingularity from a nonzero approximate determinant.

## 5. Exact dyadic values, copying, and serialization

Represent exact binary values by

```json
{"sign": 1, "mantissa_hex": "1f", "exponent2": -12}
```

meaning sign*integer(mantissa_hex,16)*2^exponent2. A nonzero mantissa is positive,
odd, lowercase and without leading zeros. Zero is sign=0,mantissa_hex="0",exponent2=0.
Complex values have separate real/imaginary encodings. Include shape, column-major
traversal, stored precision, method version and a canonical byte hash.

Public-operation extraction: locate exponent by bounded exact comparisons with
powers of two; scale into [1,2); extract the known p significand bits by comparison,
exact subtraction and doubling; require zero remainder after p bits; remove trailing
zero bits and group into hexadecimal. Native integers are used only for bounded
indices, bit counts and hex digits, not for a large mantissa. Do not export a
large mantissa through binary64 or use private object payloads.

Decode with sufficient precision via repeated multiply-by-16/add-digit and exact
binary scaling. Reject an insufficient destination precision. Decimal display
strings, even if same-precision round-tripping, are not outward real endpoints.
Signed-zero sign is not mathematically significant but its policy must be documented.

Certificate records bind all inputs, candidates and interval endpoints to exact
content. Save a JSON witness; reload in a fresh session and rerun the checker.
Do not trust a stored status, root list or bound without recomputing predicates.
Tampering with a target, radius, hash, shape, precision or method ID must be caught.
A supplied larger valid bound may pass validity while failing the quality gate.

## 6. Tests and proof-to-code map

Test signs, cancellation, exact zeros, division by 3, perfect/nonperfect roots,
2^-1500, q=64/128/256, range/NaN/infinity errors, complex conjugation and all
multiplication sign combinations. Check rational cases by exact cross multiplication
at a proved sufficient precision, not merely a second rounded calculation.
For square roots compare squared rational endpoints with the exact argument.

Test interval matrix products against independent exact small dyadic computations,
all relevant induced norms, and full preservation of precision/path/input aliases.
Report separate evidence for the proof and the tests. Random or exhaustive finite
samples detect bugs; they do not establish a floating-point theorem by themselves.

Every checker report identifies the code enforcing each assumption and its
source-level RN contract. An unknown primitive or a whole unmodeled matrix
operation on a proof path is a blocker, not permission to write CERTIFIED.
