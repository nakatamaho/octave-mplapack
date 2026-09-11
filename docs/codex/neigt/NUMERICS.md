# Precision, ordinary diagnostics, references, and safe interpretation

## 1. Precision roles and value identity

Record: generation bits g, actual eig input/work bits p, model-exactness guard,
reference bits r1/r2, diagnostic/certificate bits q, and auxiliary-candidate bits.
For smoke: r1=512,r2=640,q=768. For demo: r1=768,r2=896,q=1024.
For explicit stress: r1=1536,r2=1664,q=2048. These are caps/settings, not a license
to silently increase precision until a preferred output appears.

For OO cases generation g is fixed independently of all of these. For other
recipes construct the exact dyadic model with a proved sufficient precision,
then represent that same model at p with one rounding per component. When p
satisfies the guard, prove exact equality; otherwise label the rounded model.
The native baseline is one rounding of this exact model to binary64, once per
case, not once per MP row.

Maintain immutable A_model, A_frozen and eig outputs for each run. Certificates
name A_frozen by its exact binary content and shape. The intended/model forward
error and solver-only error for the actual frozen input are different fields.
Never compare to the ideal model while labeling the result frozen-input accuracy.

Exact widening: audit maximum-operand-precision semantics, then use a target-q
zero array added to an existing MP object; native values convert directly at q>=53.
Prove/test that values are unchanged and the result has the intended precision.
`mp(existing_mp)` and `mpbits(q)` alone do not necessarily widen the existing value.
`mp(char(X))` is not an exact cross-precision widening operation. If public semantics
changed, implement a tested equivalent via existing public operations only.

All functions that change precision or path restore it on normal and exceptional
return. Test ambient precision below and above p, aliases, injected errors, and
all filtering/output/graphics failure paths. Do not inject a q-bit scalar into a
p-bit input by assignment or concatenation and quietly change the solver precision.

### 1.1 Manifest numeric grammar

Interpret numeric parameter strings with a bounded parser for signed integers,
integer ratios, powers `2^k`, and the specifically used sum `1+2^k`. Construct
these from exact small integers and MP binary scaling. Do not use eval, str2num,
native floating-point decimal parsing, or a symbolic package. Enum/recipe strings
are not expressions to execute. Validate dimensions and exponent bounds before
allocation. The more elaborate OO standard forms are explicit constructor code,
not arbitrary expressions supplied through JSON.

## 2. Measured solve workload

For each ordinary case, frozen precision, and balance mode run
`[V,D,W]=eig(A,mode)`. Time the solver only. Test values-only API consistency in
small unit tests, not as additional core rows. Core counts follow cases.json.
The left convention to audit is

```text
A*V=V*D
W'*A=D*W'
A'*W=W*D'             # conjugating D' for a complex spectrum
```

Keep raw order. Never independently reorder D,V,W. Store raw and matched view
permutations separately. Each successful MP solve must return finite values,
nonzero vector columns and correct shapes/types. Do not normalize, repair,
replace, or real-project solver outputs before recording their residuals.

## 3. Bijective minimum-bottleneck spectrum comparison

At q, construct the full cost matrix using MP arithmetic. Costs:

```text
absolute: abs(mu_j-lambda_k)
relative: abs(mu_j-lambda_k)/abs(lambda_k)   # only all-nonzero reference groups
circle:   abs((mu_j-1)/r-unit_root_k)
```

Sort finite MP costs; binary-search the smallest threshold allowing a perfect
bipartite matching; use deterministic augmenting paths for feasibility. Return
threshold, bijection and traversal/metric metadata. A Hungarian minimum-sum match
is not the same optimization. Solve each chosen metric separately.

Absolute matching includes repeated and zero roots with multiplicity. Relative
error at a zero reference is undefined; report absolute leakage for that group.
Do not infer exact multiplicity from matching alone. Use the known model groups
only in ordinary model comparisons; a verifier must establish its own root counts.

Tests: identity/permutation, complex circles/conjugate pairs, duplicates, zeros,
computed [0,0,2] versus [0,1,2] (bottleneck 1), [2,0] versus [1,3] (1), exhaustive
permutations n<=6, and tiny positive distances 2^-700 and 2^-1500 at adequate MP
precision. Reject nonfinite/mismatched inputs. No native-double comparisons.

