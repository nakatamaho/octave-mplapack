# mplapack-interop

This Markdown manual is generated from [doc/mplapack-interop.texi](../doc/mplapack-interop.texi) via GNU Texinfo DocBook output and Pandoc. Edit the Texinfo source, then regenerate this file with `tools/build-manual-markdown.sh`.

## Introduction

`mp` is a user-facing Octave class. An object owns its represented MPFR/MPC value, shape, and stored precision. Public values are immutable at the native boundary; destructive MPLAPACK calls receive operation-owned copies. The package does not silently route supported numerical work through builtin binary64 arithmetic.

Use this package when the input data, intermediate values, or requested tolerances require more precision than binary64 provides. Use ordinary Octave values when binary64 is sufficient or when a deferred API is needed.

## Installation and package loading

Install the source package with Octave’s package manager:

    pkg install mplapack-interop-0.5.0-dev.tar.gz
    pkg load mplapack-interop

For a local dependency installation, the repository helper starts a configured session at `/home/docker/opt/octave-mplapack-stack/bin/octave-mplapack`. After starting Octave, load the package with:

    pkg load mplapack-interop

The package requires GNU Octave 11.1 or newer and an installed MPLAPACK MPFR interface discoverable through `pkg-config`. The package does not vendor MPLAPACK or search a developer-specific source path. Check the active stack with `mplapack_version ()`.

## Creating `mp` values

Decimal text is parsed directly at the current default precision:

    mpbits (256);
    x = mp ("0.1");
    A = mp ({"1.0", "2.0"; "3.0", "4.0"});

A builtin double has already been rounded before `mp` receives it:

    binary64_value = mp (0.1);
    decimal_value = mp ("0.1");

These values intentionally preserve different source information. A complex scalar can be made directly from two decimal strings:

    z = mp ("1.25", "-0.5");

Dense matrices are two-dimensional and have one uniform stored precision. Use `char`, `disp`, and explicit `double` when inspecting or converting values. Only the last of these is an intentional binary64 conversion.

## Precision model

`mpbits ()` reports the project default; `mpbits (p)` changes it for subsequently constructed values. `mpdigits (d)` requests `ceil(d*log2(10))` bits. A fresh process starts at 512 bits.

Changing the default does not recreate information already lost:

    mpbits (128);
    low = mp ("0.1");
    mpbits (1024);
    high = mp ("0.1");
    % low remains a 128-bit value; high is newly constructed at 1024 bits.

Existing operands determine the operation precision. For two `mp` operands it is the maximum stored precision; a builtin double is converted at the `mp` operand precision. The ambient default does not retroactively change operands or select an arithmetic result precision.

Linear-algebra and other native calls enter one operation-owned precision scope, normalize temporaries to that precision, and restore the caller’s thread-local backend context. Real-to-complex promotion happens once at the selected precision. Guard precision is used only where the function-specific documentation says so; it is not a hidden binary64 fallback.

## Real and complex values

Real and complex values share the public `mp` class but have different native payload kinds. `real`, `imag`, `conj`, `isreal`, `abs`, `arg`, and `angle` inspect or transform those payloads using MPFR/MPC operations.

A real input is kept on a real path when the operation permits it. A result is promoted to complex `mp` when the mathematical branch requires a complex value, for example a negative real square root or a general real matrix with complex eigenvalues. A builtin complex double may be an input, but it is converted into the operation precision. A raw builtin-double-only operation remains an Octave operation outside this package’s contract.

## Arithmetic and comparisons

The element-wise arithmetic functions and operators are `plus`, `minus`, `times`, `rdivide`, `uplus`, `uminus`, `power`, and `mpower`. Dense multiplication uses `mtimes` and MPLAPACK `Rgemm` or `Cgemm`. Mixed real/complex inputs promote to MPC at one operation precision.

Comparisons use native MPFR/MPC equality and the documented complex magnitude/phase ordering for supported extrema and sorting operations. Ordered comparisons on complex values remain rejected.

    mpbits (512);
    a = mp ("0.1");
    b = mp ("0.2");
    c = a + b;
    d = a .* b;
    e = c ^ 2;

