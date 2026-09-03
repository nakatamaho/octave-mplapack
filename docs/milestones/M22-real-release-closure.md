# Goal

Close the documented real-only v0.1 API and prepare reproducible package and
PPA handoff metadata without adding a numerical feature.

# Scope

API inventory, help and error audits, compatibility firewall, examples,
developer workflow, dependency feature detection, package/archive QA, and
release/PPA documentation.

# Non-goals

No new BLAS/LAPACK algorithm, complex support, sparse support, public `det`,
`inv`, `rank`, `cond`, `norm`, `eig`, or `svd`, and no release tag or upload.

# Design constraints

The accepted M00-M21 real paths remain unchanged. Installed dependencies are
discovered with `pkg-config`; unsupported operations must not fall back to
binary64. M22 ends with a root-level `m22-report.md`.

# Implementation tasks

Publish the v0.1 API/limitations and compatibility pages, audit wrappers and
native commands, add examples and a developer entrypoint, add an MPLAPACK
interface probe, and write the PPA/release handoff checklist.

# Required tests

Run the dependency probe, release-closure smoke/firewall tests, clean build and
package lifecycle, installed help/examples, full local CI, sanitizers, and the
complete M00-M21 regression suite.

# Gate

M22 passes only when all G22 API, documentation, errors, package, dependency,
developer UX, PPA handoff, metadata, firewall, and regression gates pass.

# Expected commit

Use reviewable commits for dependency audit, API/docs, examples/QA, and the
final report. Do not begin M23 or complex implementation.