## 4. Ordinary metrics (MEASURED, not certified)

All use exactly widened A_frozen and the actual returned outputs at q. For A!=0:

```text
rho_R = ||A*V-V*D||F/(||A||F*||V||F)
rho_L = ||W'*A-D*W'||F/(||A||F*||W||F)
eta_R = max_j ||A*v_j-mu_j*v_j||2 / ((||A||F+|mu_j|)*||v_j||2)
eta_L = max_j ||A'*w_j-conj(mu_j)*w_j||2 / ((||A||F+|mu_j|)*||w_j||2)
kappa_j = ||v_j||2*||w_j||2/abs(w_j'*v_j)
```

For an exact zero matrix use absolute residuals; never 0/0. A zero overlap yields
an explicit unresolved/infinite condition, not a dropped column. kappa_j is a
simple-eigenvalue condition estimate only for resolved simple eigenpairs. For
semisimple or defective repeats label it NOT_APPLICABLE_SIMPLE_ROOT; a numerical
finite value on an artificially split root is not the true condition of the
multiple eigenvalue. `cond(column_normalized_V)` is a diagnostic of the computed
basis, not proof the exact input is diagonalizable.

Record imaginary parts for theoretically real models, but impose no fixed count
of spurious complex values. Normwise residuals alone do not certify a common
small decomposition perturbation when V is ill-conditioned.

Cluster metrics: from a separately recorded QR basis Q_J, evaluate
`M_J=Q_J'*A*Q_J` and `||A*Q_J-Q_J*M_J||F`, and compare orthogonal projectors to an
independent model subspace when available. QR preparation does not alter the raw
eig residual. For true defect, the span of numerically returned eigenvectors can
be a poor subspace candidate; use the candidate procedure below and label its origin.

For a model matrix change report ||A_frozen-A_model||F and the ratio to ||A_model||F.
For the complex Hadamard case the reference similarity is unitary; for Toeplitz,
Forsythe and Perron diagonal scaling it is generally not unitary. Never transfer
norms or pseudospectral certificates between these coordinates without a proof.

## 5. References

Exact dyadic roots: OO realized spectra, exact similarity blocks, Hadamard integers,
Wilkinson integer roots, zero multiplicities. These need no general eig reference.

Analytic evaluated roots: Toeplitz sin/cos formula, Forsythe circle, Markov complex
modes. Evaluate at both r1/r2 from exact parameters; check absolute disagreement
<=2^-160 smoke or 2^-224 demo, scaled by max(1,max|lambda|). Forsythe uses its circle
metric. These are evaluated-consistent, not interval-certified transcendental values.

Independent paths: Frank symmetric Hermite-Jacobi formula; MKS smaller companion
plus exact zeros; Grcar general eig at r1/r2. For matching all-nonzero simple
references also check relative consistency. Keep MKS repeated zeros algebraic.

When a frozen input differs from the model, evaluate its own r1/r2 references.
Report unresolved clustered references honestly; do not force the model roots into
this reference. Inexact references block numerical solver-only forward claims,
not valid certified inclusions for the same frozen input.

A rigorous reference can come from certifying higher-precision approximate data.
The certifier must still receive exactly the original frozen input. It may certify
A using these new auxiliary candidates, but its widths must not be reported as
a certificate around the earlier low-precision eigenvectors. Record candidate hashes
and candidate_source_bits separately from measured work bits.

For a certified disk D(c,r) known to contain a particular simple reference root,
`|mu-c|+r` is an outward absolute-error upper bound. For a counted cluster, do not
assign each of its member disks to a unique exact root without a justified matching.
A precision-agreement reference remains a numerical reference unless such a
separate certificate actually succeeds.

## 6. Candidate preparation for cluster/factor certificates

The proof checker is independent of the approximation algorithm. It must never
trust a generator's exact roots or basis. Supplied candidate data are suggestions;
all existence, invertibility, counts and bounds come from CERTIFICATES.md.

