# M04 RESULT

Repository:
nakatamaho/octave-mplapack

Remote:
https://github.com/nakatamaho/octave-mplapack.git

Branch:
topic/m04-precision-api

Starting commit:
0a60ed85f60cc77c8aac7d4bf4f1cfa102fe892d

Final commit:
ea4fee9caba3b7a442e1cca8383cd839adfac9be

PR:
[#5 — M04: add public precision controls](https://github.com/nakatamaho/octave-mplapack/pull/5)

M03 integration:
- M03 PR: #4
- M03 final commit: `90a8385066b28e1f05aed3b03eb1c4c753f8f6fe`
- M03 merge commit: `0a60ed85f60cc77c8aac7d4bf4f1cfa102fe892d`

Precision architecture:
- Canonical unit: bits
- Initial default: 512 bits, updated per user request
- Source of truth: one native `std::atomic<mpfr_prec_t>` in `mp_precision`
- State lifetime: current Octave process/session
- Thread/process model: process-local, atomically accessed, not thread-local
- Uses MPFR global default: no; `gmpfrxx_mkII` retains its separate one-time TLS initialization behavior
- Guard bits: 0

mpbits:
- Getter: returns current default as `uint64`
- Setter: updates precision for subsequent objects only
- Setter return: resulting current bit precision
- Minimum accepted: 1 bit
- Maximum accepted: `MPFR_PREC_MAX` = 9223372036854775551 bits through exact Octave integer input
- Invalid-input behavior: clean package-specific error; state unchanged

mpdigits:
- Getter definition: `floor(bits * log10(2))` complete guaranteed digits
- Setter definition: selects `ceil(digits * log2(10))` bits
- Decimal-to-bit implementation: directed MPFR lower/upper bounds with certified integer agreement
- Bit-to-decimal implementation: directed MPFR lower/upper bounds with certified integer agreement
- Overflow handling: detected before state commit
- Setter return: resulting guaranteed decimal-digit count

Conversion examples:
- 1 digit: 4 bits
- 10 digits: 34 bits
- 38 digits: 127 bits
- 100 digits: 333 bits
- 1000 digits: 3322 bits
- 128 bits -> digits: 38
- 332 bits -> digits: 99
- 333 bits -> digits: 100

Per-object precision:
- 128-bit object: PASS
- 256-bit object: PASS
- 512-bit object: PASS
- Existing object after default change: unchanged and not re-rounded
- Copy after default change: source precision preserved
- mpdigits(100) object: 333 bits

State behavior:
- set before first object: PASS
- clear: state preserved
- pkg unload/reload: state preserved; tested at 256 bits
- fresh-process reset: 512 bits
- persistence to disk: none

Validation:
- zero: rejected
- negative: rejected
- fractional: rejected
- NaN: rejected
- Inf: rejected
- complex: rejected
- vector: rejected
- matrix: rejected
- overflow: rejected, including the first value above the maximum valid decimal request
- rollback after failure: PASS

M03 semantic regression:
- mp("0.1") vs mp(0.1): different at 128, 256, and 512 bits
- mp("0.125") vs mp(0.125): equal at 128, 256, and 512 bits
- signed zero: PASS
- Inf/NaN: PASS

M02 regression:
- lifecycle: PASS
- module lifetime: PASS
- sanitizer: ASan/UBSan/LSan PASS

M01 regression:
- mplapack_version: PASS; MPLAPACK 3.0.1, MPFR 4.2.2
- Rlamch: PASS
- linkage: direct MPLAPACK MPFR dependency; no missing or non-Octave unresolved dependency
- negative dependency: expected clean failure PASS

Package QA:
- source archive: `dist/mplapack-0.1.0-dev.tar.gz`
- isolated install: PASS
- source-tree shadowing: absent
- installed mpbits: PASS; fresh default 512
- installed mpdigits: PASS; `mpdigits(100)` selects 333 bits
- uninstall/reinstall: PASS
- result: PASS

QA:
- check-tree: PASS
- check-format: PASS
- local-ci: PASS
- clean rebuild #1: PASS
- clean rebuild #2: PASS
- git diff --check: PASS
- generated artifacts: source-tree artifacts removed; ignored archive retained
- git status: clean
- GitHub push: PASS
- remote SHA: matches `ea4fee9caba3b7a442e1cca8383cd839adfac9be`
- GitHub CI: push and PR structural checks PASS

Files changed:
24 files covering the native precision state and certified conversions, public wrappers, BIST/sanitizer/lifecycle/package QA, documentation, roadmap metadata, and the requested `m04-octave-mplapack-report.md`.

Gate:
G04 PASS

Known limitations:
- public char/double conversion is not implemented
- final display formatting is not implemented
- arithmetic is not implemented
- dense matrices are not implemented
- the MPLAPACK scalar wrapper performs its own one-time MPFR TLS initialization, but this is not the project precision source

Next milestone:
M05 — Conversion and display

```text
Branch:
topic/m04-precision-api
Starting commit:
0a60ed85f60cc77c8aac7d4bf4f1cfa102fe892d
Final commit:
ea4fee9caba3b7a442e1cca8383cd839adfac9be
Files changed:
24 files
Commands run:
M03 integration audit; environment/API inspection; native builds; precision boundary probes; linkage inspection; sanitizer QA; source and installed lifecycle tests; package build/install/uninstall/reinstall; diff/security audits; commit; push; PR and CI verification.
Tests:
check-tree PASS; check-format PASS; local-ci PASS; ASan/UBSan/LSan PASS; precision conversion and rollback PASS; clear/unload/fresh-process lifecycle PASS; two clean rebuilds PASS; isolated package QA PASS; M01/M02/M03 regressions PASS; GitHub structural CI PASS.
Gate:
G04 PASS
Known limitations:
Public conversion/display, arithmetic, and dense matrices remain unimplemented. M05 has not started.
```
