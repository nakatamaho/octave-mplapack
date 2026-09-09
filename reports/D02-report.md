# D01R1 -> N00-N07 -> D02 RESULT

## Result

~~~
D02 PASS — mplapack-interop 0.3.0 source frozen
RELEASE STACK INPUT: frozen and reproducible
B01-READY: YES
~~~

D02 froze the first source package containing the D01R1 real/complex API
and the N00-N07 numerical closure. D02 made release metadata and
documentation changes only; it did not add numerical functionality. The
immutable package freeze is commit 392b72786f34d0bc1efcf35e2fd0cf0de58ec64f,
tag v0.3.0.

No Debian package, binary distribution, PPA, Launchpad upload, or package
registry submission was started. B01/D01 work is not started automatically.

## Historical checkpoint and C12 baseline

~~~
REAL_V0_1_RC_COMMIT: 0bef79cddd3fdd70abafdf38bc1a4ab492652d33
REAL_V0_1_ARCHIVE: historical D00 archive, retained by the D00 record
REAL_V0_1_SHA256: historical D00 archive, retained by the D00 record

COMPLEX_START_COMMIT: 4aed479ef9cb8dff24f0326e1c2ec2a7c1ed83a3
COMPLEX_FINAL_COMMIT: 36cd341a8c14ce2d0a6790b287e5f7a7b0846cd3
C12_RESULT: COMPLEX GOAL PASS / REAL-COMPLEX-API-CLOSED / DEPENDENCY-FREEZE-READY
~~~

The historical real-only checkpoint was not modified or replaced.

## Frozen package identity

~~~
Repository: nakatamaho/octave-mplapack
Package: mplapack-interop
Version: 0.3.0
Freeze commit: 392b72786f34d0bc1efcf35e2fd0cf0de58ec64f
Tag: v0.3.0
Tag target: 392b72786f34d0bc1efcf35e2fd0cf0de58ec64f
Archive: mplapack-interop-0.3.0.tar.gz
Archive size: 306282 bytes
SHA256 A: 1282f77f98bb7b137d1a8800d1d6d426ed06000595aebc03e5fa5ac48b3bdf98
SHA256 B: 1282f77f98bb7b137d1a8800d1d6d426ed06000595aebc03e5fa5ac48b3bdf98
Installed copy: /home/docker/src/mplapack-interop-0.3.0.tar.gz
~~~

v0.3.0 is an annotated tag. Its remote target was verified, and the
archive regenerated from the tagged tree has the same hash, size, top-level
directory, and file list as the pre-tag archive. The D01R1 predecessor
remains immutable provenance:

~~~
Version: 0.2.1
Commit: b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6
Tag: v0.2.1
Archive: mplapack-interop-0.2.1.tar.gz
SHA256: 28769e877e0588a59d9c0d6736fb875624df8b836f570cc9e87eda7d74936d0f
~~~

## Frozen dependency stack

| Layer | Repository | Version | Exact source commit | Tag | Archive | SHA256 | Size |
|---|---|---:|---|---|---|---|---:|
| gmpfrxx_mkII | nakatamaho/gmpfrxx_mkII | 1.4.1 | 32a7fb797202cdf92312ed9d133f96fdbcda590a | v1.4.1 | gmpfrxx_mkII.1.4.1.tar.xz | 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4 | 15176064 |
| MPLAPACK | nakatamaho/MPLAPACK | 3.0.1 | c21a9f56224308afda9e7424ca9928d4cf840f7a | external release/tag owner | mplapack-3.0.1.tar.xz | f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1 | 85807808 |
| mplapack-interop | nakatamaho/octave-mplapack | 0.3.0 | 392b72786f34d0bc1efcf35e2fd0cf0de58ec64f | v0.3.0 | mplapack-interop-0.3.0.tar.gz | 1282f77f98bb7b137d1a8800d1d6d426ed06000595aebc03e5fa5ac48b3bdf98 | 306282 |

