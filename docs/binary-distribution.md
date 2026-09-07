# Binary-distribution architecture

D01R1 freezes the architecture and handoff contract for future prebuilt
Octave packages. It does not build or publish B01–B05 artifacts.

## Package boundary

The source package and a platform binary package are separate release
classes:

```text
source: mplapack-interop-0.2.1.tar.gz
binary: mplapack-interop-0.2.1-octave<api>-<os>-<arch>.tar.gz
```

The internal DESCRIPTION of both forms remains:

```text
Name: mplapack-interop
Version: 0.2.1
```

Normal users install a binary with `pkg install` and load it with
`pkg load mplapack-interop`; they do not need a compiler, `PKG_CONFIG_PATH`,
or a developer-specific library path.

## ABI key

The binary compatibility key is the tuple:

```text
Octave major/minor version + Octave API version + OS + architecture
```

The first audited host reports:

```text
Octave: 11.1.0
Octave API: api-v61
host: x86_64-pc-linux-gnu
mkoctfile: 11.1.0
compiler: GNU C++ 15.2.0
```

The package must not promise that an `.oct` built for another Octave API
version is compatible. Each binary artifact embeds this key in its filename
and manifest.

## Package layout

The planned installed layout is:

```text
mplapack-interop-0.2.1/
├── DESCRIPTION
├── COPYING
├── LICENSE
├── INDEX
├── inst/
├── src/__mplapack_core__.oct
├── runtime/                 # private native runtime closure
└── docs/binary-manifest.json
```

The exact `runtime/` contents are target-specific and are recorded in the
binary manifest. Runtime files remain inside the Octave package directory;
no binary package copies private libraries into `/usr/lib`, `/usr/local/lib`,
or another global directory. `pkg uninstall` therefore removes the package
and its private runtime together.

The current Octave 11.1 `pkg build` audit produced
`mplapack-interop-0.2.1-dev-x86_64-pc-linux-gnu-api-v61.tar.gz`, put the `.oct`
under `src/`, and preserved DESCRIPTION identity. It also showed that raw
`pkg build` archives whatever the build leaves in the source tree; the
release build must therefore run from a clean extraction and exclude QA
probes/build products before publication.

## Runtime closure

The audited native module has direct runtime references to:

```text
libmplapack_mpfr.so.3
libmpc.so.3
libmpfr.so.6
libgmp.so.10
libstdc++.so.6
libgcc_s.so.1
libc.so.6
```

`libmplapack_mpfr.so.3` is the MPLAPACK runtime SONAME. The gmpfrxx wrapper
is primarily header-only for the value types; any dynamically required
default-context provider is treated as an explicit manifest/runtime item,
not as an invisible developer dependency. Octave and the platform's base C
runtime are never bundled as part of this package.

## Loader strategies

### Linux

B01/B02 place private shared libraries beside the package's `.oct` or in the
declared `runtime/` subdirectory. The `.oct` and any bundled libraries use
relative ELF `DT_RUNPATH` entries based on `$ORIGIN` (for example,
`$ORIGIN/../runtime`) and are checked with `readelf -d`, `ldd`, and
`ldd -r`. No `LD_LIBRARY_PATH` is required at runtime. `DT_RPATH` and
`LD_PRELOAD` are not the architecture.

The current development proof was intentionally run with an isolated
`LD_LIBRARY_PATH` because the existing module has no relative runpath. That
is a bounded B01/B02 relocation step, not an accepted final binary artifact.

### macOS

B03/B04 use package-local `.dylib` files and install names based on
`@loader_path`/`@rpath`. `otool -L` and `install_name_tool` (where needed)
verify both direct and transitive closure. The final build also records
codesigning/notarization inputs if distribution policy requires them. No
`DYLD_LIBRARY_PATH` is required at runtime.

### Windows

B05 places the required MinGW-compatible DLL closure in the package-local
`runtime/` directory next to the `.oct` or in the documented DLL search
directory. The build verifies the exact Octave/MinGW C++ ABI and uses a
dependency inspection tool such as `objdump -p`/`ntldd`. No system-wide DLL
installation is performed.

## Manifest

Every binary artifact includes `docs/binary-manifest.json` (or the equivalent
package-preserved path) containing:

```text
package name/version
source commit and source archive SHA256
gmpfrxx version/tag/SHA256
MPLAPACK version/tag/SHA256
Octave version/API
OS/architecture/compiler/toolchain
runtime file list and SONAME/install-name/DLL identities
license and notices paths
build provenance
```

The manifest is data, not a replacement for the corresponding source archive.
It must identify the exact source URL and checksum from
`docs/dependency-release-stack-r1.md`.

## Naming matrix

| Target | Artifact pattern | Loader check |
|---|---|---|
| B01 Linux x86_64 | `mplapack-interop-0.2.1-octave11-linux-x86_64.tar.gz` | `$ORIGIN`/`DT_RUNPATH`, `readelf`, `ldd -r` |
| B02 Linux arm64 | `mplapack-interop-0.2.1-octave11-linux-aarch64.tar.gz` | `$ORIGIN`/`DT_RUNPATH`, target `readelf`, `ldd -r` |
| B03 macOS arm64 | `mplapack-interop-0.2.1-octave11-macos-arm64.tar.gz` | `@loader_path`/`@rpath`, `otool -L` |
| B04 macOS x86_64 | `mplapack-interop-0.2.1-octave11-macos-x86_64.tar.gz` | `@loader_path`/`@rpath`, `otool -L` |
| B05 Windows x86_64 | `mplapack-interop-0.2.1-octave11-windows-x86_64.tar.gz` | package-local DLL search, `objdump -p` |

The `octave11` label is shorthand for the audited Octave 11/API-v61 family;
the manifest remains authoritative and contains the full API key.
