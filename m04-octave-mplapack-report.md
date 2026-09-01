# M03 RESULT

Repository:
nakatamaho/octave-mplapack

Remote:
https://github.com/nakatamaho/octave-mplapack.git

Branch:
topic/m03-scalar-constructors

Starting commit:
d374a215aa1cbfc7585785a2f4ac685acc0413a4

Final commit:
90a8385066b28e1f05aed3b03eb1c4c753f8f6fe

PR:
[#4 — M03: add public scalar mp constructors](https://github.com/nakatamaho/octave-mplapack/pull/4)

M02 integration:
- M02 PR: #3
- M02 final commit: 3b7d4ba8361b9ba614378615c143508253357975
- M02 merge commit: d374a215aa1cbfc7585785a2f4ac685acc0413a4

Public class design:
- Mechanism: Octave 11.1 classdef value class in `inst/@mp/mp.m`
- Why selected: private/hidden properties, value semantics, future operator dispatch, and explicit concatenation rejection
- Public class: `mp`
- Internal payload: `mplapack_mpfr_scalar_internal`
- Encapsulation: private hidden `payload_`; checked native extraction only
- Octave 11.1 compatibility notes: uses installed api-v61 classdef APIs; compatibility-sensitive code is localized in the native bridge

Default precision:
- Internal default: 128 bits
- Source of truth: `src/mp_precision.h` and `src/mp_precision.cc`
- Public configurable: no; M04 owns that API
- Per-object explicit precision: PASS

String constructor:
- Input route: classdef → native bridge → `MpfrScalarStorage` → base-10 `mpfr_set_str`
- Intermediate double: none
- 0.1 result: direct 128-bit decimal parse PASS
- 0.125 result: exact dyadic value PASS
- malformed input: empty, malformed, and comma-decimal text rejected cleanly

Double constructor:
- Input route: classdef → native bridge → `MpfrScalarStorage` → `mpfr_set_d`
- Decimal formatting intermediate: none
- 0.1 result: exact incoming binary64 value preserved
- signed zero: positive and negative zero signs preserved
- finite extremes: DBL_MIN, DBL_MAX, smallest subnormal, and `1 + eps` PASS
- Inf: positive and negative infinity preserved
- NaN: preserved
- Rounding: explicit `MPFR_RNDN`; independent of mutable MPFR default rounding

Semantic comparison:
- mp("0.1") vs mp(0.1): different, PASS
- mp("0.125") vs mp(0.125): equal, PASS

Public scalar behavior:
- class: `mp`
- size: `[1 1]`
- rows: 1
- columns: 1
- numel: 1
- copy: PASS
- mp(existing_mp): safe immutable representation sharing, PASS
- cell storage: PASS
- struct storage: PASS
- function pass-through: PASS

Unsupported inputs:
- complex: rejected
- numeric vector: rejected
- numeric matrix: rejected
- cell array: rejected
- text array: rejected
- empty input: rejected

Matrix firewall:
- mp([1,2]): rejected
- mp({"1","2"}): rejected
- horizontal concatenation: rejected
- vertical concatenation: rejected
- dense matrix representation introduced: no
- result: PASS

Precision-loss firewall:
- double conversion: remains the M05 not-implemented operation
- char conversion: remains the M05 not-implemented operation
- arithmetic fallback: all tested operators fail without binary64 fallback
- result: PASS

Lifecycle regression:
- clear: PASS with public values alive
- pkg unload: live object survived unload/reload; destruction while unloaded PASS
- interpreter shutdown: source and installed public objects PASS
- result: PASS

Sanitizer QA:
- M02 storage regression: PASS
- double constructor path: PASS, including signed zero and special values
- ASan: PASS
- UBSan: PASS
- LSan: PASS with `detect_leaks=1`

M01 regression:
- mplapack_version: PASS, MPLAPACK 3.0.1
- linkage: direct `libmplapack_mpfr.so.3` dependency; no missing required libraries
- Rlamch: PASS, probe value `7.4583e-155`
- negative dependency: expected clean failure PASS

Package QA:
- source archive: `dist/mplapack-0.1.0-dev.tar.gz`
- isolated install: PASS
- source-tree shadowing: absent
- public constructor installed: PASS
- uninstall/reinstall: PASS
- result: PASS

QA:
- check-tree: PASS
- check-format: PASS
- local-ci: PASS
- clean rebuild #1: PASS
- clean rebuild #2: PASS
- git diff --check: PASS
- generated artifacts: absent from commit
- git status: clean
- GitHub push: PASS
- remote SHA: 90a8385066b28e1f05aed3b03eb1c4c753f8f6fe
- GitHub CI: push and PR structural checks PASS

Roadmap correction:
- matrix constructors moved to:
  M07
- reason:
  M02 established matrix representation as an M07 decision

Files changed:
35 files covering the public classdef wrapper, native text/double construction, precision configuration, lifecycle and sanitizer QA, package CI, roadmap/design documentation, and the requested M02 report.

Gate:
G03 PASS

Known limitations:
- public precision control is not implemented
- user-visible conversion/display is not implemented beyond the temporary `mp scalar` placeholder
- arithmetic is not implemented
- dense matrices are not implemented
- GitHub CI remains structural; native QA is authoritative in the configured Octave/MPLAPACK environment

Next milestone:
M04 — Precision API

```text
Branch:
topic/m03-scalar-constructors
Starting commit:
d374a215aa1cbfc7585785a2f4ac685acc0413a4
Final commit:
90a8385066b28e1f05aed3b03eb1c4c753f8f6fe
Files changed:
35 files
Commands run:
M02 integration; Octave classdef/API audit; native builds; sanitizer tests; linkage inspection; direct and installed constructor/lifecycle probes; source-package install/uninstall/reinstall; diff/security audits; commit; push; PR and CI verification.
Tests:
check-tree PASS; check-format PASS; local-ci PASS; ASan/UBSan/LSan PASS; constructor semantics PASS; matrix firewall PASS; clear/unload/shutdown PASS; two clean rebuilds PASS; isolated package QA PASS; M01/M02 regressions PASS; GitHub structural CI PASS.
Gate:
G03 PASS
Known limitations:
Public precision control, numeric conversion/display, arithmetic, and dense matrices remain unimplemented. M04 has not started.
```
