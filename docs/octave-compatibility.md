# Octave compatibility

M23 freezes and validates the real-only public surface with GNU Octave 11.1.0. The normal
Octave syntax is used for supported operations and the `mp` class keeps
immutable native storage. Existing values retain their stored precision;
`mpbits` is a construction default, not an operation-wide override.

Supported syntax includes scalar and dense two-dimensional real construction,
indexing and in-bounds assignment, arithmetic, `*`, `\`, `chol`, full/economy
QR (including documented pivoted three-output forms), LU, transpose, reshape,
and concatenation. Factorization methods use the selected MPLAPACK MPFR
backend and copy destructive inputs.

Intentional v0.1 differences are real-only operation coverage, no sparse or
N-D values, no matrix `char`, limited vector-linear indexing, no growth or
deletion assignment, no comparisons/logical operators or reductions, and no
`det`, `inv`, `rank`, `cond`, `norm`, `eig`, `svd`, or update APIs. Three-output
sparse permutation forms and `qr(A,B)` are not provided.

Unsupported matrix functions are expected to fail cleanly. M22's compatibility
firewall checks representative `eig`, `svd`, `det`, `inv`, `rank`, `norm`,
`sin`, `exp`, `sqrt`, power, and comparison calls for the absence of implicit
binary64 fallback, crashes, and recursion.

The package does not promise identical error text to builtin Octave. It does
promise matching error-versus-success behavior for audited forms and stable
project-owned identifiers for public validation guards.