The supplied MPLAPACK 3.0.1 archive is the QA candidate used for the stack;
MPLAPACK release/tag ownership remains external. No gmpfrxx or MPLAPACK tag
was created or modified by this work.

The dependency graph is:

~~~
mplapack-interop 0.3.0
    requires MPLAPACK 3.0.1 / mplapack_mpfr
        requires gmpfrxx_mkII 1.4.1
            requires GMP / MPFR / MPC
~~~

gmpfrxx_mkII is header-only in this release stack; its public C++ interface
uses MPFR/MPC and GMP/MPFR/MPC are the corresponding external build and
runtime dependencies. MPLAPACK's MPFR backend produces
libmplapack_mpfr.so.3. The final package extension directly requires
libmplapack_mpfr.so.3, libmpc.so.3, libmpfr.so.6, and libgmp.so.10, plus
the host C++/C runtime libraries. No optimized MPLAPACK backend was claimed
as validated.

## Milestone commits

~~~
D01R1 freeze: b19f679aa4864c991c11bd05a78b0e4b1cbe4cc6
N00 implementation: dbe320fa4ed7f1d5541991796ab2df20e2687ec2
N01 implementation: 91a034d2f1acdf739b7ec3b30cc5e333ee6de4f1
N02 implementation: 9f05418f3fc700914727e00b4321ee3ecd061dfe
N03 implementation: ab8ed68fb4e04c821bb50a0e08e578474ee1cfcd
N04 implementation: 455b5df72c65bb4475c6436429dae005910eb88f
N05 implementation: 61e8afa0c6af780f30948347f51c95b60d397d1a
N06 implementation: 9929b2360b717f7817005bccc9eb5fa193697aa2
N07 implementation: 473143f5bab22478f232c734b8c79049c65e33dc
D02 source freeze: 392b72786f34d0bc1efcf35e2fd0cf0de58ec64f
~~~

N00-N07 were each committed and pushed after the milestone gates and the
real-regression wall passed. D02's freeze commit changes only release
metadata and release-facing documentation from the N07 implementation.

## Numerical API closure

The frozen package contains the accepted real and complex arbitrary-precision
API through N07:

~~~
N00: norm for real/complex vectors and matrices
N01: det and inv, including real Rgetrf/Rgetri and complex Cgetrf/Cgetri
N02: svd, full/economy/numeric-0 forms, real and complex factors
N03: rank, cond, and rcond
N04: structured symmetric/Hermitian eig and generalized eig support
N05: general real/complex eig and Grcar QA
N06: dense generalized eig(A,B), real and complex
N07: public API and compatibility closure
~~~

Destructive LAPACK operations use operation-owned copies. Real inputs stay on
real MPLAPACK kernels, complex inputs stay on MPC/MPFR kernels, and no
builtin binary64 complex fallback is used. The one-operation/one-precision
MPFR/MPC contract, public mp value semantics, ambient precision behavior, and
scope restoration were retained throughout.

## Regression and precision evidence

~~~
tools/check-tree.sh: PASS
tools/check-format.sh: PASS
native unit and dispatch checks: PASS
M00-M23 real regression: PASS
C00-C12 complex regression: PASS
C11L complex Cgetrf: PASS
N00-N07 numerical/API regression: PASS
real/complex scalar, matrix, mixed, and structured canaries: PASS
real rank, Cholesky, QR pivot, and LU pivot canaries: PASS
complex scalar, Cgemm, Cgesv, Cgelsy rank, Cpotrf, QR,
  Cgeqp3 pivot, and Cgetrf pivot canaries: PASS
1024-bit / 2^-700: PASS
2048-bit / 2^-1500: PASS
low/high ambient precision: PASS
scope restoration and operation-owned copies: PASS
native lifetime tests: PASS
compatibility firewall: PASS
~~~

