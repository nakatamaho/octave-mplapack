function result = net_iv_real_sqrt (a, q)
  net_iv_q (q);
  if (a.lo < mp (0))
    error ("mplapack:neigt:IntervalDomain", "sqrt interval crosses negative values");
  endif
  lower = net_iv_primitive ("sqrt", a.lo, mp (0), q);
  upper = net_iv_primitive ("sqrt", a.hi, mp (0), q);
  result = net_iv_real (lower.lo, upper.hi);
endfunction
