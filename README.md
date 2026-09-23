# octave-mplapack

**Local maintenance release: `mplapack-interop 0.5.1` (2026-09-23).**
The source is recorded in the local annotated tag `v0.5.1`; the published
`v0.5.0` tag and archive remain immutable. GitHub/PPA uploads are deferred.
This maintenance release closes the Ubuntu 26.04 installer compatibility
issue and provides GNU Octave access to real and complex arbitrary-precision
linear algebra through the native `mp` type.

## Quick start

Ubuntu 26.04 only (the helper is not release-tested on other systems):

First install the system dependencies:

```sh
sudo apt-get update && sudo apt-get install -y build-essential cmake pkg-config autoconf automake libtool libgmp-dev libmpfr-dev libmpc-dev octave octave-dev xz-utils curl
```

Then, in a separate command, download and run the user-level installer:

```sh
curl -fsSL https://raw.githubusercontent.com/nakatamaho/octave-mplapack/main/tools/install-local-octave-mplapack.sh | sh
```

Run these two commands in order; do not paste them onto one shell line. The
second command does not use `sudo`, and writes under your home directory. The
installer selects gmpfrxx_mkII 1.5.0 and the published 0.5.0 package by
default. It also repairs installed MPLAPACK `.pc` metadata on Ubuntu systems
where `libmpc-dev` does not provide `mpc.pc`. To test the local 0.5.1 archive,
select it explicitly with `OCTAVE_CHANNEL=candidate`, `OCTAVE_TAR`, and
`OCTAVE_SHA256`. The installer prints the wrapper path. With the default
paths, start it from the shell as follows:

```sh
$HOME/.local/share/mplapack-interop/stack/bin/octave-mplapack
```

The wrapper is the normal Octave startup command; it loads
`mplapack-interop` automatically and suppresses only the noisy
`Octave:shadowed-function` notice for compatibility wrappers. At the Octave
prompt, run the example directly:

For example, compute a 2x2 multiple-precision SVD:

```octave
A = mp ([3, 1; 0, 2]);
[U, S, V] = svd (A);
disp (S)
assert (norm (double (A - U * S * V'), "fro") < 1e-12)
```

The compatibility wrappers are not removed. If you use ordinary `octave`
instead of the wrapper and want to control the notice yourself, run
`warning ('off', 'Octave:shadowed-function')` before `pkg load mplapack-interop`.

## News

### 0.5.1 — 2026-09-23

- The installer now uses gmpfrxx_mkII 1.5.0 by default. The published 0.5.0
  package remains the default; the local 0.5.1 archive is an explicit candidate.
- Installed MPLAPACK `.pc` metadata is normalized downstream so
  `pkg-config --cflags --libs mplapack_mpfr` works without a system `mpc.pc`.
- Complex `log2` uses gmpfrxx `mpfrxx::log2` over MPC rather than a direct
  `mpc_log2` symbol dependency.
- The new runnable `examples/18_complex_log2.m` covers the native complex path.

The published 0.5.0 tag and archive remain immutable. The 0.5.1 commit and
tag are local; GitHub, Debian, and PPA uploads are deferred.

### 0.5.0 — 2026-09-15

- First public real-plus-complex release of `mplapack-interop`.
- Supports dense linear algebra, SVD/eigenvalue problems, Schur/QZ,
  matrix functions, polynomial utilities, interpolation, solvers,
  quadrature, optimization, serialization, and documented compatibility
  helpers.
- Complex paths include `Cgemm`, `Cgesv`, `Cgelsy`, `Cpotrf`, QR, pivoted QR,
  and the mandatory `Cgetrf` LU path.
- Uses MPLAPACK 3.0.1 and gmpfrxx_mkII 1.4.1 with MPFR/MPC precision
  semantics and no builtin binary64 complex fallback.
- Release QA passed the real/complex regression walls, precision canaries,
  package lifecycle, documentation checks, and native sanitizer suite.

See [`NEWS.md`](NEWS.md) for the detailed release history. The exact frozen
dependency handoff is in
[`docs/dependency-release-stack-r1.md`](docs/dependency-release-stack-r1.md).

## Goal

`mplapack-interop` provides GNU Octave access to MPLAPACK multiple-precision
linear algebra through an Octave-native multiprecision numeric type named
`mp`. MPLAPACK is the numerical backend rather than the user-facing
programming model.

## Documentation

