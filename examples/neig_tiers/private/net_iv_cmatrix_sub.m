function result = net_iv_cmatrix_sub (left, right, q)
  result = net_iv_cmatrix_add (left, net_iv_cmatrix_neg (right), q);
endfunction
