% Make a point interval without evaluating a proof operation.
function result = net_iv_point (value, q)
  net_iv_q (q);
  if (nargin != 2 || ! isa (value, "mp") || ! isscalar (value) ...
      || ! isfinite (value))
    error ("mplapack:neigt:Interval", "invalid real point");
  endif
  result = net_iv_real (value, value);
endfunction