## Dense matrices and indexing

The dense public type is two-dimensional, column-major, and contiguous at the native boundary. `size`, `rows`, `columns`, `numel`, `ndims`, `length`, and `isempty` inspect shape without changing stored precision.

`subsref`, `subsasgn`, and `end` provide normal dense indexing and value-semantic in-bounds assignment. `reshape`, `transpose`, `ctranspose`, `horzcat`, `vertcat`, and `cat` preserve native values. `diag`, `triu`, `tril`, `repmat`, `flip`, `fliplr`, `flipud`, and `rot90` are supported for the dense two-dimensional forms. `zeros`, `ones`, `eye`, `NaN`, and `Inf` support `"like"` construction with an `mp` template.

Sparse, N-dimensional, deletion, growth assignment, and packed triangular forms are not part of the public dense contract.

## Matrix factorizations and linear solves

Use `A \ b` or `A / B` instead of explicitly forming an inverse for a solve. Square left division uses `Rgesv` or `Cgesv`; rectangular and rank-revealing forms use `Rgelss` or `Cgelsy`. Right division uses the conjugate-transpose solve identity and preserves complex conjugation.

`chol` uses `Rpotrf`/`Cpotrf`; `qr` uses `Rgeqrf`/`Rorgqr` or `Cgeqrf`/`Cungqr`; pivoted QR uses `Rgeqp3`/`Cgeqp3`; and `lu` uses `Rgetrf`/`Cgetrf`. Every destructive call receives an operation-owned copy.

    A = mp ({"4", "2"; "2", "10"});
    b = mp ({"1"; "2"});
    x = A \ b;
    [Q, R] = qr (A);
    [L, U, P] = lu (A);

Result tolerances should be based on the stored operation precision and the conditioning of the problem, not on a fixed binary64 epsilon.

## Eigenvalues, SVD, Schur and QZ

This chapter covers the dense eigenvalue, singular-value, Schur, Hessenberg, and generalized Schur interfaces. These routines are useful for analysing conditioning and invariant subspaces, but their factors are not unique. A successful call therefore must be checked with a residual, an orthogonality or unitarity relation, and a precision-aware tolerance rather than by comparing vectors element by element.

### Standard eigenproblems

The standard dense interface accepts a square `mp` matrix `A`:

    lambda = eig (A)
    [V, D] = eig (A)
    [V, d] = eig (A, "vector")
    [V, D, W] = eig (A)
    [V, D] = eig (A, "balance")
    [V, D] = eig (A, "nobalance")

The default one-output form returns a column vector of eigenvalues. The explicit `"matrix"` form returns a diagonal eigenvalue matrix, while `"vector"` returns a column. The two-output forms return right eigenvectors and eigenvalues; the three-output form additionally returns left eigenvectors. For the matrix form the identities are `A*V = V*D` and `W'*A = D*W'`. For the vector form replace `D` by `diag(d)`.

An exactly represented real symmetric matrix uses the structured MPFR `Rsyevd` path. An exactly represented complex Hermitian matrix uses `Cheevd`. Structured real eigenvalues and eigenvectors are real `mp`; a Hermitian problem has real eigenvalues but generally complex eigenvectors. The structured path does not need balancing.

All other square real matrices use MPLAPACK `Rgeevx`, and all other complex matrices use `Cgeevx`. General real results are returned as complex `mp` values even when every eigenvalue happens to be real. This keeps the imaginary parts of conjugate pairs and gives one output type for the general driver. `"balance"` and `"nobalance"` select the expert-driver mode explicitly; balancing can improve the scaling of a badly scaled problem but changes the returned vectors.

The structured/general decision is based on the represented values, not on a floating-point closeness test. A nearly symmetric matrix, a non-Hermitian complex matrix, a defective or nearly defective matrix, and a badly scaled matrix therefore exercise the general path. Sparse, non-square, and N-dimensional eigenproblems are outside the dense `mp` contract.

