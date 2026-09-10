# Advanced numerical compatibility

This document is the T00–T14 handoff for the arbitrary-precision numerical
surface of `mplapack-interop`. The tested runtime is GNU Octave 11.1.0 with
the installed MPLAPACK MPFR/MPC backend and gmpfrxx_mkII 1.4.1.

## Supported T-series surface

The following public calls are implemented for dense, two-dimensional `mp`
values and are covered by focused tests plus the required real-regression
wall:

```text
hess balance schur qz
pinv null orth rref kron
expm logm sqrtm
polyval polyvalm roots poly conv deconv polyder polyint compan
unique union intersect setdiff setxor ismember
gamma gammaln lgamma erf erfc
saveobj loadobj
plot3 scatter3 mesh surf contour3 meshc surfc waterfall
mprand mprandn mprandi mprng
interp1 pchip spline ppval mkpp unmkpp ppder ppint interp2
fzero fsolve integral quadgk fminbnd fminsearch
```

The repository-local difficult nonsymmetric eigensystem harness is documented
in `docs/nonsymmetric-eig-suite.md` and exercised by
`examples/13_nonsymmetric_eig_suite.m`. It is built only from the existing
public `mp`/`eig` API and does not add a new package-level call. The harness
covers Hadamard-similar, Frank, companion, and two Forsythe representations,
both balance modes, actual-output residuals, left/right conditioning, and
deterministic eigenvalue matching. Native rows are explicit rounded-input
controls; MP rows retain the one-operation/one-precision contract.

The T-series preserves the one-operation/one-precision MPFR/MPC contract,
uses operation-owned copies for destructive backend calls, and never silently
routes numerical work through builtin binary64 or routes a real-only call
through a complex kernel.

## Boundary and deferred surface

The public type remains dense and two-dimensional. The following are
explicitly deferred and have a re-entry document under `docs/todo/`:

| Surface | Re-entry document |
|---|---|
| optional T00 Schur/QZ ordering helpers | `docs/todo/T00-schur-optional-ordering.md` |
| `funm` | `docs/todo/T02-funm.md` |
| `polyfit`, `polyeig` | `docs/todo/T03-polyfit-polyeig.md` |
| `ismembertol` | `docs/todo/T04-ismembertol.md` |
| remaining special functions | `docs/todo/T06-special-functions.md` |
| `meshgrid` gap and volume graphics | `docs/todo/T08-meshgrid.md`, `docs/todo/T08-volume-graphics-after-ND.md` |
| matrix-valued PP output | `docs/todo/T10-matrix-valued-pp.md` |
| `interp3`, `interpn`, N-D interpolation | `docs/todo/T11-ND-interpolation.md` |
| complex nonlinear callbacks | `docs/todo/T12-complex-nonlinear-solvers.md` |
| `ArrayValued` quadrature | `docs/todo/T13-array-valued-quadrature.md` |
| `fminunc` | `docs/todo/T14-fminunc.md` |

Unsupported calls are rejected by the compatibility firewall when an `mp`
operand is involved. They are not delegated to a builtin binary64
implementation.

## Precision and regression evidence

The T-series uses source-precision and ambient-precision tests, including
1024-bit `2^-700` and 2048-bit `2^-1500` canaries where the relevant API is
applicable. The final controller wall passed M00–M23, C00–C12 including the
mandatory C11L complex LU path, N00–N08, S00–S08, T00–T14, the firewall,
serialization, graphics, and package lifecycle. Native ASan, UBSan, and
LSan completed successfully. Complete evidence is in
`reports/T00-T14-report.md`.
