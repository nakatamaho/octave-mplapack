# Binary redistribution license inventory

D01R1 records source and runtime license facts for future binary work. This
is not legal advice and does not perform the package-specific legal review
owned by B01–B05/PPA milestones.

| Component | Source/license fact | Planned handling |
|---|---|---|
| `mplapack-interop` | BSD 2-Clause (`COPYING`, `LICENSE`) | Include license and notices in every artifact |
| MPLAPACK | 2-clause BSD-style terms plus original LAPACK/BLAS notices | Include `COPYING` and all required upstream notices |
| gmpfrxx_mkII | BSD 2-Clause | Include exact source/license correspondence |
| GMP | dual GPL-2+ or LGPL-3+ terms stated by the release headers | Final bundling review and corresponding notices required |
| MPFR | LGPL-3+ terms stated by the release headers | Final bundling review and corresponding notices required |
| MPC | LGPL-3+ terms stated by the release headers | Final bundling review and corresponding notices required |
| libstdc++/libgcc or libc++ | toolchain/platform runtime terms | B-target toolchain review; do not assume one universal closure |
| Octave/system C libraries | host/platform dependencies | Do not bundle Octave or base system C libraries in this package |

## Corresponding source

Each binary manifest points to the exact corresponding source release by:

```text
component name
version
repository URL
commit/tag
source archive filename
archive SHA256
```

The package artifact contains the project licenses and dependency notices that
the final B-target review approves. A future binary release must not replace
these with a generic “built from source” statement.

## Bundle boundary

The architecture permits package-local bundling of the MPLAPACK MPFR runtime,
MPC/MPFR/GMP runtime closure, and any gmpfrxx provider that is actually
required. The final target milestone decides exact files and license text. It
does not permit global installation or an unrecorded system fallback.
