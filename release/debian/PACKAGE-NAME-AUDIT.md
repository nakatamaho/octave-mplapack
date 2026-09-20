# P00 package-name and availability audit

Retrieval date: 2026-09-20.

The following searches were performed against Debian package search and the
Debian tracker/BTS source-package reports:

```text
gmpfrxx
gmpfrxx-mkii
mplapack
octave-mplapack
octave-mplapack-interop
```

No result was returned by `packages.debian.org` name search for these names.
The tracker/BTS source-package reports returned “no maintainer / package no
longer exists (or never existed)” for `gmpfrxx-mkii`, `mplapack`, and
`octave-mplapack-interop`. No active collision was found in the local audit.

The dependency audit found an important exception: Ubuntu 26.04 already
ships source package `mpclib3` and binary packages `libmpc3`/`libmpc-dev` at
version 1.3.1-3, but that release does not export `mpc_log2`. The released
interop bridge requires MPC 1.4.0 or newer. The PPA must therefore carry a
compatible higher-version `mpclib3` build; this is not a new project source
package name or an MPLAPACK fork.

| Candidate | Existing Debian source/binary | WNPP/ITP evidence | Mentors/Salsa collision | Status |
|---|---|---|---|---|
| `gmpfrxx-mkii` | none found | none found | none found | AVAILABLE, proposal |
| `mplapack` | none found | none found | none found | AVAILABLE, proposal |
| `octave-mplapack-interop` | none found | none found | none found | AVAILABLE, proposal |
| `mpclib3` / `libmpc3` | Ubuntu 26.04 1.3.1-3 | existing Ubuntu package | existing package | PPA higher-version prerequisite |

This is an availability audit, not an ITP filing. Before public filing, repeat
the search and check current WNPP/mentors/Salsa state to avoid a race.

## P00 conclusion

`P00 PASS — PACKAGE NAMES AVAILABLE` (local audit). Team routing and public
submission remain pending; see `TEAM-ROUTING.md`.
