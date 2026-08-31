# Native value design

## Purpose

M02 establishes an internal GNU Octave value that owns one MPLAPACK MPFR
scalar.  It is lifecycle infrastructure for later milestones, not the public
`mp` class.  No constructor, conversion, display, indexing, matrix, or
arithmetic API is provided here.

## Octave 11.1 API audit

The target API was inspected in the headers installed with GNU Octave 11.1.0
under `/usr/include/octave-11.1.0/octave`.  The extension include directory was
obtained from both `mkoctfile -p OCTINCLUDEDIR` and
`octave-config -p OCTINCLUDEDIR`; the reported API directory is `api-v61`.

The selected base class is `octave_base_dld_value`, the installed DLD-aware
subclass of `octave_base_value`.  It owns an `octave::auto_shlib` reference to
the containing dynamic library and schedules library release safely from its
destructor.  The internal value overrides `clone()`, `empty_clone()`, `dims()`,
`is_defined()`, and the minimum scalar introspection needed by M02.  Numeric
conversion and operator hooks are not overridden.

The installed `DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA` and
`DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA` macros provide a distinct type ID, type
name, class name, and registration function.  An instance is placed in an
`octave_value` with the public `octave_value(octave_base_value *)` constructor.
The checked recovery path first compares `octave_value::type_id()` with the
registered static ID and then uses `dynamic_cast` on
`octave_value::internal_rep()`.

`octave_value` owns the representation through Octave's built-in reference
count.  Normal assignment therefore shares an immutable representation, while
`clone()` constructs an independent representation and storage payload.

The dynamic function uses `DEFMETHOD_DLD` to receive an
`octave::interpreter&`.  Octave 11.1 exposes the executing function through
`tree_evaluator::current_function()`.  The implementation verifies that this
object is a DLD function and calls `octave_function::lock()` on that exact
object, avoiding a second name-based symbol-table lookup.  Type registration
is performed once before an internal value can be constructed, while the lock
is reasserted on each module entry after a package reload.

Installed headers used by the implementation are:

- `defun-dld.h`
- `interpreter.h`
- `auto-shlib.h`
- `oct-shlib.h`
- `ov.h`
- `ov-base.h`
- `ov-fcn.h`
- `ov-typeinfo.h`
- `pt-eval.h`

These are installed oct-file development headers, and no Octave source or
private header is copied into the package.  The important compatibility risk
is that the installed registration macro calls
`octave::__get_type_info__()`, whose header comment describes it as an internal
interface that remains available for user-defined `octave_value` objects.
Evaluator current-function lookup and direct function locking are also
compatibility-sensitive.  The subclass and registration code is therefore
isolated in `mp_value.*` and the bridge initialization code, targeting Octave
11.1 specifically.

## Selected native base class

The internal value derives from `octave_base_dld_value`.  It represents
exactly one scalar and reports dimensions `1 x 1`.  It does not derive from a
built-in numeric container and does not advertise implicit numeric
conversions.  The DLD-aware base is essential: every native representation
holds a reference to its containing shared library.

## Type registration

The registered type name is `mplapack_mpfr_scalar_internal`, deliberately not
`mp`.  Registration uses Octave's installed type-ID macros and is guarded by a
C++ `std::once_flag` so repeated calls cannot allocate new type identities.

## Scalar storage representation

MPLAPACK's installed `mplapack_mpfr.h` declares real routines in terms of
`mpfrxx::mpfr_class`, and `mplapack_arithmetic_params_mpfr.h` defines
`REAL` as the same type.  The project-owned scalar storage class therefore
contains one `mpfrxx::mpfr_class` constructed from decimal text at an explicit
MPFR precision.

The wrapper is kept free of Octave headers.  This lets ownership and container
behavior be tested independently under sanitizers and keeps the Octave ABI
boundary localized.

## RAII ownership

`mpfrxx::mpfr_class` initializes its `mpfr_t` with `mpfr_init2`, clears it in
its destructor, and uses an initialization guard on throwing constructors.
The project wrapper preserves those RAII guarantees.  It does not expose a
raw pointer or use an external object registry.

