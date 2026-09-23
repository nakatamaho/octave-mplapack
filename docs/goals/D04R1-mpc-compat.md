# D04R1 — 0.5.1 MPC/pkg-config compatibility maintenance release

## Mission

Prepare and publish the `mplapack-interop 0.5.1` maintenance release by
merging the release work into `main`, creating an annotated tag and GitHub
Release asset, without modifying the immutable `v0.5.0` tag/archive or any
upstream MPLAPACK source. The maintenance release closes the Ubuntu 26.04
local-installer failure caused by missing `mpc.pc` metadata and removes the
direct complex `mpc_log2` symbol dependency from the Octave bridge. Debian/PPA
packaging and uploads remain deferred.

## Accepted inputs

```text
MPLAPACK:       3.0.1 official release archive
MPLAPACK SHA256: 47ebb653b21f0c62e8144c1e515e94d76965d9d0d4b7ba216b034d778570cbaa
gmpfrxx:        1.5.0 official release archive
gmpfrxx SHA256: dad1378ee62354a3c5fe8d68c3abcc3766ada00d1f5ffe2edf6c4d08d5f790a9
```

The Ubuntu downstream `.pc` correction is applied only after MPLAPACK
installation. The upstream MPLAPACK archive remains untouched.

## Scope

- select gmpfrxx_mkII 1.5.0 for the maintenance installer by default;
- use `mpfrxx::log2` for complex `log2` through the gmpfrxx MPC wrapper;
- probe the gmpfrxx MPC log2 precision contract in the dependency test;
- fail early when MPLAPACK `pkg-config --cflags/--libs` metadata is unusable;
- normalize installed MPLAPACK `.pc` files for Ubuntu's missing `mpc.pc`;
- update user, developer, backend, and release metadata for 0.5.1;
- build a reproducible 0.5.1 source archive, update `NEWS.md`, merge to
  `main`, and publish the archive as a GitHub Release asset under annotated
  tag `v0.5.1`.

## Explicit non-goals

- no changes to upstream MPLAPACK or gmpfrxx source;
- no modification or replacement of the published `v0.5.0` tag/archive;
- no Debian/PPA package upload, Launchpad operation, or Octave registry
  submission;
- no new public numerical API or binary64 fallback.

## Gates

1. focused format/tree/shell checks;
2. 0.5.1 source archive identity and reproducibility checks;
3. clean gmpfrxx 1.5.0 + MPLAPACK 3.0.1 + package installer build;
4. `pkg-config`, installed-header, dependency-probe, complex-log2, and
   unresolved-symbol evidence;
5. documentation/example consistency checks;
6. `main` contains the release, annotated tag `v0.5.1` and GitHub Release
   asset are published, and the handoff report records evidence; Debian/PPA
   and registry uploads remain NOT RUN.
