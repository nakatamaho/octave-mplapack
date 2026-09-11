% Return rigorous upper/lower bounds for the modulus of a rectangle.
function result = net_iv_complex_abs (a, q)
  re = net_iv_real (a.rl, a.rh);
  im = net_iv_real (a.il, a.ih);
  upper_sq = net_iv_real_add (net_iv_real_square (re, q), ...
                              net_iv_real_square (im, q), q);
  upper = net_iv_real_sqrt (upper_sq, q);
  if (re.lo <= mp (0) && re.hi >= mp (0))
    dx = mp (0);
  else
    dx = min_abs_endpoints (re.lo, re.hi);
  endif
  if (im.lo <= mp (0) && im.hi >= mp (0))
    dy = mp (0);
  else
    dy = min_abs_endpoints (im.lo, im.hi);
  endif
  lower_sq = net_iv_real_add (net_iv_real_square (net_iv_iv_point (dx), q), ...
                              net_iv_real_square (net_iv_iv_point (dy), q), q);
  lower = net_iv_real_sqrt (lower_sq, q);
  result = net_iv_real (lower.lo, upper.hi);
endfunction

function value = min_abs_endpoints (lo, hi)
  if (abs (lo) < abs (hi))
    value = abs (lo);
  else
    value = abs (hi);
  endif
endfunction

function value = net_iv_iv_point (x)
  value = net_iv_real (x, x);
endfunction
