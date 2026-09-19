# /goal — RELDEB00: mplapack-interop 0.5.0 Debian/PPA Release Controller

## Mission

Take the already-released upstream stack:

```text
gmpfrxx_mkII 1.4.1
MPLAPACK 3.0.1
mplapack-interop 0.5.0
```

and carry it through:

```text
0.5.0 release provenance
  ↓
Debian packaging for three source packages
  ↓
clean Debian build / policy / autopkgtest QA
  ↓
Ubuntu 26.04 LTS staging PPA
  ↓
clean apt-install validation
  ↓
Debian WNPP / ITP
  ↓
Salsa / mentors.debian.net publication
  ↓
RFS sponsorship requests
  ↓
Debian official submission handoff
```

The intended end state is not merely "we have .deb files".

The intended end state is:

```text
PPA staging package works from apt
AND
all three Debian source packages are publicly submitted for sponsorship/NEW
OR
the controller stops at the exact external credential/human gate with every artifact ready.
```

Do not add new numerical features.

Do not change the accepted `mplapack-interop 0.5.0` numerical contract.

Do not start T15+ development.

---

# 0. Current official process references

Before packaging, read the current official documentation rather than relying on stale local notes.

Required references:

```text
Debian Developer's Reference:
https://www.debian.org/doc/manuals/developers-reference/

Debian Policy:
https://www.debian.org/doc/debian-policy/

Debian Mentors:
https://mentors.debian.net/intro-maintainers/
https://mentors.debian.net/sponsors/rfs-howto/

Debian Science:
https://wiki.debian.org/Teams/DebianScience
https://salsa.debian.org/science-team/policy

Debian Octave Group:
https://wiki.debian.org/Teams/DebianOctaveGroup

Salsa CI:
https://wiki.debian.org/SalsaCI

Launchpad PPA uploads:
https://help.launchpad.net/Packaging/PPA/Uploading

Ubuntu release/suite status:
https://ubuntu.com/about/release-cycle
https://packages.ubuntu.com/octave
```

Record the retrieval date and relevant version information in the final report.

Do not copy obsolete packaging snippets merely because they appear in old project notes.

---

# 1. High-level controller graph

Execute in this order:

```text
R00  Release provenance freeze
 ↓
P00  Debian/Ubuntu availability and name collision audit
 ↓
P01  Packaging architecture and license/copyright audit
 ↓
P02  gmpfrxx_mkII Debian source package
 ↓
P03  MPLAPACK Debian source package
 ↓
P04  octave-mplapack-interop Debian source package
 ↓
P05  Clean Debian build / lintian / autopkgtest / install QA
 ↓
U00  Ubuntu staging-PPA preparation
 ↓
U01  Upload dependencies to staging PPA in order
 ↓
U02  Build/publish/install QA on Ubuntu 26.04 LTS
 ↓
D00  WNPP/ITP publication
 ↓
D01  Salsa/mentors publication
 ↓
D02  RFS sponsorship requests
 ↓
FINAL  Debian official submission handoff
```

Continue automatically through local, noninteractive work.

For public network actions:
- the user explicitly requested Debian/PPA submission through this `/goal`;
- therefore public submission is authorized if credentials are already configured and the relevant
  local quality gates PASS;
- never invent credentials, team membership, package acceptance, sponsor approval, or upload rights.

If required credentials/accounts are unavailable, stop only at the exact external gate after
preparing every local artifact and command needed to continue.

---

# 2. Release provenance — R00

## Mission

Create one authoritative provenance record for all three upstream releases.

Create:

```text
release/debian/PROVENANCE.md
release/debian/SHA256SUMS
```

## 2.1 `mplapack-interop 0.5.0`

Determine from the actual upstream release:

```text
repository URL
tag
tag target/freeze commit
release tarball filename
release tarball SHA256
release asset URL
package DESCRIPTION Name/Version
minimum GNU Octave version
license
```

Do not infer these from the old `0.5.0-dev` tree.

Require:

```text
Name: mplapack-interop
Version: 0.5.0
```

and verify the release archive installs and loads before packaging.

## 2.2 MPLAPACK 3.0.1

Record:

```text
repository URL
tag
release commit
release tarball
SHA256
pkg-config identities
installed SONAMEs
license(s)
```

The user has stated that MPLAPACK 3.0.1 is now formally released.

