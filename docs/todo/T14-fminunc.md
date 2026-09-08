# T14 `fminunc` deferral

`fminbnd` and `fminsearch` close the required T14 optimization surface.  A
robust arbitrary-precision `fminunc` needs a separately specified MP gradient
and Hessian/Jacobian callback contract, finite-difference scaling policy, and
line-search/termination semantics.  It is therefore deferred rather than
silently routing through Octave's binary64 implementation.
