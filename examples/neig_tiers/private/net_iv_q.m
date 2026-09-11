% Validate the fixed precision contract used by every interval primitive.
function net_iv_q (q)
  if (nargin != 1 || ! isnumeric (q) || ! isscalar (q) || ! isreal (q) ...
      || ! isfinite (q) || q != fix (q) || q < 64 || q > 4096)
    error ("mplapack:neigt:IntervalPrecision", ...
           "interval precision must be an integer in [64,4096]");
  endif
endfunction
