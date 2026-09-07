# N00-N07-D02 status

Status: **N00 PASS — arbitrary-precision real and complex norm complete**

The D01R1 frozen package identity remains unchanged. The development line is
now `mplapack-interop` 0.3.0-dev, and N00 is the first numerical/API
milestone on that line. N01-N07 and D02 remain pending.

## N00 identity

```text
Repository: nakatamaho/octave-mplapack
Branch: topic/d01r1-mplapack-interop
Current source before N00 commit: 9384236f6c7f360e86e8a3616e1c0bdb36873b57
Development version: 0.3.0-dev
Frozen predecessor: mplapack-interop 0.2.1 / v0.2.1
Historical predecessor commit: b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6
```

## Dependency identity used by the gates

```text
gmpfrxx_mkII: 1.4.1 / 32a7fb797202cdf92312ed9d133f96fdbcda590a
gmpfrxx SHA256: 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4
MPLAPACK: 3.0.1 / c21a9f56224308afda9e7424ca9928d4cf840f7a
MPLAPACK archive SHA256: f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1
MPLAPACK runtime: libmplapack_mpfr.so.3
```

The implementation was built and tested against the installed prefixes
derived from these archives. No source-worktree include or library path was
used by the N00 gates.

## N00 implementation

The public `@mp/norm` wrapper and native `norm` dispatch support real and
complex vectors and matrices with the accepted Octave forms:

```text
vectors: default/2, 1, 2, Inf, -Inf, 0, Fro, and positive finite p
matrices: 1, 2, Inf, and Fro
```

Real standard matrix paths use MPLAPACK Rlange and Rnrm2; complex standard
matrix paths use Clange and RCnrm2. Matrix 2-norms use singular-values-only
Rgesvd/Cgesvd helpers. Inputs are copied before destructive LAPACK calls.
MPFR/MPC precision scopes are operation-owned and no builtin binary64 complex
fallback is used.

Unsupported matrix p forms and invalid requests are rejected explicitly.
Special values, empty values, scalar values, precision preservation, and
ambient-precision behavior are covered by the native and public tests.

## Gates

```text
G-N00-API:        PASS — @mp/norm and native dispatch are present and documented
G-N00-REAL:       PASS — real vector/matrix norms use the MPFR backend
G-N00-COMPLEX:    PASS — complex vector/matrix norms use the MPC/MPFR backend
G-N00-MATRIX:     PASS — supported matrix norms and explicit deferrals behave correctly
G-N00-VECTOR:     PASS — vector p forms, finite p, and special values pass
G-N00-2NORM:      PASS — Rgesvd/Cgesvd and Rnrm2/RCnrm2 paths pass
G-N00-PRECISION:  PASS — 512-bit, 1024-bit, 2048-bit, and ambient precision pass
G-N00-SPECIAL:    PASS — empty, Inf, NaN, zero, and invalid-request tests pass
G-N00-REGRESSION: PASS — complete local CI and required regression wall pass
```

## Regression evidence

```text
tools/check-tree.sh: PASS
tools/check-format.sh: PASS
native make -C src check-norm: PASS
public norm smoke and invalid-request probes: PASS
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex Cgetrf: PASS
1024-bit / 2^-700 canary: PASS
2048-bit / 2^-1500 canary: PASS
low/high ambient precision and scope restoration: PASS
operation-owned input and native lifetime tests: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
clean archive extraction build: PASS
package install/load/smoke/help/examples/unload/uninstall/reinstall: PASS
clean rebuild and retest: PASS
full tools/local-ci.sh: PASS (exit code 0)
```

The full N00 wall used `SOURCE_DATE_EPOCH=0` and explicitly selected the
installed D01R1 gmpfrxx/MPLAPACK prefix. The development package archive was
tested as `mplapack-interop-0.3.0-dev`; no release tag or 0.3.0 archive was
created by N00.

## Scope and deferrals

N00 adds only `norm`. `det`, `inv`, `svd`, `rank`, `cond`, `rcond`, symmetric
and general eigenvalue routines, generalized eigenvalue routines, and final
closure remain assigned to N01-N07. No Debian, PPA, Launchpad, registry, or
binary-distribution work was started.

## Result

```text
N00 PASS — NORM API AND BACKEND COMPLETE
NEXT: N01 — det/inv
```
