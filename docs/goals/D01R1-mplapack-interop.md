# /goal — D01R1 Rename to `mplapack-interop` and Freeze Binary-Distribution Architecture

## Mission

Rename the GNU Octave package currently identified as:

```text
Name: mplapack
```

to:

```text
Name: mplapack-interop
```

and revise the post-D00 distribution handoff so that all future binary packages, Octave Packages registration, and PPA work use the unambiguous package identity `mplapack-interop`.

D01R1 also freezes the binary-distribution architecture to be consumed by:

```text
B01  Linux x86_64
B02  Linux arm64
B03  macOS arm64
B04  macOS x86_64
B05  Windows x86_64
F00  Octave Packages registration
PPA1-G / PPA1-M / PPA2 / PPA3 / PPA4
```

This is a package-identity and distribution-architecture revision only.

Do not change accepted numerical behavior.

Do not modify frozen `gmpfrxx_mkII` or MPLAPACK numerical source.

Do not begin B01-B05 production binary builds.

Do not begin Debian/PPA packaging.

Do not submit to the Octave Packages index.

---

# 0. D00 baseline

D00 froze:

```text
gmpfrxx_mkII:
    version: 1.4.1
    commit: 32a7fb797202cdf92312ed9d133f96fdbcda590a
    tag: v1.4.1
    archive: gmpfrxx_mkII.1.4.1.tar.xz
    sha256: 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4

MPLAPACK:
    version: 3.0.1
    commit: fa3ccb4376d2a52c2672322e5b7199a9224bed7f
    tag: v3.0.1
    archive: mplapack-3.0.1.tar.xz
    sha256: 7c8d1d7759a487bc01e8c1625599ec77b6c7e297c19b20ca45e8c342f5165e64

octave-mplapack historical D00 state:
    repository: nakatamaho/octave-mplapack
    package Name: mplapack
    version: 0.2.0
    commit: 4a3eb50843a6bf365bdab1e82146ef1900a219f6
    tag: v0.2.0
    archive: mplapack-0.2.0.tar.gz
    sha256: 0e83e26182b0fbd95a064437a97307eb74d9291b49d91c6e53dac181b24a94db
```

The old v0.2.0 state is a historical pre-public release checkpoint.

Do not rewrite it.

---

# 1. Why rename

The Octave package name `mplapack` is too easily confused with the upstream numerical library MPLAPACK.

The intended public identities are:

```text
upstream numerical library:
    MPLAPACK

Git repository:
    octave-mplapack

GNU Octave package:
    mplapack-interop
```

The public Octave usage target is:

```octave
pkg load mplapack-interop

mpbits (512);
A = mp (...);
```

---

# 2. Version policy

Do not reuse or retarget `v0.2.0`.

The renamed package must use:

```text
Name: mplapack-interop
Version: 0.2.1
```

A temporary development version `0.2.1-dev` may be used during the milestone, but the final D01R1 source freeze must be `0.2.1`.

The final source archive must be:

```text
mplapack-interop-0.2.1.tar.gz
```

or the exact canonical archive basename generated from the final Octave package metadata.

Do not create a new archive named `mplapack-0.2.1.tar.gz`.

---

# 3. Repository name

Do not rename the GitHub repository.

Keep:

```text
nakatamaho/octave-mplapack
```

unless the user separately requests a repository rename.

Do not rename the public numeric class:

```text
@mp
mp
mpbits
mpdigits
```

---

# 4. Frozen dependency policy

D01R1 must consume exactly:

```text
gmpfrxx_mkII 1.4.1
    commit 32a7fb797202cdf92312ed9d133f96fdbcda590a

MPLAPACK 3.0.1
    commit fa3ccb4376d2a52c2672322e5b7199a9224bed7f
    pkg-config mplapack_mpfr 3.0.1
    runtime libmplapack_mpfr.so.3
```

No dependency source changes are allowed.

If D01R1 proves that one of these frozen dependencies requires a source-level modification:

