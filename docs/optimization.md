# Arbitrary-precision optimization

`fminbnd` performs bounded scalar minimization with MPFR coordinates and MPFR
objective values using a safeguarded golden-section search.  `fminsearch`
uses an MPFR Nelder-Mead simplex with MPFR centroid, reflection, expansion,
contraction, shrink, and termination calculations.  Both callbacks must
return one finite real `mp` scalar; builtin binary64 objective results and
complex objectives are rejected.

`TolX`, `TolFun`, `MaxIter`, `MaxFunEvals`, and practical `Display` values are
accepted through an options struct or name/value pairs.  `OutputFcn` and
`PlotFcns` are rejected explicitly.  `fminunc` remains documented as a clean
deferred API in `docs/todo/T14-fminunc.md`.
