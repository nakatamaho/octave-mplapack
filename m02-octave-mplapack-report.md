# M02 RESULT

Repository:
nakatamaho/octave-mplapack

Remote:
https://github.com/nakatamaho/octave-mplapack.git

Branch:
topic/m02-native-value

Starting commit:
`3e17fbbcb8edcf10c34d3870da59a8682b3c30f9`

Final commit:
`3b7d4ba8361b9ba614378615c143508253357975`

PR:
[#3 — M02: add native MPFR scalar value storage](https://github.com/nakatamaho/octave-mplapack/pull/3)

M01 integration:
- M01 PR: #2
- M01 final commit: `ccab9a2f8d5d9fe39500fae627ba1a8fde8da9bd`
- main integration commit: `3e17fbbcb8edcf10c34d3870da59a8682b3c30f9`

Environment:
- Octave: 11.1.0
- Octave API version: `api-v61`
- mkoctfile: 11.1.0
- C++ compiler: GCC 15.2.0
- MPLAPACK: 3.0.1
- MPFR: 4.2.2

Octave native-value API audit:
- Base class: `octave_base_dld_value`
- Required virtual methods: `clone`, `empty_clone`, `dims`, defined/scalar introspection, and minimal internal printing
- Type registration mechanism: `DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA` / `DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA`, guarded by `std::once_flag`
- Checked cast mechanism: registered `type_id` check followed by `dynamic_cast` on `internal_rep()`
- Clone mechanism: independent copy construction of the native representation and MPFR payload
- Module locking mechanism: exact executing DLD function `lock()` plus `octave_base_dld_value`/`auto_shlib` lifetime retention
- Installed headers used: `ov-base.h`, `ov.h`, `ov-typeinfo.h`, `ov-fcn.h`, `pt-eval.h`, `interpreter.h`, `auto-shlib.h`, `oct-shlib.h`, `defun-dld.h`
- Compatibility notes: targets Octave 11.1; type registration and evaluator/function-lock APIs are isolated compatibility boundaries

Native storage:
- Project storage class: `octave_mplapack::MpfrScalarStorage`
- Underlying scalar type: `mpfrxx::mpfr_class`
- Why selected: it is MPLAPACK MPFR’s actual `REAL` type and provides explicit precision, RAII, copy/move support, and dense-array-compatible layout
- RAII: PASS
- Copy: deep copy; copy-and-swap assignment adopts source precision
- Move: no-throw move construction and assignment
- Precision query: `mpfr_class::precision()`
- MPLAPACK compatibility: exact native type match; compile-time assertions PASS

Native Octave value:
- Internal type name: `mplapack_mpfr_scalar_internal`
- Public type exposed: no public API or INDEX entry
- Shape: `1 x 1`
- Mutable: no; immutable at the Octave boundary
- Clone: deep copy preserving value, precision, and type
- Type registration: Octave type-ID macros
- Registration idempotence: PASS across 500 repeated constructions

Module lifetime:
- Risk identified: vtable, destructor, clone, and type metadata reside in the DSO
- Protection mechanism: `octave_base_dld_value` retains the DSO through `auto_shlib`; the DLD function is also explicitly locked
- mislocked/equivalent evidence: exact DLD `islocked()` exposed through private `module_test_locked` returned true
- clear test: PASS for `clear __mplapack_core__`
- live-value survival: type identity and virtual printing worked before re-entering the module; subsequent inspection and destruction passed
- interpreter shutdown: PASS with live source and installed-package values
- pkg unload behavior: function names are removed, but live values retain valid DSO code; type inspection, printing, destruction, reload, and relock PASS

Precision:
- 128-bit: PASS
- 256-bit: PASS
- 512-bit: PASS
- simultaneous precision independence: PASS
- copy precision preservation: 128-bit clone remained 128-bit after original destruction

Lifecycle QA:
- construct/destroy: PASS
- assignment: PASS
- explicit clone: PASS
- cell storage: PASS
- temporary flow: PASS
- wrong-type handling: PASS for double, string, cell, and struct inputs
- error-path cleanup: PASS for invalid text and invalid precision
- repeated initialization: PASS

Standalone sanitizer QA:
- Test executable: `src/.build-m02/mp_scalar_storage_test` — removed after QA
- ASan: PASS
- UBSan: PASS
- Leak check: PASS with `detect_leaks=1`
- stress iterations: 10,000
- contiguous-container test: PASS with `std::vector<MpfrScalarStorage>`
- result: PASS

MPLAPACK compatibility:
- Scalar type compatibility: exact `mpfrxx::mpfr_class` match
- conversion required later: no scalar-format conversion
- result: PASS

M01 regression:
- mplapack_version: PASS
- Rlamch probe: PASS, `7.4583e-155`
- linkage: direct `libmplapack_mpfr.so.3` dependency; no missing non-host dependencies
- negative dependency: PASS
- result: PASS

Package QA:
- source archive: `dist/mplapack-0.1.0-dev.tar.gz`
- isolated install: PASS
- installed __mplapack_core__: temporary package `x86_64-pc-linux-gnu-api-v61` directory
- source-tree shadowing: absent
- installed native-value tests: PASS
- public mp() still M03 stub: PASS
- result: PASS

QA:
- check-tree: PASS
- check-format: PASS
- local-ci: PASS
- clean rebuild #1: PASS
- clean rebuild #2: PASS
- git diff --check: PASS
- generated-artifact cleanup: PASS; ignored `dist/` archive retained
- git status: clean
- GitHub push: PASS
- remote SHA: `3b7d4ba8361b9ba614378615c143508253357975`
- GitHub CI: PASS for push and PR structural checks

Files changed:
24 files covering native storage/value implementation, bridge and Makefile, lifecycle/sanitizer/package QA, architecture and milestone documentation, repository policy, and the requested M01 report.

Gate:
G02 PASS

Architectural decisions established:
- Native values derive from Octave’s DLD-aware base and retain their containing module.
- Native payloads are immutable and use RAII ownership.
- Precision is explicit and belongs to each object.
- Octave assignment may share immutable representations; clone performs a deep copy.
- No pointer handles or global object registry are used.
- Future destructive LAPACK calls must use operation-owned copies.
- Matrix representation remains an M07 decision.

Known limitations:
- public mp constructor is not implemented
- matrix storage is not implemented
- arithmetic is not implemented
- default precision API is not implemented
- user-visible conversion and display are not implemented
- GitHub CI remains structural; native QA is authoritative in the configured Octave/MPLAPACK environment

Next milestone:
M03 — Constructors and dimensions

```text
Branch:
topic/m02-native-value
Starting commit:
3e17fbbcb8edcf10c34d3870da59a8682b3c30f9
Final commit:
3b7d4ba8361b9ba614378615c143508253357975
Files changed:
24 files
Commands run:
M01 integration audit; Octave/MPLAPACK API audit; clean builds; sanitizer build; linkage inspection; direct and installed Octave lifecycle probes; source-package install/uninstall/reinstall; diff/security audits; commit; push; PR and CI verification.
Tests:
check-tree PASS; check-format PASS; local-ci PASS; ASan/UBSan/LSan PASS; native-value lifecycle PASS; module clear/unload/shutdown PASS; two clean rebuilds PASS; isolated package QA PASS; M01 regression PASS; GitHub structural CI PASS.
Gate:
G02 PASS
Known limitations:
Public mp(), matrices, arithmetic, conversion/display, and default precision APIs remain unimplemented. M03 has not started.
```
