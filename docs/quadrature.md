# Arbitrary-precision quadrature

`integral` and `quadgk` accept real MP endpoints and invoke a scalar callback
with MP real arguments.  A callback may return a real or complex MP scalar;
builtin double or array-valued results are rejected at the boundary.

The implementation is adaptive tanh-sinh (double-exponential) quadrature,
using the Takahasi–Mori map

```text
x = tanh((pi/2) sinh(t))
```

and its MP derivative as the quadrature weight.  `pi`, nodes, weights,
interval transformations, and the successive-level error estimate are all
formed as MP values.  The method avoids evaluating the callback at finite
interval endpoints, which covers ordinary algebraic/logarithmic endpoint
singularities such as `1/sqrt(x)` and `log(x)`.  Finite, semi-infinite, and
two-sided infinite intervals are supported.  Finite `Waypoints`, `AbsTol`,
and `RelTol` are supported in a scalar options struct or name/value form.

`ArrayValued` is explicitly unsupported until an MP shape-preserving reduction
contract is defined.  The public `quadgk` name is retained for compatibility,
while its backend is the more endpoint-robust double-exponential rule rather
than a binary64 Gauss–Kronrod table.
