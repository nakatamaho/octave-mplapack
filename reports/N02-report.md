# N02 RESULT

## Result

```text
N02 PASS — SVD COMPLETE
```

N02 adds dense arbitrary-precision real and complex `svd` to the
`mplapack-interop` 0.3.0-dev development line. The frozen D01R1 package
`mplapack-interop` 0.2.1 / `v0.2.1` remains unchanged.

## Source identity

```text
Repository: nakatamaho/octave-mplapack
Branch: topic/d01r1-mplapack-interop
Pre-N02 commit: 582e8a1377d90cf8e0e2c4798b5a9dbaef3c33d2
N02 implementation commit: recorded after commit
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

The tests selected the installed dependency prefix explicitly through
`PKG_CONFIG_PATH`, `LD_LIBRARY_PATH`, and `CMAKE_PREFIX_PATH`. No
source-worktree dependency path, stale prefix, or builtin binary64 complex
SVD participated.

## API and shapes

Supported forms are:

```octave
s = svd (A)
[U, S, V] = svd (A)
[U, S, V] = svd (A, "econ")
[U, S, V] = svd (A, 0)
```

One output is a real `mp` column with `min(m,n)` singular values. Full factors
have shapes `U=m-by-m`, `S=m-by-n`, and `V=n-by-n`. Economy factors have
shapes `U=m-by-k`, `S=k-by-k`, and `V=n-by-k`, with `k=min(m,n)`. The
numeric zero option is accepted as the deprecated economy form. Empty and
scalar shapes match the audited Octave behavior, including no invalid
zero-size LAPACK invocation.

For real input, factors use `Rgesvd`; for complex input, factors use `Cgesvd`.
`S` is a real `mp` matrix in both cases. Complex V is formed from LAPACK VT by
native MPC conjugate transpose. Full and economy reconstructions, real
orthogonality, and complex unitarity are checked without comparing unstable
singular-vector signs or phases.

## Precision and ownership contract

The operation precision is the stored input precision. Destructive input
buffers, U/VT factors, real singular values, complex work, real work, and
workspace are operation-owned and uniformly precisioned. Workspace query
values are checked for finite positive integer range, complex query values
must have zero imaginary part, and INFO is checked for invalid arguments and
non-convergence. Ambient precision is restored after the call and input
values remain unchanged.

No SVD path converts through binary64, invokes builtin Octave `svd`, or routes
real input through complex kernels.

## N02 gates

```text
G-N02-BACKEND:        PASS
G-N02-ONE-OUTPUT:     PASS
G-N02-FULL:           PASS
G-N02-ECON:           PASS
G-N02-REAL:           PASS
G-N02-COMPLEX:        PASS
G-N02-RECONSTRUCTION: PASS
G-N02-ORTHOGONALITY:  PASS
G-N02-WORKSPACE:      PASS
G-N02-PRECISION:      PASS
G-N02-REGRESSION:     PASS
```

## Regression wall

```text
tools/check-tree.sh: PASS
tools/check-format.sh: PASS
native MPFR/MPC SVD test with ASan/UBSan: PASS
public SVD test: PASS
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
mandatory C11L complex Cgetrf: PASS
1024-bit / 2^-700: PASS
2048-bit / 2^-1500: PASS
ambient precision and scope restoration: PASS
operation-owned input and lifetime checks: PASS
ASan: PASS
UBSan: PASS
LSan: PASS
clean source archive build: PASS
package install/load/smoke/help/examples/unload/uninstall/reinstall: PASS
deterministic source package contents: PASS
tools/local-ci.sh: PASS (exit code 0)
```

The integrated wall rebuilt the native module from the source package and
from a clean extracted archive, then ran the complete existing regression
suite plus N00, N01, and N02. No release tag or final 0.3.0 archive was
created.

## Release boundaries

No MPLAPACK tag or source was changed. No Debian package, binary artifact,
PPA/Launchpad upload, or Octave Packages registry change was made. The next
milestone is N03: `rank`, `cond`, and `rcond`.

## Conclusion

```text
N02 PASS — SVD COMPLETE
NEXT: N03 — rank / cond / rcond
```