The task-oriented [user manual](doc/mplapack-interop.texi) covers installation,
precision, real/complex behavior, dense linear algebra, advanced numerics,
serialization, graphics, random generation, interpolation, solvers,
quadrature, optimization, and troubleshooting. The [public API inventory]
(docs/public-api-inventory.md) is the complete machine-auditable coverage
matrix. The [advanced compatibility matrix]
(docs/advanced-numerics-compatibility.md) records supported and deferred
forms, while the [backend map](docs/backend-map.md) connects public calls to
native algorithms. Runnable examples are under
[examples/](examples/01_scalar_precision.m). Developer documentation is
generated from [docs/doxygen/Doxyfile](docs/doxygen/Doxyfile). A generated
[Markdown version of the manual](docs/mplapack-interop.md) is also provided;
edit the Texinfo source and run `tools/build-manual-markdown.sh` to refresh it.
The difficult SVD example/verification suite is documented in
[`docs/svd-tiers.md`](docs/svd-tiers.md) and
[`docs/svd-verification.md`](docs/svd-verification.md), with runnable defaults
in `examples/14_svd_tier_s.m` through `examples/16_svd_verified.m`.
The one-case worked examples are indexed by
[`docs/examples/tiered/README.md`](docs/examples/tiered/README.md), with a
matching explanation for every NEIGT/SVT Tier S/A case. The GitHub Markdown
piecewise-rendering policy and migration record are in
[`docs/math-rendering-migration.md`](docs/math-rendering-migration.md).

For a checkout, `tools/dev-octave.sh` verifies the `pkg-config` dependency,
builds the native module, and starts a configured development session. It does
not replace clean package/install QA.

The current surface includes dense real and complex `mp`, precision-controlled
construction, arithmetic, mixed real/complex `*`, `\`, and `/`, indexing and
in-bounds assignment, `chol`, full/economy and pivoted `qr`, `lu`, `norm`,
`det`, `inv`, `svd`, `rank`, `cond`, `rcond`, structured and general standard
and generalized `eig`, dense concatenation, element-wise power, integer
matrix powers, native elementary functions, reductions, and extrema. S03 also
provides native comparisons, logical conversion and operators, `any`/`all`,
`find`, and logical indexing. S04 adds native dense matrix utilities
(`diag`, `triu`/`tril`, `repmat`, flips, `rot90`, `cat(1/2)`) and explicit
`"like"` constructors for `mp` templates. S05 adds native sequences,
rounding, spacing, and utility arithmetic; S06 adds descriptive statistics;
S07 adds common line-graphics wrappers; and S08 closes the ordinary dense
script corpus with native `sort`/`diff` and structural compatibility. Sparse,
surface-graphics, and N-D APIs remain explicitly unsupported; see the
[advanced numerical compatibility](docs/advanced-numerics-compatibility.md),
[complex API](docs/complex-api.md), and [compatibility limits](docs/complex-compatibility.md).

### Hilbert inverse example

The package includes a 1024-bit Hilbert inverse example in
[`examples/05_hilbert_inverse.m`](examples/05_hilbert_inverse.m). It constructs
each `1/(i+j-1)` from decimal `mp` values and computes all inverse columns as
`H \ I`; this avoids the binary64 matrix produced by builtin `hilb(n)`. N01
also provides the explicit `inv(H)` API.

The external MPLAPACK C++ consumer boundary is validated separately by the
MPLAPACK release QA. Its source is intentionally not copied into this Octave
package's examples.

The required MPLAPACK MPFR dependency is discovered through `pkg-config` and
must provide the uniform-precision scope interface. The package never vendors
or searches a developer-specific MPLAPACK path.

### Difficult nonsymmetric eigensystem examples

The repository also includes a high-precision QA/example suite for nonnormal
eigenproblems. It covers Hadamard-similar, Frank, companion, and two Forsythe
representations with both `balance` and `nobalance`; see
[`docs/nonsymmetric-eig-suite.md`](docs/nonsymmetric-eig-suite.md) and run
`tools/run-nonsymmetric-eig-suite.sh smoke` from a configured checkout.

### Verified NEIGT tiers

The manifest-driven Tier-S/Tier-A and verified V-S/V-A examples are available
as [`examples/14_neig_tier_s.m`](examples/14_neig_tier_s.m),
[`examples/15_neig_tier_a.m`](examples/15_neig_tier_a.m),
[`examples/16_neig_verified_vs.m`](examples/16_neig_verified_vs.m), and
[`examples/17_neig_verified_va.m`](examples/17_neig_verified_va.m). They are
repository-local QA/example entry points built from the existing public
`mp`/`mpbits`/`eig`/`svd`/`qr`/solve interfaces; they do not add package-level
numeric methods. The ordinary smoke/demo profiles measure 120/168 eig rows,
and each profile has 26 separately counted verification jobs.

The V layer is a conservative outward-safe proof baseline. It records exact
MP inputs, candidate provenance, proof preconditions, and certificate status;
it does not turn residuals or precision agreement into a proof. Use
`mp_neig_write_outputs` for a new-directory result bundle and
`mp_neig_replay` to independently replay its hash-bound V-S1 artifact. The
`plot=false` path is headless and all display conversion is kept at the final
presentation boundary. See the [NEIGT compatibility notes](docs/advanced-numerics-compatibility.md)
and the generated [user manual](docs/mplapack-interop.md).

## Initial backend

The backend is MPLAPACK's MPFR/MPC implementation for real and complex values.
MPLAPACK remains a separately installed dependency discovered through
`pkg-config`; it is not vendored here.

## Working diagnostic

With the current source package installed:

```octave
pkg load mplapack-interop
info = mplapack_version()