This example deliberately uses a nonnormal Grcar matrix. It checks the right-eigenvector residual without assuming a particular eigenvalue order, vector scale, or complex phase:

    mpbits (1024);
    G = mp (gallery ("grcar", 32));
    [V, D] = eig (G, "nobalance");
    right_residual = norm (G*V - V*D, "fro") / norm (G, "fro");
    disp (right_residual);

For a three-output call also check the left relation. Near repeated eigenvalues can have very sensitive eigenvectors even when the residual is small, so report the residual and inspect the eigenvalue separation before interpreting the vectors.

### Generalized eigenproblems

The generalized interface solves the pencil `A - lambda*B`:

    lambda = eig (A, B)
    [V, D] = eig (A, B)
    [V, d] = eig (A, B, "vector")
    [V, D, W] = eig (A, B)
    [V, D] = eig (A, B, "chol")
    [V, D] = eig (A, B, "qz")

Right and left eigenvectors satisfy `A*V = B*V*D` and `W'*A = D*W'*B`. The default one-output form is a column vector; an explicit `"matrix"` option returns a diagonal matrix. `"vector"` selects the column layout for two- and three-output forms. The output and algorithm options can be supplied together, for example `eig (A, B, "chol", "vector")`; duplicate or contradictory options are rejected.

The `"chol"` algorithm is valid only for an exactly symmetric real or Hermitian complex `A`, with a positive-definite `B`. It uses `Rsygvd` or `Chegvd`. The default chooses this definite path when the represented pair satisfies those conditions. `"qz"` forces the generalized Schur path, using `Rggev` for real input and `Cggev` for complex or promoted input. If `B` is singular or not positive definite, the default falls back to QZ; an explicit `"chol"` request reports the invalid pair instead. Generalized `"balance"` and `"nobalance"` options are not supported.

The QZ backend represents an eigenvalue as `alpha/beta`. Division is performed at the operation precision. When `beta` is zero, the result is an infinite eigenvalue rather than a binary64 overflow or a rejected problem. Real QZ conjugate pairs are returned as complex `mp` values so their imaginary components are not discarded. Mixed real/complex pencils are promoted once to MPC at the maximum stored operand precision.

For a singular or ill-conditioned pencil, use the residual relations and inspect the `beta == 0` cases. Do not compare eigenvalue vectors by position: QZ ordering and eigenvector normalization are not canonical. The detailed compatibility and reconstruction notes are in `docs/generalized-eig.md`.

### Singular value decomposition

The dense SVD interface is:

    s = svd (A)
    [U, S, V] = svd (A)
    [U, S, V] = svd (A, "econ")
    [U, S, V] = svd (A, 0)

The numeric `0` form is accepted as the deprecated economy spelling. Two-output SVD calls are rejected; request either the singular values or all three factors. If `A` is `m` by `n`, let `k = min (m, n)`. The one-output result is a real `mp` column of `k` nonnegative singular values in descending order. The full factors have shapes `U`: `m` by `m`, `S`: `m` by `n`, and `V`: `n` by `n`. Economy factors have shapes `m` by `k`, `k` by `k`, and `n` by `k`.

For real input the factors are real and the reconstruction is `A = U*S*transpose(V)`. For complex input `U` and `V` are complex `mp`, `S` remains real, and the reconstruction is `A = U*S*ctranspose(V)`. Full factors are orthogonal or unitary; economy factors have orthonormal columns. Singular vectors can change sign or complex phase, especially for repeated or clustered singular values. Check reconstruction and orthogonality rather than individual factor entries.

SVD uses MPLAPACK `Rgesvd` for real input and `Cgesvd` for complex input. The input buffer, factors, singular values, and workspaces are operation-owned storage at one uniform precision. The input is not modified. The operation precision comes from the stored input precision, not from the ambient default at the time of the call. No SVD path calls builtin Octave `svd` or reduces through binary64.

