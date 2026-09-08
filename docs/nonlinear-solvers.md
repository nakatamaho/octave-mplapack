# Nonlinear solvers

`fzero` and `fsolve` accept MP starting values and call user callbacks with
MP values.  A callback that returns builtin double data is rejected; there is
no hidden call to the builtin binary64 solver.

`fzero` accepts a scalar starting point or a two-point bracket.  Scalar starts
are expanded with MP steps until a sign-changing bracket is found.  The solve
uses a safeguarded secant proposal inside a sign-changing bracket and falls
back to the MP midpoint when the proposal is unsafe.  Default `TolX` and the
iteration budget are derived from the active MP precision; `TolX`, `TolFun`,
and `MaxIter` can be supplied in a scalar options struct.

`fsolve` accepts real MP scalar/vector/matrix starts and uses MP Newton steps.
Without `Jacobian="on"`, forward differences use MP perturbations based on
the active precision.  With `Jacobian="on"`, the callback must return
`[residual,jacobian]`, both as real MP values.  A short MP backtracking line
search is applied to rejected full Newton steps.  The implementation is
intentionally limited to real systems in this milestone; complex nonlinear
callback semantics are not silently guessed.
