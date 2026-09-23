# Staging PPA submission manifest

Status: **PREPARED / NOT UPLOADED**.

The Octave team's Debian source/binary name direction is now
`octave-mplapack`; the 0.5.0 PPA version example and local P04 draft below
still use the earlier `octave-mplapack-interop` candidate. Reconcile the
source-package name and rerun package QA before treating this manifest as an
upload candidate. No PPA upload is authorized by this draft manifest.

## Target

```text
Ubuntu suite: 26.04 (Resolute)
Architecture first: amd64
PPA owner/name: not configured; do not invent
```

## Proposed dependency-order versions

These are examples only and must be checked against the actual Launchpad PPA
before signing or upload. Never reuse an already uploaded version.

```text
gmpfrxx-mkii:             1.4.1-1~ppa1~ubuntu26.04.1
mplapack:                 3.0.1-1~ppa1~ubuntu26.04.1
octave-mplapack-interop:  0.5.0-1~ppa1~ubuntu26.04.1
mpclib3:                  1.4.1-1~ppa1~ubuntu26.04.1
```

## Upstream inputs

```text
gmpfrxx_mkII.1.4.1.tar.xz
  SHA256 395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4
mplapack-3.0.1.tar.xz
  SHA256 47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa
mplapack-interop-0.5.0.tar.gz
  SHA256 3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04
mpc-1.4.1.tar.xz
  SHA256 91204cd32f164bd3b7c992d4a6a8ce6519511aadab30f78b6982d0bf8d73e931
```

## Upload preflight

Required before U01:

```text
Launchpad account and staging PPA
upload permission
registered GPG key
dput/dput-ng configuration
signed source packages
P02/P03/P04 binary and Debian QA PASS
```

Upload order is strictly:

```text
mpclib3 -> gmpfrxx-mkii -> mplapack -> octave-mplapack-interop
```

No Launchpad URL, build ID, PPA publication, or apt-install result exists yet.
