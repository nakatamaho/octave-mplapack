# Graphics boundary bridge

S07 provides class-specific wrappers for the common line graphics functions
`plot`, `semilogx`, `semilogy`, `loglog`, `scatter`, `stem`, and `stairs`.

The wrappers call a private helper that maps only `mp` values through the
public `double` conversion immediately before the host graphics call. Axes
handles, line-style strings, property/value pairs, and ordinary builtin
values are passed through unchanged. Multiple data series and mixed
double/`mp` arguments therefore retain the normal Octave calling convention.

This is the only S07 binary64 conversion. It is a visualization boundary, not
a numerical implementation path. Converting arbitrary-precision values to
graphics doubles can map very small values to zero and very large values to
infinity. Compute any range-sensitive transform first in `mp`, for example:

```octave
plot (bits, double (log10 (residual_mp)))
```

For a single complex vector, the wrapper passes a builtin complex vector to
Octave, which plots its real component against its imaginary component:

```octave
z = mp ([1 + 2i; 2 + 1i; 3 + 3i]);
plot (z, "o");
```

## Grcar eigenvalue example

```octave
A = mp (gallery ("grcar", 32));
e = eig (A);

plot (real (e), imag (e), "o");
axis equal;
grid on;
```

Balance and no-balance results can be overlaid through the same bridge:

```octave
eb = eig (A, "balance");
en = eig (A, "nobalance");
plot (real (eb), imag (eb), "o");
hold on;
plot (real (en), imag (en), "x");
```

S07 intentionally does not add wrappers for surface or matrix graphics. Those
forms remain S08 closure candidates until a clean argument architecture is
available.