```text
D01R1 BLOCKED — D00R1 REQUIRED
```

Stop instead of patching the frozen dependency.

---

# 5. Octave hyphenated-name preflight

Before changing the real package, prove that Octave 11.1.0 supports the exact package name:

```text
mplapack-interop
```

Create a tiny throwaway package outside the real project with:

```text
Name: mplapack-interop
```

Use an isolated Octave package database/prefix and verify:

```text
pkg install
pkg list
pkg describe mplapack-interop
pkg load mplapack-interop
pkg unload mplapack-interop
pkg uninstall mplapack-interop
```

Record actual output and package-manager identity.

Hard gate:

```text
G-D01R1-NAME-SYNTAX PASS
```

If exact `pkg load mplapack-interop` behavior fails:

```text
D01R1 BLOCKED — OCTAVE HYPHENATED PACKAGE NAME
```

Do not continue.

---

# 6. Rename public package identity

Update all current, nonhistorical package identity surfaces as appropriate:

```text
DESCRIPTION Name
DESCRIPTION version/date
source archive basename
source archive top-level directory
README
NEWS
INDEX/package metadata
help text
examples
tests
package lifecycle scripts
local package database tests
developer scripts
release verification scripts
release manifests
compatibility docs
binary-distribution docs
future Octave Packages docs
future PPA naming docs
```

Search:

```bash
rg -n \
  'Name:[[:space:]]*mplapack|pkg load mplapack|pkg unload mplapack|pkg uninstall mplapack|pkg describe mplapack|mplapack-0\.2\.0|mplapack-0\.2\.1' \
  .
```

Classify every match.

Historical D00/M23/C12 reports may retain historical identities.

Do not blindly rewrite historical evidence.

---

# 7. Internal symbols normally remain unchanged

Do not rename internal implementation symbols only for cosmetic consistency.

These may remain unchanged unless technically necessary:

```text
__mplapack_core__.oct
internal C++ namespaces
private bridge commands
MplapackMpfrPrecisionScope
MPLAPACK backend routine names
repository name octave-mplapack
```

The purpose is public package identity clarity, not an internal refactor.

---

# 8. No old-name compatibility package

Default policy:

```text
no alias package named mplapack
no duplicate package registration
no permanent compatibility shim
```

The package was not yet publicly distributed under the final identity.

Document migration from the historical v0.2.0 checkpoint instead.

---

# 9. Migration QA

In an isolated package prefix:

```text
install historical mplapack 0.2.0
verify pkg list
pkg unload mplapack
pkg uninstall mplapack

install mplapack-interop 0.2.1
verify pkg list
pkg describe mplapack-interop
pkg load mplapack-interop
run real smoke
run complex smoke
pkg unload mplapack-interop
```

Verify there is no stale old package entry.

Do not attempt to support simultaneous loading of both package identities.

---

# 10. Numerical equivalence

Define:

```text
OLD_OCTAVE_FREEZE_COMMIT =
4a3eb50843a6bf365bdab1e82146ef1900a219f6
```

At the final renamed source freeze define:

```text
MPLAPACK_INTEROP_FREEZE_COMMIT
```

Audit the diff.

Allowed changes:

```text
package identity
version metadata
docs
tests
release tooling
binary-distribution architecture docs/probes
```

Numerical behavior must be unchanged.

If native/numerical source changes only because package-name/help strings are embedded, classify this explicitly.

Gate:

```text
G-D01R1-NUMERICAL-EQUIVALENCE PASS
```

---

# 11. Full regression wall

Run against the unchanged frozen dependencies:

```text
M00-M23 real regression
C00-C12 complex regression
C11L complex LU
compatibility firewall
dependency probes
package lifecycle
```

Retain all high-precision canaries:

```text
1024-bit / 2^-700
2048-bit / 2^-1500

real rank
real chol
real QR
real pivoted QR
real LU

complex scalar
Cgemm
Cgesv
Cgelsy
Cpotrf
Cgeqrf/Cungqr
Cgeqp3
Cgetrf
mixed real/complex
```

