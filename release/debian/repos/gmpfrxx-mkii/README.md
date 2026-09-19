# P02 `gmpfrxx-mkii` packaging workspace

Status: **PENDING**.

Input archive: `gmpfrxx_mkII.1.4.1.tar.xz` with SHA256
`395b9c4bd5819cf0f61758cee5f7eb400e25e2959b51a75d40a922ed41d711c4`.

Before creating `debian/`, resolve the unversioned
`libgmpxx_mkII_default_context_provider.so` ABI/SONAME decision recorded in
`../../PACKAGING-AUDIT.md` and `../../ABI-AND-MULTIARCH.md`. A package must not
be marked ready from this placeholder.
