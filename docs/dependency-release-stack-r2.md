# D04R1 dependency release stack

This repository-only manifest records the local `mplapack-interop` 0.5.1
maintenance release. It is excluded from the source archive because it contains
archive checksums and local filesystem paths. The published 0.5.0
handoff in [`dependency-release-stack-r1.md`](dependency-release-stack-r1.md)
remains immutable.

## Canonical release table

| Layer | Repository | Version | Source identity | Archive | SHA256 | Size | Depends on |
|---|---|---:|---|---|---|---:|---|
| gmpfrxx_mkII | `github.com/nakatamaho/gmpfrxx_mkII` | 1.5.0 | `8b5728474d8be0d85d5a6de0870b9d0807f42ec1` / `v1.5.0` | `gmpfrxx_mkII.1.5.0.tar.xz` | `dad1378ee62354a3c5fe8d68c3abcc3766ada00d1f5ffe2edf6c4d08d5f790a9` | 15174480 | GMP, MPFR, MPC |
| MPLAPACK | `github.com/nakatamaho/mplapack` | 3.0.1 | `953d7a4916554546937a753a30b0619691072841` / `v3.0.1` | `mplapack-3.0.1.tar.xz` | `47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa` | 85720132 | gmpfrxx 1.5.0; GMP, MPFR, MPC |
| octave-mplapack (`mplapack-interop`) | local checkout of `github.com/nakatamaho/octave-mplapack` | 0.5.1 | local release commit and annotated tag `v0.5.1` recorded in `D04R1-report.md` | `mplapack-interop-0.5.1.tar.gz` | `6079487fff60b3480eb567d5fdcc5afb7133f3489a0ebef1090cbbdc2a86346f` | 819207 | MPLAPACK 3.0.1; gmpfrxx 1.5.0; GMP, MPFR, MPC; Octave |

The local source archive was built reproducibly with `SOURCE_DATE_EPOCH=0` by
`tools/build-package.sh`. The archive has one top-level directory,
`mplapack-interop-0.5.1/`, and excludes this repository-only manifest, the
D04/D04R1 handoff goals, and the local installer helper.

## Dependency graph and compatibility policy

```text
mplapack-interop 0.5.1
    requires
MPLAPACK 3.0.1 / mplapack_mpfr
    uses
 gmpfrxx_mkII 1.5.0 for MPFR/MPC wrapper operations
    requires
GMP / MPFR / MPC
```

Ubuntu's `libmpc-dev` package does not provide `mpc.pc` in the tested
installation. The upstream MPLAPACK `.pc` files therefore remain unchanged in
the source archive, while the local installer normalizes the installed files
by clearing the unresolved `Requires:` entries and making
`-lmpc -lmpfr -lgmp` explicit in `Libs:`. No fake `mpc.pc` is installed.

The complex `log2` bridge calls gmpfrxx `mpfrxx::log2` on an MPC wrapper. It
never names the direct `mpc_log2` symbol. Real `log2` remains an MPFR call.
The operation preserves the source operation precision and the native MPFR/MPC
principal-branch semantics; no builtin binary64 fallback is used.

## QA evidence

The clean installer was run with the exact archives above in isolated
locations:

```text
prefix: /tmp/d04r1-final-prefix
log:    /tmp/d04r1-final-installer.log
```

The evidence includes gmpfrxx CTest `190/190`, the installed
`mplapack/mplapack_mpfr_precision.h`, `pkg-config --cflags --libs
mplapack_mpfr`, the gmpfrxx MPC precision probe, package installation, the
real/complex installer smoke, and a direct complex `log2` smoke. The installed
Octave module contains no unresolved `mpc_log2` symbol. The complete
92-task runnable-documentation/example-and-help smoke wall then passed under
GNU Parallel `--jobs 32` in 737 seconds (12 minutes 17 seconds); the detailed
scope and timing are recorded in
[`reports/D04R1-doc-examples-parallel-run.md`](../reports/D04R1-doc-examples-parallel-run.md).

## Release boundaries

The published `v0.5.0` tag and archive are not modified. The 0.5.1 source
archive and annotated tag `v0.5.1` are local only; there is no GitHub push or
release asset. Debian packaging, Launchpad/PPA upload, and Octave registry
submission remain separate follow-up work.
