# S1: the Ozaki--Ogita error-free triple-product generator

Source [OO22], Theorem 1 and Section 4. This is a deterministic specialization,
not a copy of the paper's MATLAB code or its large random experiments.

## 1. Fixed standard forms and inverse pairs

Let N have ones on its first superdiagonal, L=I+N', U=I+N, X=L*U, and
Y=U^(-1)*L^(-1). Compute unit-triangular inverses by the finite nilpotent series
or exact forward/back substitution, **not a floating inverse taken on faith**.
All entries are integers. Prove XY=YX=I with the exact-dyadic checker.

Prepare S_requested at the manifest's fixed generation precision g:

- `OO53_REAL`: S(i,i)=i+2^-45; S(i,i+1)=32. g=53.
- `OO53_PAIR`: for j=0..n/2-1, put the block [a,b;-b,a] at indices 2j+1:2j+2,
  a=2j+1+2^-45, b=(2j+1)/8+2^-45. Put 8*I_2 on the first block superdiagonal.
  g=53. This is a real normal diagonal block, **not** a skew-symmetric block
  unless a=0. The full upper block-triangular S need not be normal.
- `OO128_CLOSE`: diagonal [1,1+2^-80+2^-120,3,4,...,n], with ones on the first
  superdiagonal. g=128. The realized first gap must be exactly 2^-80 in the
  mandatory n=8/16 instances; the 2^-120 component is intentionally removed.

g never follows the eig work precision. Freeze one generated matrix and its
realized standard form per case. The g=53 cases are exactly binary64-representable
inputs; the g=128 case need not be. Never regenerate S' separately for each eig row.

## 2. Quantization parameters

For each nonzero dyadic x_ij write x_ij in phi_ij*Z but not 2*phi_ij*Z, with
phi_ij a power of two; set phi=0 on zeros. Define psi analogously for Y. Obtain
these from exact dyadic decomposition, not rounded logs. Set

```text
beta  = max over columns j: max(nonzero phi(:,j))/min(nonzero phi(:,j))
gamma = max over nonzero X entries: ufp(abs(x_ij))/phi_ij
theta = max over rows i: max(nonzero psi(i,:))/min(nonzero psi(i,:))
omega = max over nonzero Y entries: ufp(abs(y_ij))/psi_ij
nY    = maximum nonzero count in a row of Y
nS    = maximum nonzero count in a row of S_requested
nX    = maximum nonzero count in a column of X
nprime = min(nS,nX)
```

`ufp(x)=2^floor(log2(abs(x)))`, computed by exact comparisons/exponent search.
Choose alpha as the smallest power of two >= nY*nprime*max(abs(S_requested(:))).
The alpha search itself must not underestimate its exact target.

```text
u = 2^-g
P = beta*gamma*theta*omega
require 4*nY*nprime*u*P <= 1
sigma = 12*alpha*P
Sprime(i,j) = RN_g(RN_g(sigma + S_requested(i,j)) - sigma)
A = RN_g(Y * RN_g(Sprime * X))
```

Zero S returns zero with explicit metadata. Our mandatory cases are nonzero.
Compute the two matrix products as sums of scalar products; no Strassen/Winograd,
reassociation of the quantization expression, or unspecified GEMM evaluation route.
The rounded addition and subtraction must be distinct operations at g.

Under the source theorem's conditions these products are exact. Independently
check **both** intermediates and the final product by exact dyadic evaluation;
do not use the theorem as a reason to skip a generator regression test.
Record alpha, sigma, beta/gamma/theta/omega, counts, inequality, and precision.

The g=53 evaluator may use MP RN at 53 bits if the existing public constructor
supports it. Otherwise use deliberately native binary64 scalar operations for
this **explicit 53-bit generator only**, with the native RN/range contract audited.
This is not an MP eig fallback. Do not silently change generation_bits to 64.
All g=128 generation and all MP solves remain genuinely MP.

## 3. Paired real blocks and sign-copy rule

For each 2x2 complex-pair block, quantize its shared diagonal once and copy it to
both diagonal positions; quantize the upper b once and set the lower value to its
exact negative. Quantizing b and -b separately must not be assumed antisymmetric.
This is the paired-block modification described in [OO22] Section 4.

For the mirrored entry, establish the same quantization lattice membership and
magnitude bound used in the theorem, and verify the exact products independently.
Copying a sign preserves that lattice and bound. Do not subsequently alter A.
If b' is zero, record the realized multiplicity; never keep claiming a complex pair.
The required pair fixtures have b' != 0 and must preserve their real block structure.

## 4. Outputs and mandatory checks

Return S_requested, S_realized, X, Y, A_exact, requested and realized spectra,
generation precision, source/method IDs, exactness guard, bit audit, and hashes.

For triangular S', realized roots are diag(S'). For the paired block form they
are a' +/- i*b'. These are exact complex dyadic values; do not recompute them with
a general eigensolver. Actual measured eig(A) is a separate operation.

Required checks:

- XY=YX=I; output is neither symmetric nor triangular for mandatory fixtures.
- The theorem inequality holds; every rounded product equals its exact counterpart.
- Quantization changes at least one requested entry in each required case.
- Requested and realized spectra are separately stored and never confused.
- Both n=8 and n=16; negative entries, zeros, unequal bit lattices, and the paired rule.
- Inverse pair is invalid -> reject. Inequality fails -> reject, no quiet extra bits.
- Attempt to use a non-dyadic inverse as exact -> reject.
- A small requested entry/gap lost in a mixed-scale standard form must be recorded
  as a realized change. Test the prescribed lost 2^-120 increment. Do not assume
  that uniformly scaling S to tiny numbers makes it collapse: alpha scales with S.
  Zero input has its separate explicit branch and is not a useful hard fixture.
- Generation repeated at the same g is bit-identical. Increasing eig precision does
  not change generator hashes. A separate new g gets a separate model identity.

The preparation script provides exact-rational checks for all six n/kind cases.
Its rational-string hashes are preparation-only and use a different encoding from
the certificate serializer; do not compare hashes across unlike encodings.