## Copy and clone semantics

Copy construction creates an independent MPFR value with the source object's
precision.  Project-level copy assignment uses copy-and-swap so it also adopts
the source precision; the underlying wrapper's ordinary assignment would
otherwise retain the destination precision.  Move construction and assignment
transfer ownership safely.  Octave `clone()` deep-copies the project storage.

## Immutability

Native payloads are immutable at the Octave boundary.  Assignment may safely
share Octave's representation, and operations in future milestones must
produce new values.  Destructive LAPACK calls must operate on operation-owned
input copies or result storage rather than mutate shared public values.

## Precision ownership

Every constructed M02 scalar receives an explicit precision in bits, validated
against `MPFR_PREC_MIN` and `MPFR_PREC_MAX`.  The effective precision is read
from the stored MPFR value.  M02 introduces no public or process-global default
precision.

## Module lifetime and locking

The type's vtable, destructor, clone implementation, and registered metadata
reside in `__mplapack_core__.oct`.  Unloading that module while values or the
type registry remain alive would be unsafe.  Each representation therefore
inherits `octave_base_dld_value`, whose `octave::auto_shlib` member retains the
containing DSO and whose destructor calls `delete_later()`.  The registration
prototype also uses this base and remains in Octave's type registry, so type
metadata cannot outlive the module.

Initialization additionally locks the executing DLD function object.  The
internal `module_test_locked` QA command reports that exact object's
`islocked()` state.  Ordinary `clear __mplapack_core__` leaves the DSO resident,
the value queryable, and destruction safe even if a name-based lookup no longer
shows the function lock.

Octave 11.1's name-based `mislocked("__mplapack_core__")` is true for the
direct source module but can return false after an architecture-specific
installed package function has been resolved more than once, even while the
executing DLD object's `islocked()` is true.  Installed-package QA therefore
uses the exact function-object state rather than treating the cache-sensitive
name lookup as authoritative.

Octave 11.1 `pkg unload mplapack` forcibly removes package function names and
the visible lock flag, but the DLD-aware native values and registration
prototype retain the module.  In an isolated subprocess with a native value
alive, the value retained its type identity, its virtual print method executed,
its destructor ran safely, and the process exited zero after package unload. A
subsequent `pkg load` resolves the same registered type and reasserts the
function lock.  Thus package unload removes access to the private command until
reload, but does not invalidate live registered values.  M02 never calls
`munlock`.

## Error handling

The bridge validates command arity, string arguments, integral precision, and
internal type identity before access.  Storage and clone exceptions are
translated to Octave errors at the extension boundary.  Failed parsing
initializes temporary native storage and remains RAII-safe.

## MPLAPACK type compatibility

The stored native scalar is the same `mpfrxx::mpfr_class` type accepted by the
MPLAPACK MPFR interface, so later numerical code will not require a scalar
format conversion.  M02 does not invoke arithmetic with stored values.

## Matrix-storage implications

The selected native type is moveable, copyable, and safe in contiguous C++
containers.  Its installed implementation asserts the same size and alignment
as `mpfr_t` for dense-array stride.  M07 still owns the matrix representation;
it will need column-major contiguous native scalar storage, leading dimensions,
and efficient MPLAPACK pointer access.  M02 does not choose or implement that
container.

## Octave compatibility boundary

Only the Octave-facing value and registration files depend on custom-value
APIs.  The pure scalar storage does not include Octave headers.  The type-ID
macros, `internal_rep()` checked access, `DEFMETHOD_DLD`, evaluator current-
function lookup, and function locking are the compatibility-sensitive APIs to
re-audit before supporting an Octave release other than 11.1.

## Known limitations

- The public `mp` constructor remains the M03 not-implemented stub.
- User-visible conversion and display are not implemented.
- Matrix storage, indexing, arithmetic, and operator registration are not
  implemented.
- `pkg unload` removes package function names until the package is loaded
  again; safe destruction of already-created native values is supported.