The N00-N07 walls were run against the installed D01R1 dependency prefixes,
with the package archive later extracted and retested independently. The
MPLAPACK MPFR precision-scope interface remained present and was exercised
through the installed public header.

## Grcar and eig QA

Grcar matrices are generated in arbitrary precision in the package layer; the
accepted QA covers the documented Grcar size/parameter forms, real and complex
general eig paths, and dense generalized eig paths. The backend map is:

~~~
real general eig: Rgeevx
complex general eig: Cgeevx
real generalized eig: Rggev
complex generalized eig: Cggev
real symmetric generalized eig: Rsygvd
complex Hermitian generalized eig: Chegvd
~~~

Unsupported or ambiguous forms are rejected explicitly. No real-only operation
was routed through a complex kernel.

## SVD, rank, and condition QA

~~~
real SVD: Rgesvd
complex SVD: Cgesvd
real matrix 2-norm: Rgesvd singular-values-only helper
complex matrix 2-norm: Cgesvd singular-values-only helper
rank: singular-value thresholding from Rgesvd/Cgesvd
cond/rcond: real and complex LAPACK condition estimators
~~~

Full/economy shapes, reconstruction, orthogonality/unitarity, singular
values, scalar/empty cases, precision preservation, and input immutability
passed. Complex singular values remain real arbitrary-precision mp values.

## Sanitizer and runtime closure

~~~
ASan: PASS
UBSan: PASS
LSan: PASS
~~~

The extracted package extension was audited with readelf -d, ldd, and ldd -r.
libmplapack_mpfr.so.3, MPFR, MPC, and GMP dependencies were resolved. The
only undefined symbols accepted by the package extension are Octave host
symbols resolved by the loaded Octave executable; there were no missing
non-host relocations. N01/N02/N03/N05/N06 symbols, including Cgetrf, Cgetri,
Cgesvd, Cgecon, Cgeevx, Cggev, Rgeevx, Rggev, Rsygvd, and Chegvd, were
present in the final closure audit.

## Package lifecycle and examples

From a clean extraction of mplapack-interop-0.3.0.tar.gz in an isolated
HOME/package database:

~~~
install: PASS
pkg load mplapack: PASS
real smoke: PASS
complex smoke: PASS
help and examples: PASS
pkg unload: PASS
uninstall: PASS
reinstall: PASS
second real/complex smoke: PASS
~~~

The complete test script also exercised determinant/inverse, SVD, rank,
condition estimates, structured/general/generalized eig, Grcar, and the
required C11L complex LU path.

## Full frozen-stack rebuild

The final D02 gate uses only the following three source archives, normal
compiler/Octave prerequisites, and the documented GMP/MPFR/MPC runtime
prerequisites:

~~~
gmpfrxx archive only: PASS — clean CMake build/install; 192 CTest tests passed
MPLAPACK archive only: PASS — clean configure/build/install; version 3.0.1
octave-mplapack archive only: PASS — clean extraction and full QA
Git worktree dependency: NONE
Unfrozen header dependency: NONE
Stale development prefix: NONE
~~~

The provenance-selected paths for the installed-prefix regression were:

~~~
include: /home/docker/opt/octave-mplapack-stack/include
MPLAPACK include: /home/docker/opt/octave-mplapack-stack/include/mplapack
pkg-config: /home/docker/opt/octave-mplapack-stack/lib/pkgconfig
runtime: /home/docker/opt/octave-mplapack-stack/lib
~~~

The independent three-archive rebuild was run in a temporary prefix and
excluded the source worktrees. Its gmpfrxx CTest stage passed all 192 tests;
the MPLAPACK and package stages then passed their version/header/runtime and
full regression checks.

## Source and license provenance

