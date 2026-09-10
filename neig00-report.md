# NEIG00 report

Task and milestone: NEIG — difficult nonsymmetric eigensystems; NEIG00 repository and installed-API audit.

Branch: `main`

Starting commit: `ea3c94787a9315f99773d8bc926a3c0bebe6b0e1`

Validated implementation commit or uncommitted state: no implementation changes; the audit was run against the clean `main` tree at the starting commit.  This report is the milestone record.

Files created/modified:

- `neig00-report.md`

Environment and executable/module resolution:

- Repository: `/tmp/t00-t14` (`main`), clean before the report was added.
- Octave: GNU Octave 11.1.0, `/usr/bin/octave`.
- Installed package executable: `/home/docker/opt/octave-mplapack-stack/bin/octave-mplapack`.
- Installed package name/version: `mplapack-interop` 0.5.0-dev.
- Loaded `mp`: `/home/docker/opt/octave-mplapack-stack/octave-packages/mplapack-interop-0.5.0-dev/@mp/mp.m`.
- Loaded native module: `/home/docker/opt/octave-mplapack-stack/octave-arch/mplapack-interop-0.5.0-dev/x86_64-pc-linux-gnu-api-v61/__mplapack_core__.oct`.
- `mplapack_version()` reported backend `mpfr` and MPLAPACK `3.0.1`.
- Source-tree builds used `tools/dev-octave.sh` with `PKG_CONFIG_PATH`, `CPATH`, and `LD_LIBRARY_PATH` set to `/home/docker/opt/octave-mplapack-stack`; no dependency or header was modified.

Commands run:

```text
/home/docker/opt/octave-mplapack-stack/bin/octave-mplapack --no-gui --quiet --no-init-file --eval '<installed API audit>'
PKG_CONFIG_PATH=/home/docker/opt/octave-mplapack-stack/lib/pkgconfig \
LD_LIBRARY_PATH=/home/docker/opt/octave-mplapack-stack/lib \
CPATH=/home/docker/opt/octave-mplapack-stack/include \
tools/dev-octave.sh --eval 'test precision/eig_structured/eig_general/eig_generalized'
```

Tests and numerical results:

- `mpbits()` getter/setter and restoration: PASS.  Fresh installed process default was 512 bits; setting 1024 bits was observable and the audit restored 512 bits.
- Existing-object precision: PASS.  A 256-bit object retained 256 bits after the default changed to 1024 bits; a new object used 1024 bits.
- Real general eig with three outputs and both balance modes: PASS.  The real rotation matrix returned complex eigenvalues and satisfied both `A*V=V*D` and `W'*A=D*W'`.
- Complex-pair left/right convention: PASS; both residuals were reported as exact zero for the 2-by-2 audit fixture at the displayed precision.
- Exact real symmetric and complex Hermitian dispatch: PASS.  The audit exercised real/complex structured eig and public MP `sqrt`/`acos`/`sin`/`cos` availability.
- MP norm, condition number, and SVD: PASS.  A 2-by-2 dense MP SVD and `cond` completed at 128 bits.
- Public complex construction and finite-value inspection: PASS for the existing installed interface.
- Candidate public widening operation `X + mp(zeros(size(X)))`: PASS in the audit.  It widened a represented scalar from 256 to 1024 bits while the existing value remained unchanged and equal under the existing native test facility.  It will be validated again in the focused NEIG helper tests.
- Existing focused `precision.tst`, `eig_structured.tst`, `eig_general.tst`, and `eig_generalized.tst`: PASS.
- Installed package emitted expected warnings for functions that intentionally shadow Octave core functions; these were not failures and were not changed by NEIG00.

Gate: PASS

Known limitations:

- The source checkout selected for this task is the clean `/tmp/t00-t14` `main` worktree at the 0.5.0-dev API level.  The user-owned `/home/docker/work/octave-mplapack` checkout remains on a dirty C12 branch and was not switched or modified.
- The audit did not add a precision-inspection public API; existing test-only native inspection was used only as audit evidence.
- No NEIG numerical suite implementation was included in NEIG00.

Next milestone or minimal blocker reproducer: proceed to NEIG01.

