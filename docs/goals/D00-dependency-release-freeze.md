# D00 — Dependency Release Freeze

## Objective

Freeze the complete source stack for the first public real-plus-complex
`octave-mplapack` release:

```text
gmpfrxx_mkII 1.4.1 -> MPLAPACK 3.0.1 -> octave-mplapack 0.2.0
```

D00 is release engineering only. It does not add numerical routines, create
Debian packages, upload to Launchpad, modify `octave-mplapack-ppa`, register
the package with Octave Packages, or begin D01. A source-level change is
permitted only when it repairs a release-blocking defect already exposed by
the accepted C00–C12 contract.

## Accepted baseline

The historical real-only checkpoint is
`0bef79cddd3fdd70abafdf38bc1a4ab492652d33` and remains unchanged. The C12
tested heads are gmpfrxx `32a7fb797202cdf92312ed9d133f96fdbcda590a`, MPLAPACK
`a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`, and octave-mplapack
`36cd341a8c14ce2d0a6790b287e5f7a7b0846cd3`. The C12 result is
`COMPLEX GOAL PASS`, `REAL-COMPLEX-API-CLOSED`, and
`DEPENDENCY-FREEZE-READY`.

## Gating order

```text
D00-G gmpfrxx freeze
  -> D00-M MPLAPACK 3.0.1 freeze
  -> D00-O octave-mplapack 0.2.0 freeze
  -> D00-S frozen-stack rebuild and regression
  -> D00-R archive reproducibility
  -> D00-T release tags
  -> D00-H D01 handoff
```

Each layer must be independently installable from its source archive, and all
headers, pkg-config metadata, runtime libraries, SONAMEs, and source commits
must be traceable to the frozen stack. The one-operation/one-precision
MPFR/MPC contract remains mandatory: no builtin binary64 complex fallback,
no real-only-to-complex routing, and destructive backend calls receive
operation-owned copies.

## Required evidence

The gates cover clean scalar consumers, public precision-scope installation,
1024-bit and 2048-bit canaries, ambient/default precision and lifetime tests,
MPFR/MPC thread-scope probes, real M00–M23 regression, complex C00–C12
regression including C11L `Cgetrf`, compatibility firewall, ASan/UBSan/LSan,
package lifecycle, standalone archive builds, provenance, and reproducible
archives. Tags are created only after all gates pass and must point exactly to
the freeze commits.

The authoritative handoff is
[`docs/dependency-release-stack.md`](../dependency-release-stack.md); the
complete evidence is in [`reports/D00-report.md`](../../reports/D00-report.md)
and the running state is in
[`D00-dependency-release-freeze-status.md`](D00-dependency-release-freeze-status.md).

## Stop condition

After recording `D00 PASS — RELEASE STACK FROZEN` and `D01-READY`, stop. D01 is
a separate goal and must consume exactly the versions, commits, tags, source
archives, and SHA256 values recorded by D00.