Do not keep documentation describing it as a release candidate once the final release identity is
verified.

Compare the final release tarball against the previously tested RC artifact if the RC is available.

If SHA256 is identical:

```text
RC ARTIFACT == FINAL ARTIFACT
```

record that no additional numerical retest was needed merely for provenance.

If SHA differs:
1. unpack both;
2. compare source trees;
3. classify:
   - compression/metadata only;
   - generated/release metadata only;
   - source/build/numerical content changed.
4. rerun the appropriate QA before proceeding.

## 2.3 gmpfrxx_mkII 1.4.1

Record:

```text
repository URL
tag
release commit
tarball
SHA256
license
installed headers
installed provider/shared-library artifacts
SONAME if any
pkg-config/CMake metadata
```

Do not rely on historical hashes if the actual published release artifact differs.

## 2.4 Provenance gate

R00 PASS requires:

```text
all three release tarballs downloaded/available
SHA256 recorded
tag/commit recorded
license identified
upstream release URL recorded
no development checkout is used as a substitute for a released tarball
```

Conclusion:

```text
R00 PASS — UPSTREAM RELEASE STACK FROZEN
```

---

# 3. Package-existence and name collision audit — P00

Before creating Debian packaging, check current:

```text
packages.debian.org
tracker.debian.org
WNPP bugs
mentors.debian.net
Ubuntu package search
Launchpad PPA namespace as relevant
```

for:

```text
gmpfrxx
gmpfrxx-mkii
mplapack
octave-mplapack
octave-mplapack-interop
```

Do not confuse `mplapack` with `mlpack`.

Record:

```text
existing Debian source package?
existing Debian binary package?
existing WNPP ITP/RFP?
existing mentors upload?
existing Salsa packaging repo?
conflicting package name?
```

If an existing active ITP/package exists, do not create a duplicate.

Stop and report the correct collaboration/adoption path.

If no collision exists, record candidate Debian source package names:

```text
gmpfrxx-mkii
mplapack
octave-mplapack-interop
```

These names are proposals until the audit passes.

Conclusion:

```text
P00 PASS — PACKAGE NAMES AVAILABLE
```

---

# 4. Debian team / maintenance routing audit

Determine the most natural maintenance route.

Expected candidates:

```text
gmpfrxx-mkii:
    Debian Science or individual + Debian Science co-maintenance

mplapack:
    Debian Science

octave-mplapack-interop:
    Debian Octave Group is the natural first choice;
    Debian Science may also be relevant because of the dependency stack
```

Do not set a team as `Maintainer:` merely because it looks appropriate.

Team-maintained `Maintainer` / `Uploaders` fields require alignment with the team's current policy
and preferably team consent.

Before team consent, packaging may be prepared with the actual maintainer identity and a clear
proposal to transfer/co-maintain under the appropriate team.

Create:

```text
release/debian/TEAM-ROUTING.md
```

with:
- candidate team;
- contact address;
- Salsa group;
- current policy URL;
- proposed Maintainer/Uploaders fields;
- status: PROPOSED / CONFIRMED.

Never label PROPOSED as CONFIRMED.

---

# 5. Packaging architecture and licensing — P01

## Mission

Determine Debian source/binary split from actual installed artifacts and Debian Policy.

Do not decide binary package names from memory.

Perform staged installs using each release tarball into a temporary `DESTDIR`.

Inventory:

```text
headers
shared libraries
SONAMEs
static libraries
pkg-config files
CMake files
executables
Octave .oct files
Octave .m files
documentation
examples
license/copyright files
bundled third-party source
```

Use:

```bash
readelf -d
objdump -p
file
ldd
pkg-config
find DESTDIR
```

as appropriate.

---

# 6. gmpfrxx_mkII binary split

The upstream wrapper may be predominantly header-based but can include a shared default-context
provider.

Audit first.

Do not assume the runtime package name.

If a shared provider has a stable SONAME, derive the Debian runtime library package name from that
SONAME according to current Debian Policy.

Possible conceptual split:

```text
source: gmpfrxx-mkii

binary:
    libgmpfrxx-mkii-dev
    <SONAME-derived runtime package, only if required>
```

This is illustrative only.

If the provider library is private or lacks a proper SONAME:
- do not create a misleading ABI package;
- determine whether upstream needs an ABI/SONAME fix before Debian packaging;
- prefer an upstream fix over a Debian-only ABI invention.