a = mp("0.1");
b = mp(0.1);

mpbits()
% 512

mpdigits(100);
mpbits()
% 333

c = mp("0.1");

s = char(c)
d = double(c)
disp(c)

sum_value = a + b
difference = a - b
product = a .* b
quotient = a ./ b

A = mp ({"1", "2";
         "3", "4"});
B = mp ([1, 2;
         3, 4]);
size (A)
% 2 2
C = A * A
x = A \ b
R = mp ({"1", "0"; "0", "1"; "1", "1"});
r = mp ({"0"; "1"; "4"});
least_squares = R \ r
element = A(2, 1)
column = A(:, 2)
double_A = double(A)
disp(A)
R = chol (mp ({"4", "2"; "2", "10"}));
[Q, R] = qr (mp ([1, 2; 3, 4; 5, 7]));
% native MPLAPACK MPFR Rgemm/Rgesv/Rgelss/Rpotrf/Rgeqrf/Rorgqr/Rgeqp3 results
```

This loads the private native module, reports the Octave, MPLAPACK, and MPFR
versions, and executes the MPLAPACK MPFR `Rlamch_mpfr` probe. The constructor
creates immutable public `1 x 1` scalar values. A fresh process starts at 512
bits. `mpbits` controls the canonical bit precision and `mpdigits(n)` selects
`ceil(n * log2(10))` bits without hidden guard bits. In the example, `a` and
`b` remain 512-bit values while `c` uses 333 bits. `char(c)` returns canonical
decimal text that reconstructs the same MPFR value when parsed at `c`'s
precision. `double(c)` is an explicit, potentially lossy binary64 conversion;
`disp(c)` prints the canonical multiprecision text.

Scalar arithmetic uses MPFR round-to-nearest.  For two `mp` operands the
result precision is the greater stored operand precision; with one real
scalar `double`, the `mp` operand precision is used.  The current default does
not affect an arithmetic result.  For example, `a + 0.1` converts the
already-rounded binary64 operand directly at `a`'s precision and generally
differs from `a + mp("0.1")`.

M07 matrix constructors preserve the same source distinction element by
element.  A real double matrix transfers each existing binary64 value
directly, while a text-cell matrix parses each decimal directly.  Each matrix
has one immutable precision, contiguous column-major MPFR storage, and normal
two-dimensional shape metadata.  M08 implements dense real `A * B` through
MPLAPACK MPFR `Rgemm`, and M09 implements square `A \ B` through `Rgesv`;
M15 extends full-rank rectangular `A \ B` through `Rgels`,
with result precision equal to the maximum operand precision and a temporary
current-thread precision scope. M16 upgrades rectangular `A \ B` to the
rank-revealing MPLAPACK MPFR `Rgelss` path for minimum-norm least-squares
solutions, while square systems remain on `Rgesv`. M10 adds read-only indexing, `double(A)`, and
canonical matrix display. M11 adds native MPFR matrix `+`, `-`, `.*`, and `./`,
unary signs, and two-dimensional singleton expansion. M12 adds read-only
transpose, conjugate transpose for real values, and column-major reshape;
these structural operations preserve source precision and do not consult the
ambient precision default. M17 adds dense real `chol` through MPLAPACK MPFR
`Rpotrf`, including selected-triangle semantics and optional status output,
while preserving immutable source values and stored precision. M18 adds
non-pivoted dense real `qr` through MPLAPACK MPFR `Rgeqrf` and `Rorgqr`;
one-output `qr(A)` returns `R` and two-output forms return `Q,R`. M19 adds
column-pivoted three-output `qr` through `Rgeqp3`, reusing `Rorgqr` for `Q`.
M21 adds dense real `lu` through `Rgetrf`; packed one-output factors,
permutation-aware two/three-output factors, and vector row pivots preserve the
stored operand precision. N00 adds `norm`; N01 adds `det` and `inv` through
stored-precision `Rgetrf`/`Rgetri` and `Cgetrf`/`Cgetri` paths.

## Current feature status

| Feature | Scalar | Dense matrix | Backend | Status |
|---|---:|---:|---|---|
| `+ - .* ./` | yes | yes | MPFR | supported |
| `*` | yes | yes | `Rgemm` | supported |
| `\` | yes | yes | `Rgesv`/`Rgelss` | supported |
| `/` | yes | yes | transpose solve; `Rgesv`/`Rgelss` | supported |
| `chol` | yes | yes | `Rpotrf` | supported |
| `qr` / pivoted `qr` | yes | yes | `Rgeqrf`/`Rgeqp3`/`Rorgqr` | supported |
| `lu` | yes | yes | `Rgetrf` | supported |
| structured `eig` | yes | yes | `Rsyevd`/`Cheevd` | supported |
| complex | yes | yes | `Cgemm`/`Cgesv`/`Cgelsy`/`Cpotrf`/`Cgeqrf`/`Cgeqp3`/`Cgetrf` | supported |
| T00–T14 advanced numerics | yes | yes | MPFR/MPC native bridges | supported/deferred by API |
| sparse | no | no | future | deferred |

## Release provenance

The published `mplapack-interop 0.5.0` source remains identified by tag
`v0.5.0`, freeze commit `7187a0f6c5a40a4d5774f4f913b166ccb6a5dffa`, and
archive SHA256
`3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04`.
The local 0.5.1 maintenance release uses the official MPLAPACK 3.0.1 archive
with gmpfrxx_mkII 1.5.0; its source archive identity and validation evidence
are recorded in
[`docs/dependency-release-stack-r2.md`](docs/dependency-release-stack-r2.md).
The archive and annotated tag are local only; GitHub, Debian, and PPA uploads
are deferred.

## Public API baseline

The following workflow is available in the current release line:

```octave
pkg load mplapack-interop