---

# 12. Sanitizers

Run:

```text
ASan
UBSan
LSan
```

through the accepted real+complex native suite.

---

# 13. Rename package lifecycle

From the final renamed source archive:

```text
pkg install
pkg list
pkg describe mplapack-interop
pkg load mplapack-interop
real smoke
complex smoke
help
examples
pkg unload mplapack-interop
pkg uninstall mplapack-interop
reinstall
second smoke
```

All PASS.

---

# 14. Freeze renamed source

Freeze:

```text
Name: mplapack-interop
Version: 0.2.1
```

Generate:

```text
mplapack-interop-0.2.1.tar.gz
```

Build it twice from independent clean trees.

Require:

```text
same archive file list
same normalized metadata
same SHA256
```

Record:

```text
MPLAPACK_INTEROP_FREEZE_COMMIT
MPLAPACK_INTEROP_ARCHIVE
MPLAPACK_INTEROP_ARCHIVE_SIZE
MPLAPACK_INTEROP_SHA256
```

---

# 15. Preserve old D00 artifact

Do not overwrite/delete:

```text
mplapack-0.2.0.tar.gz
SHA256:
0e83e26182b0fbd95a064437a97307eb74d9291b49d91c6e53dac181b24a94db
```

Treat it as historical D00 provenance.

---

# 16. New tag

Do not modify:

```text
v0.2.0
```

After all rename/source gates pass, create:

```text
v0.2.1
```

pointing exactly to:

```text
MPLAPACK_INTEROP_FREEZE_COMMIT
```

Use the same annotated-tag policy established by the repository.

Verify local and remote dereferenced tag target.

Do not create a GitHub Release yet.

---

# 17. Revised release-stack manifest

Do not rewrite the historical D00 report.

Update the canonical forward-looking manifest or create:

```text
docs/dependency-release-stack-r1.md
```

It must record:

```text
gmpfrxx_mkII:
    1.4.1
    unchanged

MPLAPACK:
    3.0.1
    unchanged

historical Octave package:
    Name: mplapack
    Version: 0.2.0
    Tag: v0.2.0
    historical only

current distribution package:
    Name: mplapack-interop
    Version: 0.2.1
    Commit: <freeze>
    Tag: v0.2.1
    Archive: mplapack-interop-0.2.1.tar.gz
    SHA256: <new hash>
```

All B/F/PPA work must consume the R1 identity.

---

# 18. D01R1 binary-distribution architecture mission

After the rename source is proven, define the architecture for downloadable prebuilt Octave packages.

Do not produce final B01-B05 artifacts in D01R1.

Prototype/probe work is allowed.

The final architecture must cover:

```text
B01 Linux x86_64
B02 Linux arm64
B03 macOS arm64
B04 macOS x86_64
B05 Windows x86_64
```

---

# 19. Audit Octave `pkg build`

Using Octave 11.1.0, audit:

```octave
pkg build BUILDDIR mplapack-interop-0.2.1.tar.gz
```

Record:

```text
produced archive name/layout
DESCRIPTION identity
architecture-dependent directory
.oct placement
PKG_ADD/PKG_DEL behavior
pkg install result
pkg list result
pkg load result
pkg unload result
pkg uninstall result
```

The binary form must itself be normally installable by `pkg`.

---

# 20. Octave ABI compatibility key

Determine the binary compatibility identity from actual Octave tooling.

Record at minimum:

```text
Octave version
Octave API version
target OS
target architecture
mkoctfile identity
compiler/toolchain
C++ ABI assumptions
```

Define the exact compatibility key B01-B05 use.

Do not promise binary compatibility across different Octave API versions without evidence.

---

# 21. Public binary artifact naming

Choose a deterministic pattern after ABI audit.

Preferred conceptual pattern:

