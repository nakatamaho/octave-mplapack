% Min/max for a finite MP scalar list without binary64 conversion.
function [lo, hi] = net_iv_minmax (values)
  if (! isa (values, "mp") || isempty (values) || ! all (isfinite (values)))
    error ("mplapack:neigt:Interval", "invalid MP extrema list");
  endif
  lo = values(1);
  hi = values(1);
  for index = 2:numel (values)
    if (values(index) < lo)
      lo = values(index);
    endif
    if (values(index) > hi)
      hi = values(index);
    endif
  endfor
endfunction
