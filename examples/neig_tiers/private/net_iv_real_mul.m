function result = net_iv_real_mul (a, b, q)
  net_iv_q (q);
  p11 = net_iv_primitive ("mul", a.lo, b.lo, q);
  p12 = net_iv_primitive ("mul", a.lo, b.hi, q);
  p21 = net_iv_primitive ("mul", a.hi, b.lo, q);
  p22 = net_iv_primitive ("mul", a.hi, b.hi, q);
  lower_values = mp ([p11.lo; p12.lo; p21.lo; p22.lo]);
  upper_values = mp ([p11.hi; p12.hi; p21.hi; p22.hi]);
  [lo, ~] = net_iv_minmax (lower_values);
  [~, hi] = net_iv_minmax (upper_values);
  result = net_iv_real (lo, hi);
endfunction