Audit:
- Multi-Arch eligibility;
- architecture-independent headers vs architecture-specific metadata;
- exact GMP/MPFR/MPC dependencies;
- whether MPC is required for the MPFR-only header layer.

Conclusion must state the actual binary package split.

---

# 7. MPLAPACK binary split

Audit the actual MPLAPACK 3.0.1 installed libraries and SONAMEs.

The Debian package needed by `mplapack-interop` must at least provide the MPFR backend.

Do not automatically package every optional backend merely because upstream can build it.

For the initial Debian upload, choose the smallest policy-compliant, useful scope that:
- supports `mplapack-interop`;
- is reasonable for Debian Science;
- uses system dependencies;
- does not bundle duplicate libraries into runtime paths.

Potential conceptual split might include:

```text
source: mplapack

runtime library package(s) derived from actual SONAME:
    libmpblas-mpfr<SONAME>
    libmplapack-mpfr<SONAME>

development:
    libmplapack-mpfr-dev

optional docs/tools:
    mplapack-doc
```

but **do not use these exact names until SONAME audit confirms them**.

If mpblas and mplapack share an ABI transition policy, document whether they belong in one or
separate runtime packages.

Use current Debian shared-library policy:
- runtime package names follow SONAME transitions;
- dev symlinks/headers/pkg-config belong in development packages;
- provide `symbols` or `shlibs` as appropriate;
- run `dpkg-shlibdeps`.

---

# 8. Bundled dependency audit for MPLAPACK

MPLAPACK upstream release sources may include third-party source trees/tarballs.

Debian packaging must explicitly audit:

```text
GMP
MPFR
MPC
QD
OpenBLAS
LAPACK source
gmpfrxx_mkII
other bundled source
```

For each bundled component classify:

```text
required source input
used by Debian build
unused embedded copy
generated source
license obligation
candidate for repack removal
```

Prefer system Debian libraries for build/runtime dependencies when practical.

Do not silently compile private copies of GMP/MPFR/MPC/OpenBLAS into Debian packages if Debian
already provides suitable system packages.

Do not use `+dfsg` unless material is actually removed for DFSG/licensing reasons.

If the source tarball is repacked only to remove embedded/de-duplicated sources for Debian
maintenance reasons, use a Debian-appropriate repack suffix and document exactly why.

Do not create a repack until sponsor/team policy and license audit justify it.

---

# 9. `debian/copyright`

For all three source packages, create machine-readable DEP-5 copyright files.

Audit every shipped file/source subtree that enters the Debian source package.

Particular care:
- MPLAPACK's own BSD-style license;
- original LAPACK licensing;
- generated/mechanically converted LAPACK sources;
- bundled third-party code retained in the source package;
- gmpfrxx_mkII license;
- Octave package code/docs/examples;
- any copied test matrices/reference data.

Do not assume the top-level upstream license covers every bundled subtree.

Run license scanners only as aids; manually verify results.

NEW queue review will heavily inspect copyright/licensing.

---

# 10. Debian packaging repository layout

Use modern Debian packaging conventions.

Preferred:
- source format `3.0 (quilt)` unless team policy indicates otherwise;
- `git-buildpackage`;
- DEP-14-compatible branch naming where team policy uses it;
- `pristine-tar` if the selected team workflow expects it;
- Salsa CI recipe.

Do not create official team Salsa repositories without team permission.

Until team access exists:
- use local repos;
- optionally use the maintainer's personal Salsa namespace;
- prepare transfer/import instructions.

Create packaging workspaces under:

```text
release/debian/repos/
    gmpfrxx-mkii/
    mplapack/
    octave-mplapack-interop/
```

unless the project already has a cleaner packaging-repository convention.

Do not contaminate immutable upstream release tags with Debian packaging commits.

---

# 11. P02 — package `gmpfrxx-mkii`

Create complete Debian packaging:

```text
debian/control
debian/changelog
debian/rules
debian/source/format
debian/copyright
debian/watch
debian/upstream/metadata
debian/tests/*
debian/*.install
debian/*.symbols or shlibs policy if applicable
debian/gbp.conf where appropriate
debian/salsa-ci.yml
```

Use current `debhelper-compat`.