mpdigits(100);

A = mp({"1", "2"; "3", "4"});
b = mp({"1"; "2"});

C = A * A;
x = A \ b;
```

The completed baseline uses normal Octave matrix operations such as indexing,
`\`, and read-only conversion/display. Native backend entry points stay
private.

## Precision warning

These constructors intentionally have different input semantics:

```octave
mp("0.1")
mp(0.1)
```

The string form parses decimal text directly at the target MPFR precision.
The numeric form receives an already-rounded IEEE binary64 value and preserves
that exact value when converting to MPFR. Thus the two `0.1` values above are
intentionally different. See
[`docs/precision-semantics.md`](docs/precision-semantics.md).

## Historical 0.1.0 non-goals

- Wrapping every MPLAPACK routine
- Supporting every MPLAPACK backend
- Complex multiprecision arithmetic (implemented in the 0.2.x line)
- Replacing Octave BLAS/LAPACK
- Transparent conversion of all Octave code to multiprecision
- Complete MATLAB compatibility

## Development roadmap

```text
M00  Bootstrap
M01  Native build probe
M02  Native mp storage
M03  Public scalar constructor
M04  Precision
M05  Conversion/display
M06  Element-wise arithmetic
M07  Matrix storage
M08  Matrix multiplication
M09  Linear solve
M10  Dense matrix inspection
M11  Dense element-wise arithmetic
M12  Dense transpose and reshape
M13  Dense horizontal and vertical concatenation
M14  Dense indexed assignment with value semantics
M15  Full-rank rectangular dense solve
M16  Rank-deficient rectangular minimum-norm solve
M17  Dense real Cholesky factorization
M18  Dense real non-pivoted QR factorization
M19  Dense real pivoted QR factorization
M20  Complex architecture audit and design freeze (no public complex support)
M21  Dense real LU factorization
M22  Real v0.1 API and release closure
M23  v0.1.0 feature freeze and release candidate

D01R1  Rename package identity to mplapack-interop and freeze binary architecture

PPA1-PPA4  Debian/Ubuntu/PPA packaging and final release
```

M00 through M23, C00 through C12, S00 through S08, and T00 through T14 are
complete (M20 is design-only and the real-only M23 candidate remains
historical). No PPA upload exists. Consult
[`docs/milestones/README.md`](docs/milestones/README.md) for gate definitions
and status.
