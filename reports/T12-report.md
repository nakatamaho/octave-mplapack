# T12 report — nonlinear equations

## Result

`T12 PASS — NONLINEAR EQUATION CORE CLOSED`

T12 was implemented on the T11 head
`216f78305a2df0e3c2da0bc0cf55500fd0498d96` on
`topic/t00-t14-continuation` and tested with GNU Octave 11.1.0 and the frozen
MPLAPACK MPFR/MPC backend.

## Implemented surface

- `fzero` accepts scalar or two-point MP starts, expands scalar starts to a
  bracket, and uses safeguarded MP secant/bisection iterations;
- `fsolve` accepts real MP systems, performs MP Newton iterations, computes
  finite-difference Jacobians entirely with MP values, supports a user
  `Jacobian="on"` callback, and performs MP backtracking;
- common `TolX`, `TolFun`, `MaxIter`, `info/exit`, and output metadata are
  supported;
- non-MP or complex callback results are rejected explicitly.

The callback, tolerance, real-only boundary, and no-binary64 policy are
recorded in `docs/nonlinear-solvers.md`.

## Focused QA

`test/t12_solvers.tst` passed all four tests:

- a 1024-bit root `1 + 2^-700` invisible after binary64 conversion, bracketed
  and scalar-start fzero forms;
- a 512-bit TolX-controlled quadratic root and double callback rejection;
- a real 2-variable finite-difference Newton system, MP residuals, and a
  user-Jacobian callback from `test/t12_linear_system_callback.m`;
- a 1024-bit fsolve root and explicit double callback firewall.

## Required real-regression wall

The complete `test/run_tests.m` wall passed after T12, covering M00–M23,
C00–C12 including C11L, N00–N08, S00–S08, and T00–T12.  Expected warnings
from headless gnuplot and the existing singular-machine-precision fixture
remained non-fatal.
