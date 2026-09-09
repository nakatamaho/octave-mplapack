# N00 RESULT

## Result

N00 PASS — NORM API AND BACKEND COMPLETE

Development line: `mplapack-interop` 0.3.0-dev

## Source and dependencies

```text
Repository: nakatamaho/octave-mplapack
Branch: topic/d01r1-mplapack-interop
Pre-N00 source: 9384236f6c7f360e86e8a3616e1c0bdb36873b57
Historical frozen package: b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6
Historical tag: v0.2.1

gmpfrxx_mkII: 1.4.1
gmpfrxx commit: 32a7fb797202cdf92312ed9d133f96fdbcda590a
gmpfrxx archive SHA256: 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4

MPLAPACK: 3.0.1
MPLAPACK commit: c21a9f56224308afda9e7424ca9928d4cf840f7a
MPLAPACK archive SHA256: f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1
MPLAPACK runtime: libmplapack_mpfr.so.3
```

## N00 API

Implemented `norm` for the `mp` class in `inst/@mp/norm.m` and native
`src/mp_norm.cc`. Supported forms are:

```text
vector: default/2, 1, 2, Inf, -Inf, 0, Fro, positive finite p
matrix: 1, 2, Inf, Fro
```

The implementation uses the MPFR/MPC backend throughout. Standard real
matrix norms use Rlange, standard complex matrix norms use Clange, vector
2-norms use Rnrm2/RCnrm2, and matrix 2-norms use singular-values-only
Rgesvd/Cgesvd helpers. Destructive LAPACK operations receive operation-owned
copies. No builtin binary64 complex fallback and no routing of real-only
operations through complex kernels was introduced.

Unsupported matrix p forms and invalid options have explicit diagnostics.
Special values and empty/scalar behavior are tested. The singular-value
helpers are kept available for the later SVD milestone.

## Gate results

```text
G-N00-API: PASS
G-N00-REAL: PASS
G-N00-COMPLEX: PASS
G-N00-MATRIX: PASS
G-N00-VECTOR: PASS
G-N00-2NORM: PASS
G-N00-PRECISION: PASS
G-N00-SPECIAL: PASS
G-N00-REGRESSION: PASS
```

## Required test wall

```text
tree and format checks: PASS
native norm test: PASS
public norm test: PASS
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
mandatory C11L Cgetrf: PASS
1024-bit / 2^-700: PASS
2048-bit / 2^-1500: PASS
ambient precision and scope restoration: PASS
special values and invalid requests: PASS
native lifetime/shutdown: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
package lifecycle: PASS
clean archive extraction/rebuild/retest: PASS
full tools/local-ci.sh exit code: 0
```

The wall was run from `/tmp/d01r1-octave-src` with the D01R1 installed
dependency prefix selected explicitly through `PKG_CONFIG_PATH`,
`LD_LIBRARY_PATH`, and `CMAKE_PREFIX_PATH`. The resulting full CI log ended
with `PASS: D00 local CI` and exit code 0.

## Files added or changed

```text
inst/@mp/norm.m
src/mp_norm.h
src/mp_norm.cc
test/mp_norm_test.cc
test/norm.tst
docs/norm.md
docs/milestones/N00-norm.md
```

The package metadata, test runner, compatibility documentation, release
firewall, tree checks, and local CI were updated for the 0.3.0-dev line and
the new supported operation. The D01R1 0.2.1 tag and release archive were not
modified.

## Known limitations and next milestone

N00 deliberately does not implement det/inv, svd, rank/cond/rcond, eig,
generalized eig, or final closure. These are N01-N07 scope. The known
unrelated text-cell complex-constructor issue was not changed by N00.

No binary artifacts, Debian packages, PPA/Launchpad uploads, Octave Packages
registry changes, or final 0.3.0 release tags were created.

## Conclusion

```text
N00 PASS — NORM API AND BACKEND COMPLETE
NEXT: N01 — det/inv
```
