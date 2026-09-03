# Complex backend provenance

This file records the development dependencies used by the C00-C12 complex
implementation. These are tested development commits, not final release tags.

## Tested repositories

- `gmpfrxx_mkII`: `main` at
  `32a7fb797202cdf92312ed9d133f96fdbcda590a`;
- `mplapack`: `topic/octave-mplapack-complex-mpfr-scope` at
  `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`.

## Controlled installation

- prefix: `/home/docker/work/complex-prefix`;
- pkg-config identity: `mplapack_mpfr 3.0.1`;
- headers: `mplapack/mpblas_mpfr.h`, `mplapack/mplapack_mpfr.h`,
  `mplapack/mplapack_utils_mpfr.h`, and the installed
  `mplapack/mplapack_mpfr_precision.h`;
- link interface: `-lmplapack_mpfr -lmpc -lmpfr -lgmp`;
- runtime library: `libmplapack_mpfr.so.3` (installed file version
  `libmplapack_mpfr.so.3.0.1`).

The controlled C05 build uses MPFR support with the reference backend and
disables GMP, QD, DD, binary80, binary128, optimized, test, and benchmark
variants. MPLAPACK's public MPFR `Cgemm` declaration accepts `mpc_class`
arguments and is implemented by `mpblas/reference/Cgemm.cpp`.

The C06 square-solve audit confirms that the public MPFR declaration of
`Cgesv` uses `mpc_class` A/B arrays and `mplapackint *ipiv`; its controlled
source is `mplapack/reference/Cgesv.cpp`, which delegates to reference
`Cgetrf` and `Cgetrs`.

The C07 rank-revealing audit directly exercises the public MPFR declarations
and controlled reference sources for `Cgelsy`, `Cgelss`, and `Cgelsd`.
`Cgelsy` was selected for production because its QR-with-column-pivoting
contract supplies the required rank control and minimum-norm solve with
complex work plus `2*n` real workspace. `Cgelss` uses the real workspace in
its SVD path, while `Cgelsd` additionally requires larger real workspace and
`mplapackint` `iwork`. All workspace arrays are allocated at the operation
precision, and all integer arrays use the installed `mplapackint` type.

The C08 audit confirms that the installed `Cpotrf` declaration uses
`mpc_class` storage and `mplapackint` dimensions/status. The controlled
`mplapack/reference/Cpotrf.cpp` source uses selected-triangle Hermitian
semantics through reference `Cherk`, `Cgemm`, `Ctrsm`, and `Cpotrf2`. The
binding therefore does not precheck the ignored triangle, explicitly clears
the non-selected output triangle, and preserves the backend's real diagonal
behavior.

The C09 audit confirms that the installed `Cgeqrf` and `Cungqr` declarations
use `mpc_class` reflector and workspace arrays with `mplapackint` dimensions.
The controlled reference sources use blocked complex Householder helpers; the
binding performs precision-scoped workspace queries and invokes `Cungqr` only
for two-output calls.

The C10 audit confirms that the installed `Cgeqp3` declaration uses
`mpc_class` factor, reflector, and complex workspace arrays, an
`mplapackint*` `JPVT`, and MPFR real workspace. The controlled reference
source uses the complex pivoted Householder path. The binding initializes
`JPVT` to zero, validates the returned one-based permutation, maps it to the
public matrix/vector forms, and reuses the precision-scoped `Cungqr` path.

The C11L audit confirms that the installed `Cgetrf` declaration uses
`mpc_class` factor storage, `mplapackint` dimensions/status, and an
`mplapackint*` pivot array. The controlled reference implementation is
`mplapack/reference/Cgetrf.cpp`. The binding replays the destructive routine's
swap sequence into the public row permutation, constructs packed and
canonical factors at the source precision, and retains the real M21
two-output/matrix/vector conventions. No new upstream defect was exposed by
C11L.

The C11 structural audit confirms that mixed concatenation copies real and
complex operands directly into an MPC destination at the maximum stored MP
precision. Mixed numerical operations continue to select the existing real
or complex implementation from operand kind; no real-only operation is
rerouted through a complex kernel.

## Upstream fixes introduced during C00-C12

### MPLAPACK MPFR precision scope header

- Repository: `mplapack`;
- Problem: the public MPFR headers did not install the uniform-precision scope
  interface needed to establish one MPFR/MPC operation precision at complex
  LAPACK boundaries;
- Reproducer: a clean consumer build using `pkg-config mplapack_mpfr` failed
  the required installed-header check for `mplapack_mpfr_precision.h`;
- Topic branch: `topic/octave-mplapack-complex-mpfr-scope`;
- Fix commit: `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`;
- Tests: controlled shared MPFR installation, `check-deps`, native real and
  complex sanitizer walls, public M01–M23+C01–C11L wall, and package
  install/load/unload/reinstall smoke;
- First milestone requiring it: C00 complex precision scaffold.

No `gmpfrxx_mkII` fix was required through C12.

No final MPLAPACK 3.0.1 release commit, archive, or dependency tag is frozen
by this development goal.
