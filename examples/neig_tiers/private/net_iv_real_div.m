function result = net_iv_real_div (a, b, q)
  net_iv_q (q);
  if (b.lo <= mp (0) && b.hi >= mp (0))
    error ("mplapack:neigt:IntervalDomain", "real interval denominator contains zero");
  endif
  p11 = net_iv_primitive ("div", a.lo, b.lo, q);
  p12 = net_iv_primitive ("div", a.lo, b.hi, q);
  p21 = net_iv_primitive ("div", a.hi, b.lo, q);
  p22 = net_iv_primitive ("div", a.hi, b.hi, q);
  lower_values = mp ([p11.lo; p12.lo; p21.lo; p22.lo]);
  upper_values = mp ([p11.hi; p12.hi; p21.hi; p22.hi]);
  [lo, ~] = net_iv_minmax (lower_values);
  [~, hi] = net_iv_minmax (upper_values);
  result = net_iv_real (lo, hi);
endfunction
