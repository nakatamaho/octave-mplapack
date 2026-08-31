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

M02 establishes an internal scalar class derived from Octave 11.1's installed
`octave_base_dld_value` API. Its registered identity is
`mplapack_mpfr_scalar_internal`, not the future public `mp` class. The Octave
representation owns a project `MpfrScalarStorage`, which in turn owns the same
RAII `mpfrxx::mpfr_class` type used as MPLAPACK MPFR `REAL`. The pure storage
layer is independent of Octave headers.

The native scalar:

- uses deterministic RAII ownership;
- initializes and clears every MPFR value exactly once;
- copies and moves safely, with copy assignment preserving source precision;
- remains safe for Octave temporaries, assignments, and error paths;
- stores explicit per-object precision;
- is immutable at the Octave boundary and reports shape `1 x 1`; and
- uses neither a process-global object registry nor user-visible pointer
  handles.

Octave assignment may share an immutable representation. `clone()` and the M02
explicit clone diagnostic deep-copy value and precision. Future destructive
LAPACK operations must copy public inputs into operation-owned storage. The
matrix container, dimensions, and column-major layout remain M07 decisions;
the selected native scalar is safe in contiguous C++ containers.

Every representation's DLD-aware base retains an `octave::auto_shlib` reference
to the containing module, including the prototype stored by type registration.
The DLD function object is also locked when the internal type is initialized.
Ordinary clear cannot invalidate live values. Octave 11.1 package unload
removes the function name, but isolated lifecycle QA proves that a live value
retains usable type/vtable metadata and is destroyed safely; package reload
reasserts the lock without duplicate registration. Octave-specific subclass,
type-registration, checked-cast, and function-locking code remains localized
for future compatibility work.

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
private name `__mplapack_core__.oct`. Package tooling supplies `mkoctfile`, and
the build respects `MKOCTFILE` rather than hard-coding an executable. Explicit
`MPLAPACK_CFLAGS` and `MPLAPACK_LIBS` overrides are supported, while
`pkg-config` remains the default.

M01 proves that an Octave `.oct` module can link to and call the installed
MPLAPACK MPFR backend. The private `version` command calls
`Rlamch_mpfr("E")`; the public `mplapack_version()` wrapper only reports the
diagnostic result. The source package is generated explicitly and tested by
installation under an isolated Octave HOME. M01 does not choose a native `mp`
representation or implement arithmetic.

M02 proves that an immutable custom Octave scalar can own, copy, clone, and
destroy explicit-precision MPLAPACK MPFR storage safely. The private
`__mplapack_core__` test commands exercise lifecycle behavior only. The public
`mp()` constructor and all arithmetic remain unimplemented until later
milestones.
