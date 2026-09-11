function result = net_iv_complex_mul (a, b, q)
  ar = net_iv_real (a.rl, a.rh);
  ai = net_iv_real (a.il, a.ih);
  br = net_iv_real (b.rl, b.rh);
  bi = net_iv_real (b.il, b.ih);
  re = net_iv_real_sub (net_iv_real_mul (ar, br, q), ...
                        net_iv_real_mul (ai, bi, q), q);
  im = net_iv_real_add (net_iv_real_mul (ar, bi, q), ...
                        net_iv_real_mul (ai, br, q), q);
  result = net_iv_complex (re.lo, re.hi, im.lo, im.hi);
endfunction
