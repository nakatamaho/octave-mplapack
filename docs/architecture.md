# Architecture contract

## Layering

The intended implementation has the following layers:

```text
GNU Octave user code
        |
        v
@mp and public helper functions
        |
        v
private native .oct interface
        |
        v
native multiprecision value/matrix representation
        |
        v
MPLAPACK MPFR BLAS/LAPACK routines
```

The public API follows ordinary Octave numeric syntax. Backend routine names
such as `Rgemm` and `Rgesv` are implementation details, not the primary public
interface. Ordinary `.m` code must not handle native storage details, raw
pointers, or integerized pointer handles.

Octave's normal `double` matrix implementation remains untouched. Octave's
system BLAS and LAPACK also remain untouched. `mp` values are separate numeric
objects whose MPLAPACK operations work directly on native MPFR-backed storage;
the project will not use `LD_PRELOAD` or silently route through binary64.

Through M10 the only backend is real MPFR arithmetic. Complex arithmetic and
MPC-valued matrices are future extensions. GMP, DD, QD, binary80, and
binary128 backends are outside this baseline.

## Native representation and ownership

M00 deliberately does not fix a native representation or inheritance
hierarchy. Before M02 chooses custom-value mechanics, it must inspect the
installed Octave 11.x headers, the Octave 11.1 extension APIs, examples shipped
with that installed version, and its supported custom-value mechanisms. It
must not rely on obsolete tutorials. If Octave 8 support is later required,
compatibility logic must be isolated instead of scattering version conditionals
through numerical code.

The eventual native representation must:

- use deterministic RAII ownership;
- initialize and clear every MPFR value correctly;
- copy safely and move safely when moves are used;
- remain safe for Octave temporaries, assignments, and error paths;
- avoid leaks and double-free defects;
- preserve explicit precision metadata;
- represent matrix dimensions explicitly;
- distinguish scalar metadata from matrix storage where appropriate; and
- avoid process-global raw-pointer registries and user-visible integer handles.

## Dependency and build boundary

MPLAPACK is an installed, separate dependency and is never vendored or modified
by this project. Discovery defaults to:

```sh
pkg-config --modversion mplapack_mpfr
pkg-config --cflags mplapack_mpfr
pkg-config --libs mplapack_mpfr
```

The initial baseline requires MPLAPACK 3.0.0 or newer unless later evidence
establishes a better boundary. M01 must record which installation is used and
prove that no MPLAPACK source or build tree is required.

The native bridge will use Octave's normal external-module mechanism and the
provisional private name `__mplapack_core__.oct`. Package tooling supplies
`mkoctfile`, and the build must respect `MKOCTFILE` rather than hard-coding an
executable. Explicit `MPLAPACK_CFLAGS` and `MPLAPACK_LIBS` overrides may be
supported later, but `pkg-config` remains the default. M00 introduces no CMake
project and no native build implementation.