Do not hard-code obsolete compat levels from old examples.

Build-Depends should use Debian system packages such as:

```text
libgmp-dev
libmpfr-dev
libmpc-dev
cmake / pkgconf / compiler
```

only as actually required.

## gmpfrxx autopkgtest

At minimum:
1. compile a small C++ program against installed public headers;
2. exercise real arbitrary precision;
3. exercise one special function wrapper used by `mplapack-interop`;
4. link/load the provider library if applicable;
5. verify pkg-config/CMake metadata if shipped.

No test may use the source tree accidentally.

Conclusion:

```text
P02 PASS — GMPFRXX-MKII DEBIAN PACKAGE READY
```

---

# 12. P03 — package MPLAPACK 3.0.1

Create complete Debian packaging from the final released tarball.

The Debian build must:
- use system gmpfrxx-mkii package created in P02;
- use system GMP/MPFR/MPC;
- build the selected MPFR backend;
- install public headers;
- install pkg-config metadata required by interop;
- preserve `mplapack_mpfr_precision.h`;
- produce policy-compliant shared libraries.

Do not use the developer's `/usr/local` or `$HOME/MPLAPACK`.

## MPLAPACK tests

Run package build-time tests at a scale suitable for Debian builders.

Do not make the package take an unreasonable time on slow architectures.

Split tests into:
- deterministic build-time smoke/core tests;
- heavier autopkgtest where appropriate.

Mandatory installed-package autopkgtest:
- pkg-config lookup;
- compile/link simple real MPFR `Rgemm` or `Rgesv`;
- compile/link simple complex MPFR/MPC routine;
- run both;
- confirm runtime loader resolves Debian-installed shared libs only.

Audit:
- `dpkg-shlibdeps`;
- symbols/shlibs;
- `ldd`;
- no RPATH into build/source/home directories.

Conclusion:

```text
P03 PASS — MPLAPACK DEBIAN PACKAGE READY
```

---

# 13. P04 — package `octave-mplapack-interop`

Use the released:

```text
mplapack-interop 0.5.0
```

source archive.

Use Debian's current Octave add-on packaging infrastructure.

Audit and prefer:

```text
dh-octave
dh-octave-autopkgtest
```

according to current Debian Octave Group practice.

Do not manually reproduce obsolete Octave package helper logic if `dh-octave` provides it.

## Debian dependency baseline

The package requires GNU Octave >= 11.1 according to the upstream contract.

Express dependencies/build-dependencies correctly.

Do not relax upstream's Octave minimum simply to support older Ubuntu releases.

Build against P03's development package and P02's headers/runtime as required.

## Binary package

Expected conceptual source/binary naming:

```text
source:
    octave-mplapack-interop

binary:
    octave-mplapack-interop
```

but verify Debian Octave Group naming policy.

Architecture must reflect the compiled `.oct` module; do not mark it `Architecture: all` if native
architecture-specific code is shipped.

## Autopkgtest

Use the installed Debian package only.

Mandatory smoke:

```octave
pkg load mplapack-interop
mpbits (128)
basic mp scalar
real matrix multiply
real solve
complex operation
eig on a small nonsymmetric matrix
svd
serialization round-trip
RNG fixed-seed replay
```

Include a small Grcar residual if runtime is reasonable.

Do not run the entire upstream release wall as an autopkgtest.

Keep archive tests useful for Debian buildds/CI.

Conclusion:

```text
P04 PASS — OCTAVE-MPLAPACK-INTEROP DEBIAN PACKAGE READY
```

---

# 14. P05 — clean Debian QA wall

Use Debian unstable (`sid`) as the primary package target.

Verify current:

```bash
apt-cache policy octave octave-dev dh-octave
```

The package needs Octave >= 11.1.

Use `sbuild` as the primary clean build gate.

Required for each source package:

```text
source package builds
binary package builds
build dependencies complete
no network during build
tests pass
```

Required QA tools where applicable:

```text
lintian --pedantic
autopkgtest
piuparts
blhc
reprotest
dpkg-gensymbols
dpkg-shlibdeps
```

Do not add unjustified lintian overrides.

Create a local APT repository or equivalent and test the full dependency stack through APT:

```text
gmpfrxx-mkii
    ↓
mplapack
    ↓
octave-mplapack-interop
```

Then from a clean environment run:

```bash
apt install octave-mplapack-interop
```

No:
- `LD_LIBRARY_PATH`;
- `$HOME` prefixes;
- local source trees;
- custom `PKG_CONFIG_PATH`.

Conclusion:

```text
P05 PASS — THREE-PACKAGE DEBIAN STACK CLEAN
```

---

# 15. ABI, symbols, Multi-Arch, reproducibility

Before public upload, create:

```text
release/debian/ABI.md
release/debian/MULTIARCH.md
release/debian/REPRODUCIBILITY.md
```

For every shared library record:
- filename;
- SONAME;
- Debian binary package;
- `symbols` or `shlibs`;
- dev dependency;
- Multi-Arch decision.

Do not add Multi-Arch fields by habit.

For C++ libraries, evaluate whether full `symbols` maintenance is sustainable; Debian Policy allows
`symbols` or `shlibs`.

Build twice where practical and use `diffoscope` when artifacts differ.

---

# 16. Ubuntu staging PPA — U00

The mandatory initial PPA target is:

```text
Ubuntu 26.04 LTS (Resolute)
```

because `mplapack-interop 0.5.0` requires GNU Octave >= 11.1 and Ubuntu 26.04 provides Octave
11.1.0.

Do not target the interop package at:
- Ubuntu 24.04 LTS (Octave 8.4);
- Ubuntu 25.10 (Octave 9.4);
- Ubuntu 22.04 LTS (Octave 6.4);

unless a separate Octave backport project is explicitly approved.

Do not backport Octave in this controller.

Keep the first staging stack coherent and target Ubuntu 26.04 only.

---

# 17. PPA naming and version ordering

Discover the configured Launchpad owner and PPA.

Prefer a staging PPA, conceptually:

```text
<owner>/mplapack-staging
```

Do not invent an owner.

Use PPA versions that sort below the eventual Debian official versions, conceptually:

```text
1.4.1-1~ppa1~ubuntu26.04.1
3.0.1-1~ppa1~ubuntu26.04.1
0.5.0-1~ppa1~ubuntu26.04.1
```

Verify with `dpkg --compare-versions`.

Never reuse an already-uploaded PPA version.

---

# 18. PPA credentials preflight

Verify:
- Launchpad account;
- staging PPA;
- upload permission;
- GPG key;
- `dput`/`dput-ng`;
- signed source artifacts.

Never print or commit secrets.

If credentials/PPA are unavailable, prepare exact artifacts and setup instructions and stop:

```text
U01 BLOCKED — LAUNCHPAD CREDENTIAL/PPA ACTION REQUIRED
```

Do not claim PPA PASS.

---

# 19. U01 — upload to staging PPA

Upload source packages in dependency order:

```text
1. gmpfrxx-mkii
2. mplapack
3. octave-mplapack-interop
```

Do not upload a dependent package until its build dependencies are published in the PPA.

Record Launchpad build URLs/IDs.

Require publication before proceeding.

Conclusion:

```text
U01 PASS — STAGING PPA STACK PUBLISHED
```

---

# 20. U02 — Ubuntu 26.04 clean apt-install QA

Use a clean Ubuntu 26.04 environment with only normal Ubuntu repositories plus the staging PPA.

Run:

```bash
sudo apt update
sudo apt install octave-mplapack-interop
```

Run installed-package smoke:
- Octave version;
- package discovery/load;
- mpbits;
- real arithmetic;
- real solve;
- complex arithmetic;
- eig;
- svd;
- small Grcar residual;
- serialization;
- deterministic RNG;
- help/manual.

Audit:
- `ldd`;
- `dpkg -L`;
- `apt-cache policy`;
- no `/usr/local`;
- no `$HOME` dependency;
- no bad RPATH.

Remove/reinstall and rerun smoke.

Conclusion:

```text
U02 PASS — UBUNTU 26.04 STAGING PPA VALIDATED
```

---

# 21. WNPP / ITP — D00

Check WNPP again immediately before filing.

If no active package/ITP exists, prepare/file ITP bugs for:

```text
gmpfrxx-mkii
mplapack
octave-mplapack-interop
```

Use current Debian procedure (`reportbug wnpp` or equivalent).

Each ITP must include:
- package name;
- description;
- upstream URL;
- source URL;
- license;
- reason/usefulness;
- dependency relation;
- proposed maintenance arrangement.

