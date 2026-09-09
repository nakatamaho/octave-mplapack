# S07 report — graphics boundary bridge

## Result

```text
S07 PASS — GRAPHICS BOUNDARY BRIDGE CLOSED
```

Implementation and documentation commit:
`384987bb6dbddd0758915debcda064acd15caaee`.

## Public API

The `mp` class now provides graphics-boundary wrappers for:

```text
plot
semilogx
semilogy
loglog
scatter
stem
stairs
```

The private `mp_graphics_args` helper converts only `mp` data to builtin
double immediately before the host graphics routine is called. Axes handles,
style strings, property names, non-`mp` property values, ordinary builtin
numeric values, and other non-`mp` arguments are preserved. The wrappers
therefore cover single series, multiple series, axes-handle-first calls,
property/value pairs, and mixed double/`mp` arguments.

Single complex-vector plotting follows Octave's builtin convention after the
final boundary conversion: the real component is used for x and the
imaginary component for y. The conversion is private to graphics wrappers;
no numerical operation routes through it or through builtin binary64
arithmetic.

## Required examples and limitations

The S07 test exercises all seven line-graphics families, the axes-handle and
mixed-argument forms, style/property arguments, and the complex-vector case.
It also exercises the required Grcar example and balance/nobalance overlay:

```octave
A = mp (gallery ("grcar", 32));
e = eig (A);

plot (real (e), imag (e), "o");
axis equal;
grid on;
```

```octave
eb = eig (A, "balance");
en = eig (A, "nobalance");
plot (real (eb), imag (eb), "o");
hold on;
plot (real (en), imag (en), "x");
```

Graphics are inherently a builtin-double boundary. Extremely small or large
`mp` values can consequently become zero or infinity when plotted. The
documented mitigation is to transform in `mp` first, for example:

```octave
plot (bits, double (log10 (residual_mp)))
```

Surface and matrix graphics beyond this line-graphics bridge remain S08
closure candidates. No numerical fallback was added.

## Gates

```text
G-S07-PLOT: PASS
G-S07-SEMILOG: PASS
G-S07-SCATTER: PASS
G-S07-STEM-STAIRS: PASS
G-S07-MIXED-ARGS: PASS
G-S07-HANDLE-ARGS: PASS
G-S07-COMPLEX: PASS
G-S07-GRCAR: PASS
G-S07-GRAPHICS-BOUNDARY-DOC: PASS
G-S07-NO-NUMERICAL-FALLBACK: PASS
G-S07-REGRESSION: PASS
```

The dedicated `test/script-compat/s07.tst` gate passed all four tests. The
post-milestone `tools/local-ci.sh` wall passed M00–M23, C00–C12 including
mandatory C11L, N00–N08, S00–S07, native ASan/UBSan/LSan gates, clean rebuild
#2, deterministic source-package generation, and isolated install,
unload/uninstall, and reinstall QA against the frozen dependencies. The
gnuplot toolkit emitted its known host warning; all graphics assertions
passed.

The active package metadata remains `0.4.0-dev`; immutable `v0.3.1` and the
frozen gmpfrxx/MPLAPACK dependencies remain unchanged.

## Next milestone

Proceed automatically to S08 — Ordinary script compatibility closure.
