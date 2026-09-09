# DOC00 status

DOC00 closes the documentation gap before D04.  Work is on
`topic/t00-t14-continuation`, whose development version is `0.5.0-dev`.
The documentation implementation freeze commit is
`8f8bbdc0d75ccf4bc572ba843ad6b1ebf4ae0f75`.

| Gate | Result | Evidence |
|---|---|---|
| G-DOC00-API-INVENTORY | PASS | `docs/public-api-inventory.md`; 202 supported, 9 deferred, 3 internal entries |
| G-DOC00-USER-MANUAL | PASS | `doc/mplapack-interop.texi`, task-oriented 24-chapter manual |
| G-DOC00-PRECISION-CHAPTER | PASS | stored precision, `mpbits`, `p_op`, promotion, and graphics boundary documented |
| G-DOC00-PER-API-MP-NOTES | PASS | grouped user entries, inventory notes, API help, and backend map |
| G-DOC00-HELP-TEXT | PASS | all public `inst/@mp/*.m` and `inst/*.m` entries have help blocks; representative lookups pass |
| G-DOC00-DOXYGEN | PASS | `docs/doxygen/Doxyfile`, main page, native contracts, HTML generated |
| G-DOC00-BACKEND-MAP | PASS | `docs/backend-map.md` covers native entry, backend, copy, and precision rules |
| G-DOC00-EXAMPLES | PASS | 12 deterministic runnable examples under `examples/` |
| G-DOC00-EXAMPLE-CI | PASS | `tools/test-doc-examples.sh`; all examples and selected help lookups pass |
| G-DOC00-SERIALIZATION-DOC | PASS | manual, `docs/serialization.md`, and exact round-trip example |
| G-DOC00-GRAPHICS-DOC | PASS | manual, boundary documentation, and headless graphics example |
| G-DOC00-RNG-DOC | PASS | manual, `docs/rng.md`, and deterministic state example |
| G-DOC00-DEFERRED-DOC | PASS | indexed deferred list and links under `docs/todo/` |
| G-DOC00-README | PASS | README landing page links to manual, inventory, compatibility, examples, and developer docs |
| G-DOC00-NEWS | PASS | unreleased 0.5.0-dev user-facing section and D04 RC wording |
| G-DOC00-MANUAL-BUILD | PASS | `tools/build-docs.sh`; HTML, Info/plaintext, and Doxygen HTML generated |
| G-DOC00-CONSISTENCY | PASS | `tools/check-docs.sh` |
| G-DOC00-REGRESSION | PASS | `tools/local-ci.sh`, M/C/N/S/T wall, sanitizer wall, and package lifecycle |

## Verification log

- `tools/check-tree.sh`: PASS
- `tools/check-format.sh`: PASS
- `tools/check-docs.sh`: PASS
- `tools/test-doc-examples.sh`: PASS; examples 01--12, help lookups, Grcar,
  Hilbert SVD, serialization/RNG, interpolation, solvers, and graphics
- `tools/build-docs.sh`: PASS with `makeinfo` and Doxygen 1.15; Info/plaintext
  is the manual artifact because this host has no TeX engine
- `tools/local-ci.sh`: PASS with the installed MPLAPACK 3.0.1 MPFR interface;
  this re-ran M00--M23, C00--C12 including C11L, N00--N08, S00--S08,
  T00--T14, native ASan/UBSan/LSan, clean rebuild, archive checks, and the
  isolated package lifecycle
- DOC00 source package: PASS; two `SOURCE_DATE_EPOCH=0` builds had identical
  SHA256 `21f2bffd547246f24f0d884aa034157e55db7157e21e08c61bc760f1bee40154`.
  The archive contains documentation sources and examples, and excludes
  generated `docs/.build` output.

## Scope

No numerical or native implementation was changed for DOC00.  Changes are
documentation, Octave help text, runnable examples, documentation/build
tooling, and the source-package file-selection fix needed to ship the manual
while excluding generated output.

## Result

```text
DOC00 PASS — USER/DEVELOPER DOCUMENTATION CLOSED
D04-READY
```

D04 was not started automatically.