```text
mplapack-interop-0.2.1-octave<abi>-<os>-<arch>.tar.gz
```

Examples may become:

```text
mplapack-interop-0.2.1-octave11-linux-x86_64.tar.gz
mplapack-interop-0.2.1-octave11-linux-aarch64.tar.gz
mplapack-interop-0.2.1-octave11-macos-arm64.tar.gz
mplapack-interop-0.2.1-octave11-macos-x86_64.tar.gz
mplapack-interop-0.2.1-octave11-windows-x86_64.tar.gz
```

Do not freeze the exact `octave11` component until the API audit determines whether an Octave API identifier is better.

Internal DESCRIPTION remains:

```text
Name: mplapack-interop
Version: 0.2.1
```

---

# 22. User UX target

Normal binary-package usage must be:

```octave
pkg install <platform-binary-package>.tar.gz
pkg load mplapack-interop

mpbits ()
```

Expected default:

```text
512
```

No compiler required.

Normal users should not need to configure:

```text
LD_LIBRARY_PATH
DYLD_LIBRARY_PATH
PKG_CONFIG_PATH
CMAKE_PREFIX_PATH
```

---

# 23. Source package vs binary package

Maintain distinct release classes:

```text
source:
    mplapack-interop-0.2.1.tar.gz

binary:
    platform/ABI-qualified binary package
```

Source install may require development dependencies.

Binary install must not require a compiler.

---

# 24. Runtime dependency closure

Determine the actual runtime closure of `__mplapack_core__.oct`.

At minimum audit:

```text
gmpfrxx default-context provider library if dynamically required
libmplapack_mpfr
MPC
MPFR
GMP
C++ runtime
compiler runtime
Octave libraries
other actual dependencies
```

Derive from built artifacts.

Do not guess.

---

# 25. Preferred runtime model

Prefer a self-contained package-local runtime for B01-B05 where technically and legally appropriate.

Do not install private dependency libraries globally from an Octave binary package.

Design:

```text
Octave package
├── normal package files
├── architecture-specific __mplapack_core__.oct
└── private runtime libraries
```

Determine the exact package-safe locations.

---

# 26. Linux loader strategy

Audit/prototype:

```text
$ORIGIN
DT_RUNPATH
DT_RPATH
link-time -Wl,-rpath
patchelf only if justified
```

Goal:

```text
.oct resolves its package-local private runtime without LD_LIBRARY_PATH
```

Audit transitive shared-library resolution as well.

---

# 27. macOS loader strategy

Define/prototype plan:

```text
@loader_path
@rpath
install_name
otool -L
install_name_tool if required
codesigning implications
```

Goal:

```text
.oct and bundled dylibs resolve package-locally without DYLD_LIBRARY_PATH
```

Production builds belong to B03/B04.

---

# 28. Windows loader strategy

Define:

```text
package-local DLL layout
DLL search behavior
Octave/MinGW ABI compatibility
MPLAPACK/MPFR/MPC/GMP DLL closure
```

Determine the expected placement relative to `.oct`.

Production build belongs to B05.

---

# 29. Bundle/system dependency matrix

Create a table:

```text
Dependency | Linux | macOS | Windows | Bundle? | System? | Reason | License
```

Cover:

```text
gmpfrxx runtime provider
MPLAPACK MPFR runtime
MPC
MPFR
GMP
libstdc++ / libc++
compiler runtime
Octave runtime
```

Do not bundle Octave itself.

Do not casually bundle system C libraries.

---

# 30. Licensing and source correspondence

Create/update:

```text
docs/binary-redistribution-licenses.md
```

Record redistribution obligations for:

```text
mplapack-interop
MPLAPACK
gmpfrxx_mkII
GMP
MPFR
MPC
any compiler/runtime library planned for bundling
```

Define how binary releases refer users to exact corresponding source:

```text
version
tag
source URL
SHA256
```

D01R1 is an architecture/license inventory, not legal advice.

