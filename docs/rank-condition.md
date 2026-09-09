# Dense arbitrary-precision rank and condition numbers

N03 adds `rank`, `cond`, and `rcond` for dense two-dimensional real and
complex `mp` values.

`rank(A)` obtains singular values through MPLAPACK `Rgesvd` or `Cgesvd`. Its
default threshold is

```text
max(size(A)) * sigma_max * Rlamch_mpfr("E")
```

where every term is evaluated at the one operation precision selected from
the stored operand (or the maximum precision of an explicit MPFR tolerance).
`rank(A,tol)` compares singular values against the supplied real tolerance;
the comparison is strict, as in Octave.

The default and 2-norm condition numbers use the largest and smallest MPFR
singular values. `cond(A,"fro")` uses the Frobenius singular-value identity

```text
sqrt(sum(sigma_i^2)) * sqrt(sum(1/sigma_i^2))
```

for square matrices. Singular matrices return MPFR `Inf` for the condition
number. `cond(A,1)`, `cond(A,Inf)`, and `rcond(A)` use operation-owned LU
copies and MPLAPACK `Rgecon` or `Cgecon`; they do not form an explicit
inverse. `rcond` is the 1-norm reciprocal estimate. The second output of
`det(A)` is the same 1-norm reciprocal estimate.

The 2-norm condition number is supported for rectangular matrices. The
1-norm, infinity-norm, and Frobenius condition forms, as well as `rcond`,
require square matrices. Empty square inputs return `cond=0` and `rcond=Inf`;
rank of an empty matrix is zero. Condition results are real MPFR `mp` values
for both real and complex inputs, and public inputs remain unchanged.