For well-separated simple cases, use computed V and a computed inverse candidate.
For a selected k-cluster:

1. Try QR of the selected computed columns, completing to n columns. Preserve
   candidate origin and precision; do not treat a tolerance rank estimate as proof.
2. If columns are deficient or graph validation is inconclusive, use a bounded
   **candidate-only** contour projector preparation at r1 or r2. The query contour
   center/radius are chosen from approximate clusters, not asserted exact roots.
   For M=16,32,64 (in this order) and z_j=c+r*exp(2*pi*i*(j+1/2)/M), form
   `P_hat=(1/M)*sum((z_j-c)*((z_j*I-A)\I))`.
   Choose k independent-looking columns by deterministic norm-pivoted QR/Gram--Schmidt
   and complete a basis with coordinate vectors. Record all solves and errors.
3. Feed that point basis to the same graph checker. Quadrature convergence, the
   number k, or use of a model-centered query contour is **not** its proof.

This computes an approximate invariant-subspace basis, not replacement eigenvalues.
It is confined to small verification jobs and is not a new eig backend. A selected
k may come from the requested test query; the checker must prove dimension and
spectral separation itself. Public ordered Schur, if already present and audited,
may supply an additional candidate route, never a required new binding.

After either candidate route, permit at most four **candidate-only** Newton
corrections of the invariant graph at the selected r1/r2. For point central blocks
and current Z, solve the vectorized linearized equation using

```text
K_Z = kron(I_k,C22-Z*C12) - kron(transpose(C11+C12*Z),I_h)
K_Z * vec(dZ) = -vec(C21+C22*Z-Z*C11-Z*C12*Z).
```

Update the candidate range, recompute its thin QR, and build a new nonsingular
completion. The graph checker then starts again at Z=0 in the new coordinates.
These corrections are only approximation work; they prove nothing until the
outward checker succeeds. They avoid making contour quadrature accuracy the
ceiling of a certificate. Do not iterate without a cap or use a generator's
exact invariant basis as the solution of a required verification job.

For a nonnormal complement, try a completion consisting of the QR-normalized
cluster columns and computed complementary invariant/eigenvector columns; it need
not be unitary. In particular, the two nonzero MKS(6,3) eigenvectors make a useful
complement to its four-dimensional zero-root subspace. Any such X still needs the
verified nonsingularity test. When a unitary completion gives overly broad D2
Gershgorin disks, a different candidate completion is allowed, not weakened
separation criteria. Record this bounded alternative (at most two completion
strategies per candidate).

At most the declared three node counts, four Newton corrections per candidate,
two completion strategies, and two candidate precisions are used.
A failed solve at a contour shift is logged; do not silently perturb the input.
No successful graph predicate means INCONCLUSIVE and a failed mandatory positive
gate, not PASS. A full-space identity projector does not count as a nontrivial
cluster success.

## 7. Reporting statuses

Use separate fields, not a single overloaded PASS:

```text
solver_status: success | nonconverged | error
input_status: exact_model | rounded_model | native_underflow | generator_rejected
reference_status: exact_algebraic | evaluated_consistent | unresolved
claim_status: MEASURED | CERTIFIED_ALL | CERTIFIED_CLUSTER | CERTIFIED_PAIR |
              CERTIFIED_INVARIANT_BASIS | CERTIFIED_EIGENFACTORS |
              CERTIFIED_SCHUR_TRIANGULAR | CERTIFIED_BLOCK_SCHUR |
              CERTIFIED_ALL_FINITE | CERTIFIED_PERRON_ROOT |
              CERTIFIED_INSIDE | CERTIFIED_OUTSIDE | CERTIFIED_PERRON_PAIR |
              INCONCLUSIVE | UNSUPPORTED_DOMAIN | ARITHMETIC_CONTRACT_FAILED | ERROR
claim_quality: resolved | broad | not_identified | not_applicable
```

Individual vector identification at multiplicity uses an explicit
`NOT_IDENTIFIABLE_INDIVIDUALLY` reason. An inconclusive verifier is not evidence
of a nonexistent eigenpair, a singular matrix, or a solver error. However all
mandatory positive verification jobs must satisfy their stated useful-width gates.