---

# 31. Binary manifest

Define a manifest included in each B01-B05 binary artifact.

It must record:

```text
package Name
package Version
source commit
source archive SHA256
gmpfrxx version/tag/SHA256
MPLAPACK version/tag/SHA256
Octave version
Octave API version
OS
architecture
compiler/toolchain
bundled runtime files
runtime licenses/notices
build provenance
```

Choose a package location that survives `pkg build`/`pkg install`.

Verify rather than assume.

---

# 32. Install/unload/uninstall architecture

A binary package must support:

```text
pkg install
pkg load mplapack-interop
pkg unload mplapack-interop
pkg uninstall mplapack-interop
```

No package-local runtime files may be orphaned.

Avoid copying SO/dylib/DLL files to global system directories.

---

# 33. Old/new coexistence

Audit whether historical:

```text
mplapack 0.2.0
```

and:

```text
mplapack-interop 0.2.1
```

can coexist.

Because both expose the same `mp` class, supported user guidance should normally be:

```text
uninstall old mplapack before installing mplapack-interop
```

Do not add complicated conflict management unless necessary.

---

# 34. F00 identity

Future Octave Packages registration must use:

```text
mplapack-interop
```

not `mplapack`.

Record:

```text
package index name: mplapack-interop
repository: https://github.com/nakatamaho/octave-mplapack
```

Do not submit in D01R1.

---

# 35. Future PPA identity

Correct future PPA assumptions.

Recommended user-facing Debian binary package candidate:

```text
octave-mplapack-interop
```

The exact Debian source/binary naming is finalized in the PPA policy milestone.

Dependency order remains:

```text
gmpfrxx_mkII
    ->
MPLAPACK
    ->
mplapack-interop
```

Do not create Debian metadata here.

---

# 36. Linux proof-of-architecture

On the current Linux host, build one non-release proof-of-architecture binary package if practical.

Requirements:

```text
renamed package builds
binary archive installs
package reports mplapack-interop
__mplapack_core__.oct loads
runtime relocation concept is demonstrated
real smoke passes
complex smoke passes
```

This is not B01.

Do not publish this prototype.

If final relocation work is clearly B01-owned, document the proven design and remaining bounded B01 work.

---

# 37. No absolute-path runtime design

The accepted binary architecture must not require:

```text
/home/<user>/...
/tmp/...
custom /usr/local prefix
```

at runtime.

Any prototype using temporary prefixes must prove how B01 makes the final artifact relocatable.

---

# 38. Documentation

Create/update:

```text
docs/binary-distribution.md
docs/binary-redistribution-licenses.md
docs/dependency-release-stack-r1.md
docs/octave-compatibility.md
README.md
NEWS.md
docs/goals/D01R1-mplapack-interop-binary-architecture.md
reports/D01R1-report.md
```

Keep historical D00 material historical.

---

# 39. B01-B05 handoff contract

Common immutable source input after D01R1:

```text
package:
    mplapack-interop

version:
    0.2.1

source commit:
    MPLAPACK_INTEROP_FREEZE_COMMIT

source archive:
    mplapack-interop-0.2.1.tar.gz

source SHA256:
    <D01R1 result>

dependencies:
    gmpfrxx_mkII 1.4.1
    MPLAPACK 3.0.1
```

B01-B05 may not silently change numerical source.

---

# 40. B target matrix

Output a final table for:

```text
B01 Linux x86_64
B02 Linux arm64
B03 macOS arm64
B04 macOS x86_64
B05 Windows x86_64
```

For each record:

```text
target Octave version/API
toolchain
artifact filename pattern
runtime dependency strategy
loader strategy
test environment
dependency-inspection tool
smoke tests
license bundle
binary manifest
```

Do not build final artifacts during D01R1.

---

# 41. Gates

## G-D01R1-NAME-SYNTAX

PASS only if exact `mplapack-interop` install/load/unload/uninstall behavior is proven with Octave 11.1.0.

