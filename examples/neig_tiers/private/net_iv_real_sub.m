function result = net_iv_real_sub (a, b, q)
  net_iv_q (q);
  result = net_iv_real (net_iv_primitive ("sub", a.lo, b.hi, q).lo, ...
                        net_iv_primitive ("sub", a.hi, b.lo, q).hi);
endfunction
