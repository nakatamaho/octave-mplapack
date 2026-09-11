% Construct a closed finite real interval [lo,hi].
function result = net_iv_real (lo, hi)
  if (nargin != 2 || ! isa (lo, "mp") || ! isa (hi, "mp") ...
      || ! isscalar (lo) || ! isscalar (hi) ...
      || ! isfinite (lo) || ! isfinite (hi) || lo > hi)
    error ("mplapack:neigt:Interval", "invalid real interval");
  endif
  result = struct ("kind", "real", "lo", lo, "hi", hi);
endfunction