## G-D01R1-DEPS

PASS only if frozen gmpfrxx/MPLAPACK identity remains unchanged and provenance is verified.

## G-D01R1-RENAME

PASS only if all current public package identity surfaces use `mplapack-interop`.

## G-D01R1-IDENTITY

PASS only if:

```text
Name = mplapack-interop
Version = 0.2.1
archive = mplapack-interop-0.2.1.tar.gz
pkg load identity = mplapack-interop
old v0.2.0 untouched
v0.2.1 tag correct
```

## G-D01R1-NUMERICAL-EQUIVALENCE

PASS only if no numerical behavior changed.

## G-D01R1-REGRESSION

PASS only if M00-M23, C00-C12, C11L, canaries, firewall, and sanitizers pass.

## G-D01R1-REPRODUCIBLE

PASS only if the renamed source archive reproduces byte-identically.

## G-D01R1-BINARY-ARCH

PASS only if the complete B01-B05 architecture is frozen.

---

# 42. Overall gate

D01R1 PASS requires:

```text
G-D01R1-NAME-SYNTAX            PASS
G-D01R1-DEPS                   PASS
G-D01R1-RENAME                 PASS
G-D01R1-IDENTITY               PASS
G-D01R1-NUMERICAL-EQUIVALENCE  PASS
G-D01R1-REGRESSION             PASS
G-D01R1-REPRODUCIBLE           PASS
G-D01R1-BINARY-ARCH            PASS
```

Final conclusion:

```text
D01R1 PASS — MPLAPACK-INTEROP IDENTITY FROZEN
B01-READY
```

---

# 43. Failure classifications

If hyphenated package loading fails:

```text
D01R1 BLOCKED — OCTAVE HYPHENATED PACKAGE NAME
```

If numerical behavior changes:

```text
D01R1 FAIL — NUMERICAL REGRESSION
```

If old v0.2.0 history is rewritten:

```text
D01R1 FAIL — RELEASE HISTORY REWRITE
```

If the archive name changes but DESCRIPTION remains `mplapack`:

```text
D01R1 FAIL — COSMETIC-ONLY RENAME
```

If frozen dependencies require source modification:

```text
D01R1 BLOCKED — D00R1 REQUIRED
```

If accepted runtime architecture requires developer absolute paths:

```text
D01R1 FAIL — NON-RELOCATABLE BINARY ARCHITECTURE
```

---

# 44. Git policy

Suggested branch:

```text
topic/d01r1-mplapack-interop
```

Do not force-push.

Before commits:

```bash
git status --short
git diff --check
```

Do not commit production binary artifacts.

Do not rewrite historical tags.

---

# 45. Suggested commits

Prefer:

```text
1. D01R1: rename Octave package to mplapack-interop
2. D01R1: close renamed package lifecycle and migration QA
3. D01R1: define relocatable binary-distribution architecture
4. D01R1: freeze mplapack-interop 0.2.1 source identity
5. docs: record D01R1 report/handoff
```

---

# 46. Final report

Produce:

