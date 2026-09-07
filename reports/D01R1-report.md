# D01R1 RESULT

## Result

D01R1 IN PROGRESS — the public package rename and architecture audit are
underway. The final `0.2.1` source identity, complete regression wall, final
dependency reconciliation, reproducible release archive, and `v0.2.1` tag are
not yet frozen.

Release identity conclusion: NOT-FROZEN

Binary distribution conclusion: ARCHITECTURE DEFINED; B01-READY PENDING FINAL
SOURCE/DEPENDENCY FREEZE

## Historical D00 package identity

```text
Repository: nakatamaho/octave-mplapack
Old package Name: mplapack
Old version: 0.2.0
Old freeze commit: 4a3eb50843a6bf365bdab1e82146ef1900a219f6
Old tag: v0.2.0
Old archive: mplapack-0.2.0.tar.gz
Old SHA256: 0e83e26182b0fbd95a064437a97307eb74d9291b49d91c6e53dac181b24a94db
Old tag unchanged: YES (not modified by D01R1)
```

## Dependency candidates

### gmpfrxx_mkII

```text
Version: 1.4.1
Commit: 32a7fb797202cdf92312ed9d133f96fdbcda590a
Tag: v1.4.1
Archive: gmpfrxx_mkII.1.4.1.tar.xz
SHA256: 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4
Changed during D01R1: NO
```

### MPLAPACK

```text
Version: 3.0.1
D00 candidate: fa3ccb4376d2a52c2672322e5b7199a9224bed7f
D00 candidate SHA256: 7c8d1d7759a487bc01e8c1625599ec77b6c7e297c19b20ca45e8c342f5165e64
Current QA candidate before pkg-config fix: 76cbb400aed5e8be7e9f2cfa02f27a95a5e564e4
Current QA archive before pkg-config fix: mplapack-3.0.1.tar.xz
Current QA archive SHA256 before pkg-config fix: 0739d73de62e9918874d80fe4d119cc60605f3772036455b65b9f24eb52f7e0f
Current source after pkg-config fix: c21a9f56224308afda9e7424ca9928d4cf840f7a
Supplied corrected RC archive: mplapack-3.0.1.tar.xz
Supplied corrected RC archive SHA256: f969c5039a3147f9ea412b051993c62e83854ceebf8515947ac9887bd8852ad1
Supplied corrected RC archive size: 85807808 bytes
Supplied corrected RC archive audit: Makefile.am, public precision header, and generated Makefile.in fixed
Current final archive: pending separate MPLAPACK release-QA regeneration
Runtime SONAME: libmplapack_mpfr.so.3
Changed during D01R1: release-blocking pkg-config include-path fix was pushed by this repository's prior handoff; final QA is maintained separately
```

The pre-fix QA candidate includes the user-supplied macOS fixes `98fa308ac`,
`20f2f414d`, and `76cbb400a`. Commit `c21a9f562` adds the release-blocking
external-gmpfrxx include path to the MPFR pkg-config outputs. The supplied
`f969c503...` archive contains the corrected `Makefile.am` and generated
`Makefile.in`, and both were verified with the public precision header against
the source commit. The previous `0739d73...` archive predates the source fix.
The corrected archive remains a candidate until the separate MPLAPACK release
QA accepts it and creates the release tag.

## Package-name preflight

```text
Octave: GNU Octave 11.1.0
Temporary package: isolated /tmp/d01r1-name-preflight fixture
Name: mplapack-interop
Install: PASS
pkg list: PASS, name displayed with hyphen
pkg describe: PASS
pkg load: PASS
pkg unload: PASS
pkg uninstall: PASS
Hyphen supported: YES
Result: G-D01R1-NAME-SYNTAX PASS
```

## New package identity (development state)

```text
Repository: nakatamaho/octave-mplapack
Package Name: mplapack-interop
Version before: 0.2.0
Version after: 0.2.1-dev (temporary)
Freeze commit: pending
Tag: pending
Tag target: pending
Archive: mplapack-interop-0.2.1-dev.tar.gz (development archive)
Archive size: 247665 bytes (development archive; not the final release archive)
SHA256 A: f3403336da0f5320f98bb0ecade7400fe604889e73109c92e4fdce2ea0abf804
SHA256 B: f3403336da0f5320f98bb0ecade7400fe604889e73109c92e4fdce2ea0abf804
Hashes identical: YES (development archive only)
Top-level directory: mplapack-interop-0.2.1-dev
pkg list identity: verified in installed development archive
pkg describe identity: verified
pkg load identity: verified
Result: development rename PASS; final identity pending
```

The final archive section is updated only from the final `0.2.1` source tree.

## Example QA

The Octave example `examples/05_hilbert_inverse.m` was installed and loaded
under the renamed package identity. It computed `H \ I` at 1024 bits and
reported `binary64 residual infinity norm: 1.185e-302`. The explicit
`double` conversion is used only for the final diagnostic. The example now
restores the caller's ambient `mpbits` value with `unwind_protect`.

The external MPLAPACK public-header consumer boundary is maintained and
validated by the separate MPLAPACK release QA. Its C++ source is intentionally
not shipped in this Octave package.

