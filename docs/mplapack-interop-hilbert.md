# Hilbert inverse: `mplapack-interop`

This example shows a high-precision Hilbert inverse at the Octave package
boundary:

GNU Octave uses the `mplapack-interop` package and its public `mp` class.

Hilbert matrices are ill-conditioned, so constructing them in binary64 first
would hide the precision that the example is intended to demonstrate. The
example therefore forms `1/(i+j-1)` directly at the selected MPFR precision.

## Octave

```octave
pkg load mplapack-interop
previous_bits = mpbits ();
unwind_protect
  mpbits (1024);
  n = 6;
  H = mp (zeros (n, n));
  for j = 1:n
    for i = 1:n
      H(i, j) = mp ("1") ./ mp (sprintf ("%d", i + j - 1));
    endfor
  endfor

  I = mp (eye (n));
  Hinv = H \ I;
  residual = H * Hinv - I;
  disp (Hinv);
  disp (residual);
  fprintf ("binary64 residual infinity norm: %.3e\n",
           norm (double (residual), inf));
unwind_protect_cleanup
  mpbits (previous_bits);
end_unwind_protect
```

`H \ I` is intentional. The package does not provide `inv(mp)`; solving
against the identity uses the public MPLAPACK-backed left-division path and
supports multiple right-hand sides. `hilb(n)` is not used because its builtin
result is a binary64 matrix. `double` appears only in the final diagnostic,
after the high-precision calculation is complete. The wrapper restores the
caller's ambient MPFR precision even if the calculation raises an error.

The runnable file is
[`../examples/05_hilbert_inverse.m`](../examples/05_hilbert_inverse.m).

## MPLAPACK release QA

The installed MPLAPACK public-header consumer boundary, including
`MplapackMpfrPrecisionScope` and the MPFR backend routines, is validated by
the separate MPLAPACK release QA. The C++ consumer source is intentionally
not shipped in this Octave package's examples.
