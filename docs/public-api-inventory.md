# Public API inventory

This is the machine-auditable DOC00 coverage matrix. The inventory is
derived from the public `inst/@mp/*.m` methods and package-level
`inst/*.m` functions. Files below `inst/@mp/private/` and `inst/private/`
are implementation helpers and are intentionally excluded.

Status meanings: `SUPPORTED` is part of the tested public surface;
`PARTIAL` means only the listed forms are supported; `DEFERRED` is not a
supported call; `INTERNAL` is an Octave dispatch hook rather than a user
entry point. A supported entry has a help block, a manual/MP note, a
pasteable example or grouped example, and a backend/algorithm reference.

The difficult nonsymmetric eigensystem harness under
`examples/nonsymmetric_eig/` is a repository-local example/QA surface built
from existing public APIs. It intentionally has no additional package-level
API row; its runnable entry point and coverage are recorded in
`docs/nonsymmetric-eig-suite.md` and the compatibility matrix.

| API | Kind | Status | Manual/MP notes | Help | Example | Backend/Doxygen |
|---|---|---|---|---|---|---|
| `mp` | @mp method/constructor | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/01_scalar_precision.m` | `docs/backend-map.md`; Doxygen |
| `Inf` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `NaN` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `abs` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `acos` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `acosh` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `all` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `and` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `angle` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `any` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `arg` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `asin` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `asinh` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `atan` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `atan2` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `atanh` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `balance` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `bounds` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `cat` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `cbrt` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `ceil` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `char` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `chol` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `colon` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `columns` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `compan` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/08_advanced_dense.m` or grouped | `docs/backend-map.md`; Doxygen |
| `cond` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/07_svd_hilbert.m` or grouped | `docs/backend-map.md`; Doxygen |
| `conj` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `contour3` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `conv` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/08_advanced_dense.m` or grouped | `docs/backend-map.md`; Doxygen |
| `cos` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `cosh` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `ctranspose` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `cumprod` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `cumsum` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `deconv` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/08_advanced_dense.m` or grouped | `docs/backend-map.md`; Doxygen |
| `det` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `diag` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `diff` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `disp` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `double` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `eig` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/07_svd_hilbert.m` or grouped | `docs/backend-map.md`; Doxygen |
| `end` |dispatch method| INTERNAL | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `eps` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `eq` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `erf` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `erfc` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `exp` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `expm` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/08_advanced_dense.m` or grouped | `docs/backend-map.md`; Doxygen |
| `expm1` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `eye` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `find` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `fix` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `flip` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `fliplr` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `flipud` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `floor` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `gamma` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `gammaln` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `ge` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `gt` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `hess` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/07_svd_hilbert.m` or grouped | `docs/backend-map.md`; Doxygen |
| `horzcat` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `hypot` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `imag` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `inf` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `intersect` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `inv` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `isempty` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `isequal` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `isequaln` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `isfinite` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `isinf` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `ismember` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `isnan` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `isnumeric` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `isreal` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `kron` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `le` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `length` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `lgamma` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `linspace` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `loadobj` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/09_serialization_rng.m` or grouped | `docs/backend-map.md`; Doxygen |
| `log` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `log10` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `log1p` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `log2` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `logical` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `loglog` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `logm` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/08_advanced_dense.m` or grouped | `docs/backend-map.md`; Doxygen |
| `logspace` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `lt` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `lu` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `max` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mean` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `median` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mesh` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `meshc` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `min` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `minus` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mldivide` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mod` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mpower` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mrdivide` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mtimes` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `nan` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `ndims` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `ne` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `norm` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/07_svd_hilbert.m` or grouped | `docs/backend-map.md`; Doxygen |
| `not` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `null` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/07_svd_hilbert.m` or grouped | `docs/backend-map.md`; Doxygen |
| `numel` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `ones` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `or` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `orth` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/07_svd_hilbert.m` or grouped | `docs/backend-map.md`; Doxygen |
| `pinv` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/07_svd_hilbert.m` or grouped | `docs/backend-map.md`; Doxygen |
| `plot` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `plot3` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `plus` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `poly` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/08_advanced_dense.m` or grouped | `docs/backend-map.md`; Doxygen |
| `polyder` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/08_advanced_dense.m` or grouped | `docs/backend-map.md`; Doxygen |
| `polyint` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/08_advanced_dense.m` or grouped | `docs/backend-map.md`; Doxygen |
| `polyval` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/08_advanced_dense.m` or grouped | `docs/backend-map.md`; Doxygen |
| `polyvalm` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/08_advanced_dense.m` or grouped | `docs/backend-map.md`; Doxygen |
| `power` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `prod` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `properties` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `qr` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `qz` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/07_svd_hilbert.m` or grouped | `docs/backend-map.md`; Doxygen |
| `range` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `rank` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/07_svd_hilbert.m` or grouped | `docs/backend-map.md`; Doxygen |
| `rcond` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/07_svd_hilbert.m` or grouped | `docs/backend-map.md`; Doxygen |
| `rdivide` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `real` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `rem` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `repmat` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `reshape` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `roots` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/08_advanced_dense.m` or grouped | `docs/backend-map.md`; Doxygen |
| `rot90` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `round` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `rows` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `rref` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/07_svd_hilbert.m` or grouped | `docs/backend-map.md`; Doxygen |
| `saveobj` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/09_serialization_rng.m` or grouped | `docs/backend-map.md`; Doxygen |
| `scatter` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `scatter3` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `schur` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/07_svd_hilbert.m` or grouped | `docs/backend-map.md`; Doxygen |
| `semilogx` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `semilogy` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `setdiff` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `setxor` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `sign` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `signbit` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `sin` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `sinh` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `size` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `sort` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `sqrt` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `sqrtm` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/08_advanced_dense.m` or grouped | `docs/backend-map.md`; Doxygen |
| `stairs` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `std` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `stem` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `subsasgn` |dispatch method| INTERNAL | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `subsref` |dispatch method| INTERNAL | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `sum` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `sumsq` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `surf` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `surfc` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `svd` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/07_svd_hilbert.m` or grouped | `docs/backend-map.md`; Doxygen |
| `tan` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `tanh` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `times` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `transpose` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `tril` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `triu` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `uminus` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `union` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `unique` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `uplus` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `var` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `vertcat` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `waterfall` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/12_graphics_boundary.m` or grouped | `docs/backend-map.md`; Doxygen |
| `xor` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `zeros` | @mp method| SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `fminbnd` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/11_solvers_quadrature_optimization.m` or grouped | `docs/backend-map.md`; Doxygen |
| `fminsearch` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/11_solvers_quadrature_optimization.m` or grouped | `docs/backend-map.md`; Doxygen |
| `fsolve` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/11_solvers_quadrature_optimization.m` or grouped | `docs/backend-map.md`; Doxygen |
| `fzero` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/11_solvers_quadrature_optimization.m` or grouped | `docs/backend-map.md`; Doxygen |
| `integral` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/11_solvers_quadrature_optimization.m` or grouped | `docs/backend-map.md`; Doxygen |
| `interp1` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/10_interpolation.m` or grouped | `docs/backend-map.md`; Doxygen |
| `interp2` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/10_interpolation.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mkpp` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/10_interpolation.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mpbits` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mpdigits` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mplapack_version` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/02_matrix_arithmetic.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mprand` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/09_serialization_rng.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mprandi` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/09_serialization_rng.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mprandn` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/09_serialization_rng.m` or grouped | `docs/backend-map.md`; Doxygen |
| `mprng` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/09_serialization_rng.m` or grouped | `docs/backend-map.md`; Doxygen |
| `pchip` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/10_interpolation.m` or grouped | `docs/backend-map.md`; Doxygen |
| `ppder` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/10_interpolation.m` or grouped | `docs/backend-map.md`; Doxygen |
| `ppint` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/10_interpolation.m` or grouped | `docs/backend-map.md`; Doxygen |
| `ppval` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/10_interpolation.m` or grouped | `docs/backend-map.md`; Doxygen |
| `quadgk` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/11_solvers_quadrature_optimization.m` or grouped | `docs/backend-map.md`; Doxygen |
| `spline` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/10_interpolation.m` or grouped | `docs/backend-map.md`; Doxygen |
| `unmkpp` | package function | SUPPORTED | User manual § API quick reference; precision/compatibility notes | yes | `examples/10_interpolation.m` or grouped | `docs/backend-map.md`; Doxygen |

## Intentionally deferred public forms

| API/form | Status | Re-entry record |
|---|---|---|
| `funm` | DEFERRED | [docs/todo/T02-funm.md](docs/todo/T02-funm.md) |
| `polyfit` | DEFERRED | [docs/todo/T03-polyfit-polyeig.md](docs/todo/T03-polyfit-polyeig.md) |
| `polyeig` | DEFERRED | [docs/todo/T03-polyfit-polyeig.md](docs/todo/T03-polyfit-polyeig.md) |
| `ismembertol` | DEFERRED | [docs/todo/T04-ismembertol.md](docs/todo/T04-ismembertol.md) |
| `meshgrid` | DEFERRED | [docs/todo/T08-meshgrid.md](docs/todo/T08-meshgrid.md) |
| `interp3` | DEFERRED | [docs/todo/T11-ND-interpolation.md](docs/todo/T11-ND-interpolation.md) |
| `interpn` | DEFERRED | [docs/todo/T11-ND-interpolation.md](docs/todo/T11-ND-interpolation.md) |
| `fminunc` | DEFERRED | [docs/todo/T14-fminunc.md](docs/todo/T14-fminunc.md) |
| `ArrayValued` | DEFERRED | [docs/todo/T13-array-valued-quadrature.md](docs/todo/T13-array-valued-quadrature.md) |

The deferred forms are not included as supported rows and must fail through the documented compatibility boundary; they must never fall through to builtin binary64 numerical execution.
