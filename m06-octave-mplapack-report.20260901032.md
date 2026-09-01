# M05 RESULT

Repository:
nakatamaho/octave-mplapack

Remote:
https://github.com/nakatamaho/octave-mplapack.git

Branch:
topic/m05-conversion-display

Starting commit:
f37f35b0562bc3a6a98629d63f9e7cade1d76ac3

Final commit:
8bdd3b2b5c4764c2945cbdcf0c089fc92f66c7f4

PR:
[#6 — M05: add scalar conversion and display](https://github.com/nakatamaho/octave-mplapack/pull/6)

M04 integration:
- M04 PR: #5
- M04 final commit: `ea4fee9caba3b7a442e1cca8383cd839adfac9be`
- M04 merge commit: `f37f35b0562bc3a6a98629d63f9e7cade1d76ac3`

Environment:
- Octave: 11.1.0
- MPLAPACK: 3.0.1
- MPFR: 4.2.2
- C++ compiler: GCC 15.2.0

Canonical text design:
- Native formatting API: `mpfr_get_str(base=10, n=0, MPFR_RNDN)` using MPFR’s certified precision-derived digit count ([MPFR 4.2.2 manual](https://www.mpfr.org/mpfr-4.2.2/mpfr.html#Conversion-Functions-1))
- Output grammar: `[-]d[.digits]e[+|-]exponent`
- Round-trip guarantee: exact native reconstruction at the source object’s precision
- Shortest decimal: not guaranteed
- Object precision used: yes
- Locale dependent: no; `ja_JP.utf8` QA passed
- Decimal point: `.`
- Exponent style: lower-case `e`, explicit sign, no unnecessary leading zeroes
- Buffer ownership: RAII wrapper with `mpfr_free_str`; size arithmetic checked

Special textual values:
- +0: `0`
- -0: `-0`
- +Inf: `Inf`
- -Inf: `-Inf`
- NaN: `NaN`

char(mp):
- Return type: character row vector
- 128-bit round-trip: PASS
- 256-bit round-trip: PASS
- 333-bit round-trip: PASS
- 512-bit round-trip: PASS
- 1024-bit round-trip: PASS
- Default-change independence: PASS
- Payload leakage: absent

double(mp):
- Native conversion API: `mpfr_get_d`
- Rounding mode: `MPFR_RNDN`, ties-to-even
- Decimal intermediate: none
- binary64-origin bit round-trip: PASS
- +0: bit-preserving PASS
- -0: bit-preserving PASS
- DBL_MIN: bit-exact PASS
- DBL_MAX: bit-exact PASS
- smallest subnormal: bit-exact PASS
- +Inf: PASS
- -Inf: PASS
- NaN: PASS
- overflow: signed infinity PASS
- underflow: signed zero PASS
- tie-to-even: exact `1 + 2^-53` midpoint rounded to `1.0`, PASS

disp(mp):
- Representation: canonical `char(x)` plus one newline
- Converts through double: no
- format short: PASS
- format long: PASS; identical output
- bare-object display: canonical value shown
- payload leakage: absent
- default-change independence: PASS

Precision regression:
- Fresh-process default: 512 bits
- mpbits: PASS
- mpdigits: PASS
- existing-object precision: unchanged
- package unload/reload: state preserved
- fresh-process reset: 512 bits

M03 regression:
- mp("0.1") vs mp(0.1): remain distinct
- mp("0.125") vs mp(0.125): remain equal
- signed zero: PASS
- Inf/NaN: PASS
- matrix firewall: PASS

Implicit-conversion firewall:
- mp + mp: unsupported
- mp + double: unsupported
- double + mp: unsupported
- mp * mp: unsupported
- representative generic functions: `sin`, `exp`, and `sqrt` fail without binary64 fallback
- result: PASS

M02 regression:
- native lifecycle: PASS
- module lifetime: PASS
- sanitizer: PASS

M01 regression:
- mplapack_version: PASS
- Rlamch: PASS
- linkage: direct `libmplapack_mpfr.so.3` dependency
- negative dependency: expected clean failure PASS

Sanitizer QA:
- canonical formatting: PASS
- temporary MPFR string ownership: PASS
- double conversion: PASS
- stress iterations: 10,000 plus 8192-bit smoke test
- ASan: PASS
- UBSan: PASS
- LSan: PASS

Package QA:
- source archive: `dist/mplapack-0.1.0-dev.tar.gz`
- isolated install: PASS
- source-tree shadowing: absent
- installed char: PASS; path under isolated HOME
- installed double: PASS; path under isolated HOME
- installed disp: PASS; path under isolated HOME
- unload/shutdown: PASS
- uninstall/reinstall: PASS
- result: PASS

QA:
- check-tree: PASS
- check-format: PASS
- local-ci: PASS
- clean rebuild #1: PASS
- clean rebuild #2: PASS
- ldd -r: no missing or non-Octave unresolved dependencies; expected Octave host symbols resolve inside Octave
- git diff --check: PASS
- generated artifacts: absent from commit
- git status: clean
- GitHub push: PASS
- remote SHA: `8bdd3b2b5c4764c2945cbdcf0c089fc92f66c7f4`
- GitHub CI: push and PR structural checks PASS

Files changed:
25 files covering native scalar conversion, public `char`/`double`/`disp`, BIST and sanitizer QA, installed-package lifecycle QA, documentation, roadmap status, repository invariants, and the requested timestamped M04 report.

Gate:
G05 PASS

Known limitations:
- arithmetic is not implemented
- dense matrices are not implemented
- matrix conversion/display is not implemented
- complex multiprecision is not implemented
- canonical text is source-precision round-trip text, not precision-independent exact serialization

Next milestone:
M06 — Element-wise arithmetic

```text
Branch:
topic/m05-conversion-display
Starting commit:
f37f35b0562bc3a6a98629d63f9e7cade1d76ac3
Final commit:
8bdd3b2b5c4764c2945cbdcf0c089fc92f66c7f4
Files changed:
25 files
Commands run:
M04 integration audit; MPFR API audit; native builds; linkage inspection; sanitizer QA; direct and installed conversion/display tests; locale and stress tests; package install/unload/uninstall/reinstall; diff and security audits; commit; push; PR creation; GitHub CI verification.
Tests:
check-tree PASS; check-format PASS; local-ci PASS; ASan/UBSan/LSan PASS; 128/256/333/512/1024-bit round-trip PASS; binary64 bit-pattern and ties-to-even PASS; display and implicit-conversion firewalls PASS; two clean rebuilds PASS; isolated package QA PASS; M01-M04 regressions PASS; GitHub structural CI PASS.
Gate:
G05 PASS
Known limitations:
Arithmetic, dense matrices, matrix conversion/display, and complex multiprecision remain unimplemented. M06 has not started.
```
