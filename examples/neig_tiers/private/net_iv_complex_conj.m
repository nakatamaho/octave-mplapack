function result = net_iv_complex_conj (a)
  result = net_iv_complex (a.rl, a.rh, -a.ih, -a.il);
endfunction
