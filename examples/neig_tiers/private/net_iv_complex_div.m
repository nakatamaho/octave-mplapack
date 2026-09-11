function result = net_iv_complex_div (a, b, q)
  ar = net_iv_real (a.rl, a.rh);
  ai = net_iv_real (a.il, a.ih);
  br = net_iv_real (b.rl, b.rh);
  bi = net_iv_real (b.il, b.ih);
  denominator = net_iv_real_add (net_iv_real_mul (br, br, q), ...
                                 net_iv_real_mul (bi, bi, q), q);
  if (denominator.lo <= mp (0))
    error ("mplapack:neigt:IntervalDomain", "complex denominator contains zero");
  endif
  re = net_iv_real_div (net_iv_real_add (net_iv_real_mul (ar, br, q), ...
                                         net_iv_real_mul (ai, bi, q), q), ...
                        denominator, q);
  im = net_iv_real_div (net_iv_real_sub (net_iv_real_mul (ai, br, q), ...
                                         net_iv_real_mul (ar, bi, q), q), ...
                        denominator, q);
  result = net_iv_complex (re.lo, re.hi, im.lo, im.hi);
endfunction
