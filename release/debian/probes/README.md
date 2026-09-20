# Debian audit probes

These programs are test-only evidence for the Debian/PPA controller. They are
not installed, linked into `octave-mplapack`, or treated as public API.

## gmpfrxx provider ABI/TLS probe

`gmpfrxx-provider-abi.cpp` checks the released provider's ABI version and
structure size, the exported mode/token functions, per-thread precision
contexts, and reset behavior. Build it against an isolated gmpfrxx release
build and provider library:

```sh
c++ -std=c++17 -pthread \
  -DGMPXX_MKII_DEFAULT_CONTEXT_MODE=GMPXX_MKII_DEFAULT_CONTEXT_EXTERNAL_PROVIDER \
  -I"$GMPFRXX_SOURCE/include" -I"$GMPFRXX_BUILD/generated" \
  release/debian/probes/gmpfrxx-provider-abi.cpp \
  -L"$GMPFRXX_BUILD" \
  -Wl,-rpath,"$GMPFRXX_BUILD" \
  -lgmpxx_mkII_default_context_provider \
  -o /tmp/gmpfrxx-provider-abi
/tmp/gmpfrxx-provider-abi
```

The variables identify the selected release source/build directories; no
developer-specific path is part of the repository or package build.

The expected output is:

```text
gmpfrxx provider ABI/TLS PASS
```
