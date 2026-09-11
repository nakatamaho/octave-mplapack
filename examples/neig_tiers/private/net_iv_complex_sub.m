function result = net_iv_complex_sub (a, b, q)
  result = net_iv_complex_add (a, net_iv_complex (-b.rh, -b.rl, -b.ih, -b.il), q);
endfunction
