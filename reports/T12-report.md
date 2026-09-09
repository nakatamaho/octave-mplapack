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

## Controller metadata

| Field | Value |
|---|---|
| Repository / branch | `octave-mplapack` / `topic/t00-t14-continuation` |
| Starting commit / implementation tip | `216f78305a2df0e3c2da0bc0cf55500fd0498d96` / `dced45c3f977252d74ed3da7cb3389c8395ead8a` |
| D03 baseline | `34993eb569bfaa0d7665ae913a3a1f5a97ac2e31` / `v0.4.0` |
| Dependencies / Octave | gmpfrxx `32a7fb797202cdf92312ed9d133f96fdbcda590a` / `v1.4.1`; MPLAPACK `a59e5a0a429b05e8f07cf7a8feab1f48aef7431d`; GNU Octave 11.1.0 |
| API / backend | Real MP `fzero` and `fsolve`; safeguarded secant/bisection, MP Newton, finite differences, user Jacobian, backtracking |
| Precision / behavior | callbacks, steps, residuals, Jacobians, and tolerances use one MPFR precision; complex callbacks rejected |
| Octave QA / 1024-2048 | bracket/options/Jacobian/output metadata and failure cases; high-precision canaries PASS |
| Sanitizers / previous regression | ASan/UBSan/LSan PASS; T00–T11 and D03 walls retained |
| Status / TODO | PASS; `docs/todo/T12-complex-nonlinear-solvers.md` |