The following Hilbert example is more informative than a diagonal test: the matrix is dense, non-diagonal, and ill-conditioned. Its entries are created from decimal `mp` values, so the Hilbert matrix is not first created by the builtin binary64 `hilb` function:

    mpbits (512);
    n = 8;
    H = mp (zeros (n, n));
    for i = 1:n
      for j = 1:n
        H(i,j) = mp (1) / mp (i + j - 1);
      endfor
    endfor
    [U, S, V] = svd (H);
    reconstruction = norm (H - U*S*V', "fro") / norm (H, "fro");
    left_orthogonality = norm (U'*U - mp (eye (n)), "fro");
    right_orthogonality = norm (V'*V - mp (eye (n)), "fro");
    disp (diag (S));
    disp (reconstruction);
    disp (left_orthogonality);
    disp (right_orthogonality);

For a high-condition-number problem, increase `mpbits` before creating the input and choose tolerances from the requested precision and problem conditioning. A later change to `mpbits` does not change an existing matrix or the precision of an already-created SVD result. `pinv`, `null`, `orth`, and `rref` use singular values or related rank decisions and therefore require the same tolerance discipline.

### Schur Hessenberg and QZ decompositions

The Hessenberg and Schur interfaces provide useful intermediate forms:

    H = hess (A)
    [P, H] = hess (A)
    S = schur (A)
    [U, S] = schur (A)
    [U, S] = schur (A, "complex")
    [AA, BB, Q, Z] = qz (A, B)
    [AA, BB, Q, Z] = qz (A, B, "real")

The two-output Hessenberg form satisfies `P*H*P' = A`; `H` is upper Hessenberg and `P` is orthogonal or unitary. The default Schur type is `"real"` for real input and `"complex"` for complex input. The two-output Schur form satisfies `S = U'*A*U`. A real Schur form can contain 2-by-2 blocks for conjugate pairs; a complex Schur form is triangular. The factors and their ordering are not unique, and Schur reordering selectors are not part of this public interface.

The generalized Schur (QZ) interface returns the orientation used by this package: `Q*A*Z = AA` and `Q*B*Z = BB`. The default QZ type is complex; `"real"` requests the real generalized Schur form for a real pencil. The diagonal or 2-by-2 blocks encode the generalized eigenvalues; the `alpha`/`beta` interpretation and infinite-eigenvalue rule are the same as for generalized `eig`. QZ is a decomposition of a pencil, not an inverse of `B`, so it remains usable when `B` is singular.

For all of these routines use the exact reconstruction orientation above. Do not substitute a transpose for a conjugate transpose in a complex test, and do not assume that two valid runs return the same signs, phases, or block ordering. The optional Schur/QZ ordering helpers remain intentionally deferred.

### Precision and validation

Every eig, SVD, Hessenberg, Schur, and QZ call selects one operation precision from its stored input operands. For a generalized problem this is the maximum stored precision of `A` and `B`. The native wrapper enters the matching MPFR/MPC precision scope, converts real values to complex values once when promotion is required, and restores the caller’s ambient precision on return. A new worker thread does not inherit a parent thread’s precision automatically; a worker must establish its own scope at entry.

The LAPACK drivers destructively overwrite their input buffers. The public `mp` payload is immutable, so the wrapper always passes an operation-owned copy and leaves the input unchanged. Workspace queries and driver status values are checked before results are returned. The complex paths use MPC-native storage throughout and never silently fall back to builtin binary64 complex arithmetic.

For a normal validation, compute a relative residual such as `norm (A*V - V*D, "fro") / norm (A, "fro")`, an orthogonality or unitarity residual such as `norm (U'*U - eye (n), "fro")`, and the appropriate generalized relation. Keep the residual as an `mp` value until the final display or an explicitly justified pass/fail conversion. At 1024 bits, test a `2^-700` tail; at 2048 bits, test a `2^-1500` tail. Also test with a low ambient default, a high ambient default, and a restored default to ensure that the operation precision belongs to the input and not to unrelated global state.

The focused API and backend notes are maintained in `docs/eig.md`, `docs/generalized-eig.md`, and `docs/svd.md`; the runnable examples are `examples/06_grcar_eig.m`, `examples/07_svd_hilbert.m`, and `examples/08_advanced_dense.m`.

## Matrix functions

`expm`, `logm`, and `sqrtm` use package-owned arbitrary- precision matrix algorithms with MPFR/MPC working values. Principal branches and branch cuts can promote a real input to complex. Validate matrix identities and inspect conditioning near a branch cut.

`mpower` for integer square matrices uses exponentiation by squaring; noninteger matrix powers are deferred. `polyvalm` evaluates a polynomial at a dense matrix.

## Elementary and special functions

The supported scalar/element-wise elementary family includes `sqrt`, `cbrt`, `exp`, `expm1`, `log`, `log1p`, `log10`, `log2`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `sinh`, `cosh`, `tanh`, `asinh`, `acosh`, `atanh`, `hypot`, and `atan2`. Real domain crossings use the documented MPC promotion rules.

The supported MPFR-backed special family is `gamma`, `gammaln`, `lgamma`, `erf`, and `erfc`. Poles, signed zeros, infinities, NaNs, and domain branches are tested explicitly. Other special-function families are deferred and rejected cleanly.

## Polynomial operations

`poly`, `polyval`, `polyvalm`, `roots`, `conv`, `deconv`, `polyder`, `polyint`, and `compan` operate on arbitrary-precision coefficient or root data. Polynomial roots are conditioning-sensitive; clustered roots can move materially when precision changes. Use residuals such as `polyval (p, roots (p))` and not only elementwise root matching.

    p = mp ({"1", "-3", "2"});
    r = roots (p);
    residual = norm (polyval (p, r));
    disp (residual);

`polyfit` and `polyeig` remain deferred.

## Set operations

`unique`, `union`, `intersect`, `setdiff`, `setxor`, and `ismember` support the documented dense real/complex forms, including stable and row options where implemented. Equality and ordering use native values; NaN membership follows the documented Octave compatibility rule. `ismembertol` is deferred.

## Serialization and save/load

The `saveobj` and `loadobj` hooks use schema `octave-mplapack-mp`, version 1. The schema records kind, shape, stored precision, and canonical text elements in column-major order. It preserves finite values, signed zero, infinity, NaN classification, and complex components without raw pointers or MPFR limb dumps.

    mpbits (1024);
    A = mp ({"1.234567890123456789", "-0"; "Inf", "NaN"});
    save ("/tmp/mp-example.mat", "A");
    clear A;
    load ("/tmp/mp-example.mat");
    disp (A);

The package must be loaded before loading an `mp` object. Malformed or newer schemas are rejected rather than guessed.

## Graphics

`plot`, `plot3`, `loglog`, `semilogx`, `semilogy`, `scatter`, `scatter3`, `stem`, `stairs`, `mesh`, `surf`, `contour3`, `meshc`, `surfc`, and `waterfall` are boundary wrappers. They explicitly convert only final visualization data to builtin `double`; all numerical calculation before plotting remains MPFR/MPC. This is the documented exception to the no-binary64-fallback rule.

    t = linspace (mp ("0"), mp ("6.283185307179586476925286766559"), 32);
    y = sin (t);
    plot (double (t), double (y));

For a package `mp` graphics call, the wrapper performs the conversion. For values outside the binary64 range, transform or scale in `mp` before the graphics boundary. N-D and volume graphics, and `meshgrid` for `mp`, are deferred.

## Arbitrary-precision random numbers

`mprand`, `mprandn`, and `mprandi` use the package’s `xorshift128plus-v1` engine and generate p-bit values directly. They are not cryptographic. `mprng` controls the seed and serializable state. Fixed seed/state is required for reproducibility.

    mprng ("seed", uint64 (7));
    u1 = mprand (2, 1);
    mprng ("seed", uint64 (7));
    u2 = mprand (2, 1);
    assert (isequal (u1, u2));

## Interpolation

`interp1` and `interp2` use MPFR/MPC grids, query points, and piecewise-polynomial values. `pchip`, `spline`, `mkpp`, `unmkpp`, `ppval`, `ppder`, and `ppint` operate on the supported scalar/vector piecewise-polynomial contract. Query-grid precision matters: a query that collapses to a double grid point may remain distinct at MPFR precision. Extrapolation is explicit. `interp3`, `interpn`, and matrix-valued PP output are deferred.

## Nonlinear equations

`fzero` accepts a scalar start or sign-changing bracket; `fsolve` accepts real scalar/vector starts. Callbacks receive `mp` values and must return `mp` values. `TolX`, `TolFun`, finite-difference steps, and stopping checks are precision-aware. Complex nonlinear callbacks are deferred.

    mpbits (512);
    target = mp ("1.25");
    [root, fval, info] = fzero (@(x) x*x - target*target, mp ({"0", "2"}));
    assert (info == 1);
    assert (abs (root - target) < mp ("1e-40"));

## Numerical integration

`integral` and `quadgk` use MP nodes, weights, transforms, and error estimates. Scalar callbacks may return real or complex `mp`; builtin double and array-valued callback results are rejected. Finite and infinite intervals, waypoints, and precision-aware absolute/relative tolerances are supported. `ArrayValued` remains deferred.

    options = struct ("AbsTol", mp ("1e-40"), "RelTol", mp ("1e-40"));
    [value, err] = integral (@(x) x*x, mp ("0"), mp ("1"), options);
    assert (abs (value - mp ("1")/mp ("3")) < mp ("1e-35"));

## Optimization

`fminbnd` uses an MPFR safeguarded golden-section search and `fminsearch` uses an MPFR Nelder–Mead simplex. Objective callbacks must return finite real `mp` scalars. `TolX`, `TolFun`, iteration limits, and evaluation limits are precision-aware. `fminunc` remains deferred.

## Performance notes

Higher precision increases scalar arithmetic cost and can increase workspace and serialization size. Dense algorithm dimension scaling remains that of the selected algorithm. MPLAPACK-backed calls and package-owned MPFR/MPC algorithms have different constant factors. RNG generation cost grows with requested precision. Graphics deliberately loses arbitrary precision at the final display boundary.

## Octave compatibility

The supported surface follows ordinary Octave syntax where the dense two-dimensional `mp` contract permits it. The authoritative compatibility boundaries are `docs/octave-script-compatibility.md` and `docs/advanced-numerics-compatibility.md`. Unsupported calls involving `mp` fail through package-owned diagnostics rather than silently delegating to builtin binary64 implementations.

For exact supported forms, consult `docs/public-api-inventory.md`. The public package name is `mplapack-interop`; the public numeric class is `mp`. Native `__mplapack_core__` operations are implementation details and are not user API.

## Deferred and unsupported functionality

The following are intentionally deferred: optional Schur/QZ ordering helpers, `funm`, `polyfit`, `polyeig`, `ismembertol`, remaining special-function families, `meshgrid` for `mp`, volume/N-D graphics, matrix-valued PP output, `interp3`, `interpn`, complex nonlinear callbacks, `ArrayValued` quadrature, and `fminunc`. Sparse, symbolic, N-D, and unrelated ODE/PDE surfaces are also outside the current contract.

Each deferred item has a re-entry record under `docs/todo/`; a missing form must not be implemented by a builtin-double fallback. These limitations are part of the release documentation, not hidden omissions.

## Troubleshooting

`pkg load` fails
Confirm the package is installed, the package name is `mplapack-interop`, and Octave’s package directory is on its path.

MPLAPACK runtime is not found
Check `pkg-config --modversion mplapack_mpfr`, the installed library search path, and the runtime environment used to start Octave. Do not add a developer source directory as a workaround.

Precision unexpectedly looks low
Construct from decimal text, set `mpbits` before construction, and remember that changing the default cannot restore information lost by a previous binary64 constructor.

Version or dependency mismatch
Use `mplapack_version ()` and `pkg-config`. D04 currently records MPLAPACK 3.0.1 as a release candidate, not a completed release.

Graphics overflow or underflow
Perform scaling or logarithms in `mp`, then explicitly convert the final display data.

Callback or serialization error
Return `mp` from nonlinear/integration/optimization callbacks and load the package before restoring an `mp` object. Check schema version and stored precision.

## API quick reference

The following entries make every public name searchable. Related functions share a short example in the preceding task chapter and have individual help text in the corresponding Octave method/function file. The inventory is the machine-auditable coverage matrix.

**Construction and inspection**

`mp`, `mpbits`, `mpdigits`, `mplapack_version`, `properties`, `char`, `disp`, `double`, `real`, `imag`, `conj`, `isreal`, `isnumeric`, `isnan`, `isinf`, `isfinite`, `isequal`, `isequaln`.

**Arithmetic**

`plus`, `minus`, `times`, `rdivide`, `uplus`, `uminus`, `mtimes`, `mldivide`, `mrdivide`, `power`, `mpower`, `abs`, `arg`, `angle`, `sign`.

**Dense structure and indexing**

`size`, `rows`, `columns`, `numel`, `ndims`, `length`, `isempty`, `subsref`, `subsasgn`, `end`, `reshape`, `transpose`, `ctranspose`, `horzcat`, `vertcat`, `cat`, `diag`, `triu`, `tril`, `repmat`, `flip`, `fliplr`, `flipud`, `rot90`, `zeros`, `ones`, `eye`, `nan`, `NaN`, `inf`, `Inf`.

**Logical operations and reductions**

`eq`, `ne`, `lt`, `le`, `gt`, `ge`, `logical`, `and`, `or`, `xor`, `not`, `any`, `all`, `find`, `sum`, `prod`, `cumsum`, `cumprod`, `sumsq`, `min`, `max`, `mean`, `median`, `var`, `std`, `range`, `bounds`, `sort`, `diff`, `signbit`, `floor`, `ceil`, `fix`, `round`, `rem`, `mod`, `hypot`, `atan2`, `eps`, `colon`, `linspace`, `logspace`.

**Factorizations and conditioning**

`chol`, `qr`, `lu`, `norm`, `det`, `inv`, `rank`, `cond`, `rcond`, `svd`, `pinv`, `null`, `orth`, `rref`.

**Eigenproblems and matrix functions**

`eig`, `hess`, `balance`, `schur`, `qz`, `kron`, `expm`, `logm`, `sqrtm`.

**Elementary and special functions**

`sqrt`, `cbrt`, `exp`, `expm1`, `log`, `log1p`, `log10`, `log2`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `sinh`, `cosh`, `tanh`, `asinh`, `acosh`, `atanh`, `gamma`, `gammaln`, `lgamma`, `erf`, `erfc`.

**Polynomials and sets**

`poly`, `polyval`, `polyvalm`, `roots`, `conv`, `deconv`, `polyder`, `polyint`, `compan`, `unique`, `union`, `intersect`, `setdiff`, `setxor`, `ismember`.

**Serialization, random numbers, interpolation, solvers, and optimization**

`saveobj`, `loadobj`, `mprand`, `mprandn`, `mprandi`, `mprng`, `interp1`, `interp2`, `pchip`, `spline`, `ppval`, `mkpp`, `unmkpp`, `ppder`, `ppint`, `fzero`, `fsolve`, `integral`, `quadgk`, `fminbnd`, `fminsearch`.

**Graphics boundary**

`plot`, `plot3`, `loglog`, `semilogx`, `semilogy`, `scatter`, `scatter3`, `stem`, `stairs`, `mesh`, `surf`, `contour3`, `meshc`, `surfc`, `waterfall`.

**See also**

`docs/public-api-inventory.md`, `docs/advanced-numerics-compatibility.md`, `docs/precision-semantics.md`, and the per-topic documents in `docs/`.