```text
# D01R1 RESULT

## Result

D01R1 PASS / FAIL / BLOCKED

Release identity conclusion:
MPLAPACK-INTEROP IDENTITY FROZEN / NOT-FROZEN

Binary distribution conclusion:
B01-READY / NOT-READY

## Historical D00 package identity

Repository:
Old package Name:
Old version:
Old freeze commit:
Old tag:
Old archive:
Old SHA256:
Old tag unchanged:

## Frozen dependencies

### gmpfrxx_mkII
Version:
Commit:
Tag:
Archive:
SHA256:
Changed during D01R1:

### MPLAPACK
Version:
Commit:
Tag:
Archive:
SHA256:
Runtime SONAME:
Changed during D01R1:

## Package-name preflight

Octave:
Temporary package:
Name:
Install:
pkg list:
pkg describe:
pkg load:
pkg unload:
pkg uninstall:
Hyphen supported:
Result:

## New package identity

Repository:
Package Name:
Version:
Freeze commit:
Tag:
Tag target:
Archive:
Archive size:
SHA256 A:
SHA256 B:
Hashes identical:
Top-level directory:
pkg list identity:
pkg describe identity:
pkg load identity:
Result:

## Rename diff audit

DESCRIPTION:
README:
NEWS:
INDEX:
Help:
Examples:
Tests:
Release tooling:
Package lifecycle:
Historical docs preserved:
Internal symbols renamed:
Numerical source changed:
Result:

## Migration QA

Old 0.2.0 install:
Old unload:
Old uninstall:
New 0.2.1 install:
New pkg list:
New load:
Real smoke:
Complex smoke:
Stale old package entry:
Result:

## Full regression

M00-M23:
C00-C12:
C11L:
1024:
2048:
Compatibility firewall:
ASan:
UBSan:
LSan:
Package lifecycle:
Result:

## Octave binary package audit

pkg build:
Binary archive internal Name:
Architecture-dependent path:
.oct location:
Install:
Load:
Unload:
Uninstall:
Result:

## ABI compatibility key

Octave version:
Octave API version:
OS:
Architecture:
Compiler/toolchain:
Required key for B01-B05:
Result:

## Runtime dependency closure

gmpfrxx runtime:
MPLAPACK runtime:
MPC:
MPFR:
GMP:
C/C++ runtimes:
Octave libraries:
Other:
Result:

## Binary runtime layout

Common layout:
Package-local runtime directory:
.oct location:
Manifest location:

### Linux
Loader strategy:
Prototype:
Environment variable required:
Result:

### macOS
Loader strategy:
Planned tools:
Environment variable required:
Result:

### Windows
DLL strategy:
Planned placement:
Environment variable required:
Result:

## Licensing

Project license:
MPLAPACK:
gmpfrxx:
GMP:
MPFR:
MPC:
Bundled-runtime notice strategy:
Corresponding-source strategy:
File:
Result:

## Binary artifact naming

Source:
Linux x86_64:
Linux arm64:
macOS arm64:
macOS x86_64:
Windows x86_64:

## B01-B05 handoff

### B01
...

### B02
...

### B03
...

### B04
...

### B05
...

## F00 handoff

Octave Packages name:
Repository:
Source release identity:
Index work started:
Result:

## PPA naming handoff

Recommended Debian source:
Recommended Debian binary:
Dependency order:
PPA work started:

## Revised release stack

gmpfrxx_mkII:
    version:
    commit:
    tag:
    archive:
    sha256:

MPLAPACK:
    version:
    commit:
    tag:
    archive:
    sha256:

mplapack-interop:
    version:
    commit:
    tag:
    archive:
    sha256:

## Gates

G-D01R1-NAME-SYNTAX:
G-D01R1-DEPS:
G-D01R1-RENAME:
G-D01R1-IDENTITY:
G-D01R1-NUMERICAL-EQUIVALENCE:
G-D01R1-REGRESSION:
G-D01R1-REPRODUCIBLE:
G-D01R1-BINARY-ARCH:

## Changes
...

## Commits
...

## Push / PR

Branch:
PR:
Remote tip:
Tag push:
CI:

## Known limitations
...

## Next milestone

If D01R1 PASS:

Proceed to:

B01 — Linux x86_64 binary package

B01 must consume exactly the frozen `mplapack-interop` source commit/archive/
SHA256 and the unchanged D00 dependency stack recorded here.

Do not modify numerical source in B01.

If B01 discovers a source-level problem, stop and reopen the appropriate
freeze rather than patching the release silently.

Do not begin B01 automatically.
```

---

# 47. Stop

After the D01R1 report:

```text
STOP
```

Do not begin:

```text
B01
B02
B03
B04
B05
F00
PPA1-G
PPA1-M
PPA2
PPA3
PPA4
```

automatically.
