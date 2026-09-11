% Exact unit-in-the-first-place power for a positive MP scalar.
function exponent = net_ufp (value)
  if (nargin != 1 || ! isa (value, "mp") || ! isscalar (value) ...
      || ! isfinite (value) || value <= mp (0))
    error ("mplapack:neigt:Ufp", "ufp expects a positive finite MP scalar");
  endif
  value = abs (value);
  exponent = 0;
  scale = mp (1);
  while (value >= mp (2) * scale)
    scale = scale * mp (2);
    exponent += 1;
  endwhile
  while (value < scale)
    scale = scale * mp ("0.5");
    exponent -= 1;
  endwhile
  if (! (scale <= value && value < mp (2) * scale))
    error ("mplapack:neigt:Ufp", "exact ufp search did not bracket value");
  endif
endfunction