Record actual bug numbers.

If BTS/reportbug email configuration is unavailable:
- create ready-to-send ITP text in `release/debian/itp/`;
- stop at the exact mail credential gate;
- never fabricate bug numbers.

Conclusion:

```text
D00 PASS — THREE ITP BUGS FILED
```

---

# 22. Team contact

After packaging quality is strong:

For `gmpfrxx-mkii` and `mplapack`, contact Debian Science.

For `octave-mplapack-interop`, contact the Debian Octave Group and optionally Debian Science.

Prepare concise messages with:
- release identity;
- ITP;
- packaging VCS;
- sbuild/lintian/autopkgtest status;
- PPA evidence;
- maintenance intent;
- request for team-maintenance/sponsor guidance.

Do not claim team membership before confirmation.

Store drafts in:

```text
release/debian/team-contact/
```

---

# 23. Salsa / mentors publication — D01

Use relevant team Salsa namespace only after team agreement.

Otherwise use personal Salsa temporarily.

Prepare git-buildpackage-compatible repos and Salsa CI.

For non-DD sponsorship, upload signed source packages to `mentors.debian.net` with `dput`.

Use final Debian versions:

```text
1.4.1-1
3.0.1-1
0.5.0-1
```

unless the packaging audit requires a different mapping.

Do not use PPA suffixes in Debian uploads.

Record:
- VCS URLs;
- mentors URLs;
- `.dsc` hashes;
- `.changes` hashes;
- public GPG fingerprint.

If credentials are unavailable, stop at the exact external gate with all artifacts ready.

Conclusion:

```text
D01 PASS — DEBIAN SOURCE PACKAGES PUBLISHED FOR SPONSORSHIP
```

---

# 24. RFS — D02

File RFS bugs against `sponsorship-requests` following current mentors guidance.

Use `[ITP]` in new-package RFS subjects.

Include:
- ITP bug;
- mentors URL/dget command;
- Salsa VCS;
- build/test/lintian/autopkgtest status;
- PPA staging evidence;
- maintenance/team status;
- dependency chain.

Request sponsorship in dependency order:

```text
gmpfrxx-mkii
  ↓
mplapack
  ↓
octave-mplapack-interop
```

Record actual RFS bug numbers.

Do not claim sponsorship acceptance before a sponsor responds.

Conclusion:

```text
D02 PASS — DEBIAN RFS SUBMISSIONS OPEN
```

---

# 25. NEW / official acceptance boundary

New source/binary packages need sponsor/DD upload and NEW review.

The controller must never claim:
- "official Debian package";
- "accepted into Debian";
- "NEW passed";

without actual archive/tracker evidence.

For a normal non-DD route, successful completion of this controller is:

```text
ITP filed
public VCS
mentors upload
RFS filed
sponsor/NEW pending
```

If real Debian upload rights are detected, follow current Developer's Reference; never assume rights.

---

# 26. Ubuntu official path

Long-term path:

```text
Debian unstable
    ↓
Ubuntu automatic sync during the normal sync window
```

when there is no Ubuntu delta and package/version is eligible.

The staging PPA is not the final official Ubuntu package.

Ensure PPA versions sort below Debian/Ubuntu archive versions.

Create:

```text
release/debian/UBUNTU-SYNC.md
```

---

# 27. Packaging quality details

Before public submission verify:
- package descriptions are factual and concise;
- `debian/watch` works with `uscan --report`;
- Debian build flags/hardening are preserved;
- no network access during build/test;
- no vendored system libraries are silently used;
- no root required for ordinary package use;
- package removal/purge/reinstall works;
- Octave tests use isolated HOME/package DB;
- docs/examples are installed sensibly;
- every lintian override is justified.

Initial Debian changelogs should normally be:

```text
gmpfrxx-mkii (1.4.1-1) unstable; urgency=medium
mplapack (3.0.1-1) unstable; urgency=medium
octave-mplapack-interop (0.5.0-1) unstable; urgency=medium
```

Add `Closes: #...` only after real ITP numbers exist.

---

# 28. Status and resume safety

Maintain:

```text
release/debian/STATUS.md
release/debian/QA.md
release/debian/DEBIAN-STATUS.md
```

`QA.md` should track:

```text
source build
sbuild sid amd64
lintian
autopkgtest
piuparts
reprotest
license
symbols/shlibs
multiarch
PPA resolute build
PPA apt install
ITP
Salsa
mentors
RFS
NEW
sid
Ubuntu sync
```

Use only:

```text
PASS
FAIL
PENDING
N/A
BLOCKED
```

The controller must be resumable.

Never:
- re-upload the same PPA version;
- duplicate an ITP;
- duplicate an RFS;
- recreate existing Salsa repos blindly.

---

# 29. External-action blockers

If an external account/credential is missing, stop with a precise message.

Examples:

```text
BLOCKED — LAUNCHPAD STAGING PPA NOT AVAILABLE

Artifacts ready:
...

Required user action:
...

Resume from:
U01
```

or:

```text
BLOCKED — MENTORS SIGNING KEY NOT REGISTERED
```

Do not ask vague questions.

Provide exact next commands/actions.

---

# 30. Final report

Produce:

```text
# RELDEB00 RESULT

## Result
PASS / PARTIAL / BLOCKED / FAIL

## Upstream release provenance
gmpfrxx_mkII:
  version:
  tag:
  commit:
  tarball:
  SHA256:

MPLAPACK:
  version:
  tag:
  commit:
  tarball:
  SHA256:

mplapack-interop:
  version:
  tag:
  commit:
  tarball:
  SHA256:

## Package-name audit
gmpfrxx-mkii:
mplapack:
octave-mplapack-interop:
WNPP:
Debian collisions:
mentors collisions:

## Team routing
gmpfrxx:
mplapack:
octave interop:
Debian Science:
Debian Octave Group:

## Debian binary package architecture
gmpfrxx:
MPLAPACK:
octave interop:
SONAMEs:
Multi-Arch:
symbols/shlibs:

## Licensing
DEP-5:
bundled dependencies:
repack:
NEW concerns:

## Local Debian QA
sbuild:
lintian:
autopkgtest:
piuparts:
reprotest:
local apt stack:
runtime loader:
lifecycle:

## Ubuntu staging PPA
Target:
PPA:
gmpfrxx:
MPLAPACK:
interop:
architectures:
apt install:
smoke:
remove/reinstall:
URLs:

## Debian submission

### gmpfrxx-mkii
ITP:
Salsa:
mentors:
RFS:
sponsor:
NEW:
sid:

### mplapack
ITP:
Salsa:
mentors:
RFS:
sponsor:
NEW:
sid:

### octave-mplapack-interop
ITP:
Salsa:
mentors:
RFS:
sponsor:
NEW:
sid:

## Ubuntu official path
PPA version sorting:
Debian sync eligible:
Ubuntu sync:

## External blockers
...

## Final state
PPA-STAGING-VALIDATED:
DEBIAN-PACKAGING-READY:
DEBIAN-ITP-FILED:
DEBIAN-MENTORS-PUBLISHED:
DEBIAN-RFS-FILED:
DEBIAN-OFFICIAL-ACCEPTED:
UBUNTU-OFFICIAL-SYNCED:

## Next
If RFS is filed:
respond to sponsor/NEW feedback; do not duplicate submissions.

If accepted into Debian:
monitor buildd/autopkgtest/tracker and Ubuntu sync.

Do not begin unrelated numerical feature work automatically.
```

---

# 31. Success definitions

Full controller PASS:

```text
all three Debian source packages pass local QA
Ubuntu 26.04 staging PPA passes apt-install QA
ITPs filed
public packaging VCS exists
source packages available to sponsors
RFS bugs filed
```

Report:

```text
RELDEB00 PASS — PPA VALIDATED AND DEBIAN SUBMISSION OPEN
```

This does not mean NEW acceptance.

If credentials prevent public actions after local work:

```text
RELDEB00 PARTIAL — PUBLIC SUBMISSION ARTIFACTS READY
```

Only report:

```text
DEBIAN-OFFICIAL-ACCEPTED: YES
```

after archive evidence exists.

Only report:

```text
UBUNTU-OFFICIAL-SYNCED: YES
```

after Ubuntu archive evidence exists.

---

# 32. Stop

After the final report:

```text
STOP
```

Do not:
- start T15+ feature work;
- create unrelated PPAs;
- backport Octave to Ubuntu 24.04/25.10;
- duplicate Debian bugs/uploads;
- bypass sponsor/team review.
