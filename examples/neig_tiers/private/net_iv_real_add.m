function result = net_iv_real_add (a, b, q)
  net_iv_q (q);
  result = net_iv_real (net_iv_primitive ("add", a.lo, b.lo, q).lo, ...
                        net_iv_primitive ("add", a.hi, b.hi, q).hi);
endfunction
