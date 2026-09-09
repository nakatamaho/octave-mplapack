# D01R1 — Binary architecture handoff

D01R1 freezes the architecture for future `mplapack-interop` binary packages;
it does not start B01–B05 production builds, Debian/PPA packaging, or Octave
Packages registration.

The package identity is `mplapack-interop`, the repository remains
`nakatamaho/octave-mplapack`, and the public numeric API remains `mp`,
`mpbits`, and `mpdigits`.

The ABI key is the complete Octave version/API, OS, architecture, and compiler
toolchain. The audited host is GNU Octave 11.1.0, API `api-v61`,
`x86_64-pc-linux-gnu`, GNU C++ 15.2.0. Binary archives use package-local
runtime libraries and relative loader identities (`$ORIGIN` on ELF,
`@loader_path`/`@rpath` on macOS, and package-local DLL search on Windows).

The exact runtime closure, license inventory, manifest fields, and B01–B05
target matrix are maintained in:

- [`docs/binary-distribution.md`](../binary-distribution.md)
- [`docs/binary-redistribution-licenses.md`](../binary-redistribution-licenses.md)
- [`docs/dependency-release-stack-r1.md`](../dependency-release-stack-r1.md)

The current `pkg build` audit is a design probe only. Production artifacts
remain the next milestones.
