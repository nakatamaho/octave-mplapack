function result = net_iv_complex_add (a, b, q)
  real_sum = net_iv_real_add (net_iv_real (a.rl, a.rh), ...
                              net_iv_real (b.rl, b.rh), q);
  imag_sum = net_iv_real_add (net_iv_real (a.il, a.ih), ...
                              net_iv_real (b.il, b.ih), q);
  result = net_iv_complex (real_sum.lo, real_sum.hi, imag_sum.lo, imag_sum.hi);
endfunction
