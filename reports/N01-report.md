# N01 RESULT

## Result

```text
N01 PASS — DETERMINANT AND INVERSE COMPLETE
```

N01 adds dense arbitrary-precision `det` and `inv` for real and complex
`mp` values on the development line `mplapack-interop` 0.3.0-dev. The
frozen D01R1 package `mplapack-interop` 0.2.1 / `v0.2.1` was not modified.

## Source identity

```text
Repository: nakatamaho/octave-mplapack
Branch: topic/d01r1-mplapack-interop
Pre-N01 commit: dbe320fa4ed7f1d5541991796ab2df20e2687ec2
N01 implementation commit: recorded after commit
N01 report/status commit: recorded after commit
Development version: 0.3.0-dev
Frozen predecessor commit: b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6
Frozen predecessor tag: v0.2.1
```

## Frozen dependency stack used for validation

```text
gmpfrxx_mkII: 1.4.1
gmpfrxx commit: 32a7fb797202cdf92312ed9d133f96fdbcda590a
gmpfrxx archive SHA256: 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4

MPLAPACK: 3.0.1
MPLAPACK source commit: c21a9f56224308afda9e7424ca9928d4cf840f7a
MPLAPACK archive SHA256: f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1
MPLAPACK runtime: libmplapack_mpfr.so.3
```

All N01 native and Octave tests selected the installed frozen dependency
prefix explicitly. No source-worktree header, library, stale development
prefix, or builtin binary64 complex implementation participated.

## Implementation

Real determinant uses MPLAPACK `Rgetrf`, row-pivot parity, and the product of
the diagonal of U. Complex determinant uses `Cgetrf` with the corresponding
MPC/MPFR precision scope and arithmetic. Singular determinants return exact
MPFR/MPC zero; the empty determinant is one and nonsquare inputs are
rejected.

Real inverse uses `Rgetrf`, a checked `Rgetri` workspace query, and `Rgetri`.
Complex inverse uses `Cgetrf`, a checked `Cgetri` workspace query, and
`Cgetri`. Query results, INFO values, workspace sizes, and precision
contracts are validated explicitly. Singular inverse requests produce the
package `mplapack:mp:SingularMatrix` diagnostic.

The operation owns the destructive LAPACK copies. Existing real operations
remain on real kernels, complex operations remain on complex kernels, and no
binary64 fallback was introduced. N01 implements the one-output determinant
form; the optional reciprocal-condition output remains deliberately deferred
to N03 condition-number support.

## Public API and diagnostics

```text
det(A)       real and complex dense mp matrices
inv(A)       real and complex dense mp matrices
```

The wrappers enforce the current one-output contract, preserve stored operand
precision, preserve input values, and handle scalar and empty matrices.
Non-square, singular, invalid, and excessive-output cases have explicit
package behavior covered by public tests.

## N01 gates

```text
G-N01-DET:          PASS
G-N01-DET-PIVOT:    PASS
G-N01-INV:          PASS
G-N01-WORKSPACE:    PASS
G-N01-SINGULAR:     PASS
G-N01-PRECISION:    PASS
G-N01-IMMUTABILITY: PASS
G-N01-REAL-COMPLEX: PASS
G-N01-REGRESSION:   PASS
```

## Regression wall

```text
tree check: PASS
format check: PASS
native determinant/inverse test: PASS
public determinant/inverse test: PASS
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
mandatory C11L complex Cgetrf: PASS
1024-bit / 2^-700 canary: PASS
2048-bit / 2^-1500 canary: PASS
low/high ambient precision and scope restoration: PASS
input immutability and operation lifetime: PASS
singular and non-square diagnostics: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
clean source-archive extraction build: PASS
package install/load/smoke/help/examples/unload/uninstall/reinstall: PASS
clean rebuild and retest: PASS
tools/local-ci.sh: PASS (exit code 0)
```

The full N01 wall was run with `SOURCE_DATE_EPOCH=0` and the D01R1 installed
gmpfrxx/MPLAPACK prefix selected through `PKG_CONFIG_PATH`,
`LD_LIBRARY_PATH`, and `CMAKE_PREFIX_PATH`.

## Files and release boundaries

N01 adds the determinant/inverse native implementation, public wrappers,
native and public tests, API documentation, milestone documentation, and the
corresponding tree/CI/firewall updates. The development source archive was
rebuilt and tested as `mplapack-interop-0.3.0-dev`.

No final 0.3.0 tag or archive was created. No MPLAPACK tag was changed. No
Debian package, binary distribution, PPA/Launchpad upload, or Octave Packages
registry change was made.

## Conclusion

```text
N01 PASS — DETERMINANT AND INVERSE COMPLETE
NEXT: N02 — svd
```
