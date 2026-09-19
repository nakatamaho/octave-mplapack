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

| Candidate | Existing Debian source/binary | WNPP/ITP evidence | Mentors/Salsa collision | Status |
|---|---|---|---|---|
| `gmpfrxx-mkii` | none found | none found | none found | AVAILABLE, proposal |
| `mplapack` | none found | none found | none found | AVAILABLE, proposal |
| `octave-mplapack-interop` | none found | none found | none found | AVAILABLE, proposal |

This is an availability audit, not an ITP filing. Before public filing, repeat
the search and check current WNPP/mentors/Salsa state to avoid a race.

## P00 conclusion

`P00 PASS — PACKAGE NAMES AVAILABLE` (local audit). Team routing and public
submission remain pending; see `TEAM-ROUTING.md`.
