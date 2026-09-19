# P04 `octave-mplapack-interop` packaging workspace

Status: **PENDING**.

Input archive: `mplapack-interop-0.5.0.tar.gz` with SHA256
`3c4e992516deb1266918c1c5bf6542cc9e1b7f301aeeb1f354dd64f2558f9e04`.

The Octave package name is `mplapack-interop`, minimum Octave is 11.1.0, and
the native `.oct` bridge must build against installed MPLAPACK pkg-config
metadata rather than a private prefix. P04 depends on completed P02/P03
packages and their Debian QA.