The current QA-stack `tools/local-ci.sh` wall completed successfully after
that restoration fix: M00–M23, C00–C12, mandatory C11L, lifecycle tests,
clean rebuild/retest, and ASan/UBSan-enabled native tests all passed. This is
not yet a final frozen-stack result because MPLAPACK release QA and the final
candidate/archive are maintained separately by the release maintainer.

## Octave binary package audit

```text
pkg build: PASS (design probe)
Binary archive: mplapack-interop-0.2.1-dev-x86_64-pc-linux-gnu-api-v61.tar.gz
Internal Name: mplapack-interop
Architecture-dependent directory: encoded in archive basename/API key
.oct location: src/__mplapack_core__.oct
Raw probe issue: pkg build includes source-tree QA output if left behind
Final policy: clean extraction plus package-local runtime and release cleanup
Production B01 artifact: NOT BUILT
Result: architecture probe recorded; relocation proof pending B01
```

## ABI compatibility key

```text
Octave version: 11.1.0
Octave API version: api-v61
OS/architecture: Linux x86_64 (x86_64-pc-linux-gnu)
Compiler/toolchain: GNU C++ 15.2.0
Required key: Octave major/minor + API + OS + architecture
Result: PASS for audit host; target matrix recorded for B01-B05
```

## Runtime dependency closure

```text
MPLAPACK runtime: libmplapack_mpfr.so.3
MPC: libmpc.so.3
MPFR: libmpfr.so.6
GMP: libgmp.so.10
C/C++ runtimes: libstdc++.so.6, libgcc_s.so.1, libc.so.6
Octave libraries: host Octave loader/runtime, not bundled
Other: any gmpfrxx provider is an explicit manifest item if required
Result: audited with readelf/ldd; final package-local closure belongs to B01-B05
```

## Binary runtime layout

```text
Common layout: package files + src/__mplapack_core__.oct + runtime/ + manifest
Package-local runtime directory: runtime/
.oct location: src/__mplapack_core__.oct
Manifest location: docs/binary-manifest.json (or package-preserved equivalent)
```

| Target | Loader strategy | Environment variable required |
|---|---|---|
| B01/B02 Linux | `$ORIGIN`/`DT_RUNPATH`; `readelf`, `ldd -r` | none |
| B03/B04 macOS | `@loader_path`/`@rpath`; `otool -L` | none |
| B05 Windows | package-local DLL directory; `objdump -p`/`ntldd` | none |

The current development module has no relative runpath and therefore used an
isolated library path for the design probe. That is not a final binary claim.

## Licensing

See [`docs/binary-redistribution-licenses.md`](../docs/binary-redistribution-licenses.md).
The inventory records BSD 2-Clause for this project and gmpfrxx, MPLAPACK's
2-clause BSD-style terms plus LAPACK/BLAS notices, GMP's dual GPL-2+/LGPL-3+
terms, MPFR/MPC LGPL-3+ terms, and future toolchain/runtime review items.

## Binary artifact naming

```text
Source: mplapack-interop-0.2.1.tar.gz
B01: mplapack-interop-0.2.1-octave11-linux-x86_64.tar.gz
B02: mplapack-interop-0.2.1-octave11-linux-aarch64.tar.gz
B03: mplapack-interop-0.2.1-octave11-macos-arm64.tar.gz
B04: mplapack-interop-0.2.1-octave11-macos-x86_64.tar.gz
B05: mplapack-interop-0.2.1-octave11-windows-x86_64.tar.gz
```

## F00 and PPA handoff

```text
Octave Packages name: mplapack-interop
Repository: https://github.com/nakatamaho/octave-mplapack
Index work started: NO
Recommended Debian binary: octave-mplapack-interop
Dependency order: gmpfrxx_mkII -> MPLAPACK -> mplapack-interop
PPA work started: NO
```

## Revised release stack

See [`docs/dependency-release-stack-r1.md`](../docs/dependency-release-stack-r1.md).
The renamed package's final commit/tag/archive/checksum remain pending.

## Gates

```text
G-D01R1-NAME-SYNTAX: PASS
G-D01R1-DEPS: PENDING — corrected candidate awaits separate MPLAPACK release QA/tag
G-D01R1-RENAME: IN PROGRESS
G-D01R1-IDENTITY: PENDING final 0.2.1 archive/tag
G-D01R1-NUMERICAL-EQUIVALENCE: PENDING final diff audit
G-D01R1-REGRESSION: PASS on current QA stack; final frozen dependency wall pending
G-D01R1-REPRODUCIBLE: PENDING final archive A/B
G-D01R1-BINARY-ARCH: IN PROGRESS; design documented, relocation proof B01-owned
```

## Known limitations

- The corrected MPLAPACK candidate has passed the archive-content audit; its
  separate full release QA and `v3.0.1` tag are still pending.
- The source package is temporarily `0.2.1-dev`; no `v0.2.1` tag has been
  created.
- No B01–B05 production binary, Debian package, PPA upload, or registry
  submission has been started.
