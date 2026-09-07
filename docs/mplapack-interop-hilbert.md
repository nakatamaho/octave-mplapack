# Hilbert inverse: `mplapack-interop` and MPLAPACK

This example shows the same calculation at two public boundaries:

1. GNU Octave uses the `mplapack-interop` package and its public `mp` class.
2. An independent C++ program uses the installed MPLAPACK MPFR interface.

Hilbert matrices are ill-conditioned, so constructing them in binary64 first
would hide the precision that the example is intended to demonstrate. Both
examples therefore form `1/(i+j-1)` directly at the selected MPFR precision.

## Octave

```octave
pkg load mplapack-interop
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
```

`H \ I` is intentional. The package does not provide `inv(mp)`; solving
against the identity uses the public MPLAPACK-backed left-division path and
supports multiple right-hand sides. `hilb(n)` is not used because its builtin
result is a binary64 matrix. `double` appears only in the final diagnostic,
after the high-precision calculation is complete.

The runnable file is
[`../examples/05_hilbert_inverse.m`](../examples/05_hilbert_inverse.m).

## External MPLAPACK-interop C++

Build the companion consumer from an installed MPLAPACK 3.0.1 interface:

```sh
c++ -std=c++17 -O2 -o hilbert_inverse_mpfr \
  examples/interop_hilbert_inverse_mpfr.cpp \
  $(pkg-config --cflags --libs mplapack_mpfr)
./hilbert_inverse_mpfr
```

The program includes only these public headers:

```cpp
#include <mpblas_mpfr.h>
#include <mplapack_mpfr.h>
#include <mplapack_mpfr_precision.h>
```

It enters `MplapackMpfrPrecisionScope(1024)`, performs `Rgetrf` and `Rgetri`
on an operation-owned inverse buffer, and checks the result with MPFR
`Rgemm`. The aggregate headers `mpblas.h` and `mplapack.h` are intentionally
not included; they depend on internal `INTEGER`/`REAL` definitions and are
not part of the installed public development interface.

The runnable file is
[`../examples/interop_hilbert_inverse_mpfr.cpp`](../examples/interop_hilbert_inverse_mpfr.cpp).
