# D01R1 status — `mplapack-interop` identity and binary architecture

Status: **IN PROGRESS**

This worktree is the D01R1 release-engineering branch.  It is based on the
D00 handoff commit `675231d53ebdbd8a03f0d11cfeab999e21c4a212`; the historical
D00 `mplapack` 0.2.0 identity and archive remain unchanged.

## Completed

### G-D01R1-NAME-SYNTAX — PASS (preflight)

GNU Octave `11.1.0` accepted an isolated throwaway package whose DESCRIPTION
contained:

```text
Name: mplapack-interop
Version: 0.0.1
```

The isolated preflight successfully ran `pkg install`, `pkg list`,
`pkg describe mplapack-interop`, `pkg load mplapack-interop`, a package
function, `pkg unload mplapack-interop`, and `pkg uninstall mplapack-interop`.
The temporary package database was empty afterwards.

### Rename implementation and examples — IN PROGRESS

The production metadata now uses `Name: mplapack-interop` and temporary
`Version: 0.2.1-dev`. Current `pkg load`/lifecycle checks in
`tools/local-ci.sh`, README/NEWS/INDEX, and current compatibility/help text use
the new identity. The historical D00 documents retain `mplapack` deliberately.

The following examples are implemented and tested against the current QA
stack:

```text
examples/05_hilbert_inverse.m
examples/interop_hilbert_inverse_mpfr.cpp
docs/mplapack-interop-hilbert.md
```

The Octave example uses `H \ I` at 1024 bits; the C++ example uses public
MPLAPACK MPFR headers and `Rgetrf`/`Rgetri`/`Rgemm` under
`MplapackMpfrPrecisionScope`. Both examples avoid a binary64 Hilbert
construction. The Octave example restores the caller's ambient `mpbits`
setting with `unwind_protect`.

The current QA-stack local wall completed successfully after this fix:
M00–M23, C00–C12, mandatory C11L, lifecycle tests, clean rebuild/retest, and
ASan/UBSan-enabled native tests all passed. This evidence still awaits
repetition against an MPLAPACK installation rebuilt from the current
macOS-fixed 3.0.1 RC.

### G-D01R1-BINARY-ARCH — design recorded

`docs/binary-distribution.md` defines the source/binary boundary, Octave API
key, package-local runtime layout, Linux `$ORIGIN`/`DT_RUNPATH`, macOS
`@loader_path`/`@rpath`, Windows DLL strategy, manifest, target naming matrix,
and license handoff. `pkg build` was audited on Octave 11.1.0 and produced an
API-qualified Linux archive with `src/__mplapack_core__.oct`. Production B01–B05
builds remain intentionally unstarted.

## Pending

The production package metadata and documentation rename is not yet frozen.
The final 0.2.1 dependency candidates, complete numerical regression, source
archive reproducibility, tags, and binary-distribution architecture audit are
pending.

No Debian package, PPA change, registry submission, or production binary
distribution build has been started.

## Current dependency evidence

The latest MPLAPACK 3.0.1 RC supplied for QA is commit
`76cbb400aed5e8be7e9f2cfa02f27a95a5e564e4`, archive SHA256
`0739d73de62e9918874d80fe4d119cc60605f3772036455b65b9f24eb52f7e0f`.
This supersedes the earlier pre-macOS-fix candidate for D01R1 QA; it is not
claimed as a final public release until the required release gates pass.
