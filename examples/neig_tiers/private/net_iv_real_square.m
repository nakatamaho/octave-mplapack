% Verified square; the lower endpoint is exactly zero when the interval crosses zero.
function result = net_iv_real_square (a, q)
  net_iv_q (q);
  p11 = net_iv_primitive ("mul", a.lo, a.lo, q);
  p12 = net_iv_primitive ("mul", a.lo, a.hi, q);
  p21 = net_iv_primitive ("mul", a.hi, a.lo, q);
  p22 = net_iv_primitive ("mul", a.hi, a.hi, q);
  upper_values = mp ([p11.hi; p12.hi; p21.hi; p22.hi]);
  [~, hi] = net_iv_minmax (upper_values);
  if (a.lo <= mp (0) && a.hi >= mp (0))
    lo = mp (0);
  else
    lower_values = mp ([p11.lo; p12.lo; p21.lo; p22.lo]);
    [lo, ~] = net_iv_minmax (lower_values);
  endif
  result = net_iv_real (lo, hi);
endfunction