~~~
gmpfrxx_mkII: LICENSE, BSD 2-Clause
MPLAPACK: COPYING, BSD-style MPLAPACK/LAPACK/BLAS terms recorded upstream
octave-mplapack: COPYING/LICENSE, BSD 2-Clause
GMP: COPYING terms, dual GPL-2.0-or-later / LGPL-3.0-or-later source terms
MPFR: LGPL-3.0-or-later
MPC: LGPL-3.0-or-later
~~~

This report records source/license facts only; binary redistribution legal
analysis belongs to the later binary-distribution work.

## Upstream changes required by the complex implementation and release QA

No gmpfrxx_mkII source change was required during C00-C12, D00, D01R1, or
N00-N07. The gmpfrxx freeze remains the already tested 1.4.1 source.

The MPLAPACK history used by the candidate includes the following required
precision, archive, and platform fixes:

~~~
a59e5a0a429b05e8f07cf7a8feab1f48aef7431d  MPFR precision-scope implementation
e6e1bcbf9513e9de47cb6c70afbd791e30868aae  integrate scope support on master
3b340e7bc4eb08052580b9669e2fe1f3b16b4b3a  scope contract regression tests
98fa308ac5dcbb31fe5876b21b3eb7d8c52c8ae0  portable macOS /bin/sh pkg-config generation
20f2f414df106ba09200560ebb4a18ac62c29fb5  macOS QD/DD shared-library load checks
76cbb400aed5e8be7e9f2cfa02f27a95a5e564e4  Automake macOS QD load probe
c21a9f56224308afda9e7424ca9928d4cf840f7a  external gmpfrxx include flags in MPFR pkg-config
85b581ea0c9183cdbaf44d34eb48d7cc8eb3dcb2  align bundled gmpfrxx with 1.4.1
3786c35a825ae3927b8621bed380e14877d17912  include generated gmpfrxx Makefile.in in release archive
fa3ccb4376d2a52c2672322e5b7199a9224bed7f  export external gmpfrxx headers in MPFR pkg-config
f4e5818135dada8c6ef0a7f11954c53f11f4202a  reproducible source archive tooling
~~~

The exact full MPLAPACK source identity used by D00/D01R1 is the supplied
3.0.1 archive at commit c21a9f56224308afda9e7424ca9928d4cf840f7a; the archive
hash in the frozen-stack table is authoritative. The N00-N07 source changes
are the milestone commits listed above. D02 itself contains no numerical
implementation change.

## Release-stack manifest and handoff

The canonical handoff files are:

~~~
docs/dependency-release-stack-r1.md
docs/binary-distribution.md
docs/goals/N00-N07-D02-status.md
reports/D02-report.md
~~~

They record the three versions, commits, tags, archive names, hashes, sizes,
dependency order, runtime SONAME, include/pkg-config/runtime paths, test
platform, and license facts needed by future binary-distribution work.

## Gates

~~~
G-D02-SOURCE-FREEZE:      PASS
G-D02-VERSION:            PASS
G-D02-REPRODUCIBLE:       PASS
G-D02-REGRESSION:         PASS
G-D02-PACKAGE-LIFECYCLE: PASS
G-D02-RUNTIME-CLOSURE:    PASS
G-D02-DOCS:               PASS
G-D02-TAG:                PASS
G-D02-BINARY-HANDOFF:     PASS
~~~

## Known limitations

The MPLAPACK tag/release publication is maintained by its upstream release
owner; this work consumes the exact supplied QA archive and does not create or
modify the MPLAPACK tag. Optimized MPLAPACK complex backends were not claimed
as validated. The package still requires the host Octave ABI and the normal
GMP/MPFR/MPC runtime prerequisites. These are release-stack facts, not
unresolved D02 blockers.

## Next milestone

~~~
D02 PASS — RELEASE SOURCE FROZEN
B01-READY
~~~

The next milestone is B01/D01 binary-distribution architecture, but it is not
started automatically. It must consume exactly the frozen package source
archive and the dependency identities recorded above. Any later source-level
defect requires reopening the appropriate freeze rather than silently editing
the frozen tree.
