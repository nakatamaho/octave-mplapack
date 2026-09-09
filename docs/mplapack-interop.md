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

`eig` has structured, general, and generalized forms. Structured real symmetric and complex Hermitian inputs use `Rsyevd`/`Cheevd`. General problems use `Rgeevx`/`Cgeevx`. Generalized definite and QZ forms use `Rsygvd`/`Chegvd` and `Rggev`/`Cggev`.

Eigenvalue order is not canonical. Eigenvector scale and complex phase are not canonical either, so validate residuals rather than elementwise vectors. For a standard problem use `A*V = V*D`; for a generalized problem use `A*V = B*V*D`. Three-output forms return left vectors and should be checked with the corresponding conjugate-transpose identity.

The required Grcar example is:

    mpbits (1024);
    A = mp (gallery ("grcar", 32));
    [V, D] = eig (A);
    r = norm (A*V - V*D, "fro") / norm (A, "fro");
    disp (r);

`schur`, `hess`, and `qz` have non-unique factors. QZ generalized eigenvalues may be represented by an `alpha`/`beta` pair; `beta == 0` represents an infinite eigenvalue. Reconstruction orientation is part of the API contract and is documented in `docs/eig.md` and `docs/generalized-eig.md`.

`svd`, `pinv`, `null`, `orth`, and `rref` are sensitive to singular-value tolerances. Singular-vector signs/phases are non-unique; use reconstruction, orthogonality, and projector residuals.

    n = 8;
    H = mp (zeros (n, n));
    for i = 1:n
      for j = 1:n
        H(i,j) = mp (1) / mp (i + j - 1);
      endfor
    endfor
    [U, S, V] = svd (H);
    sv = diag (S);
    svd_residual = norm (H - U*S*V', "fro") / norm (H, "fro");
    disp (sv);
    disp (svd_residual);

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
