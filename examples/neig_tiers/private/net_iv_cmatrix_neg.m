function result = net_iv_cmatrix_neg (matrix)
  result = matrix;
  result.rl = -matrix.rh;
  result.rh = -matrix.rl;
  result.il = -matrix.ih;
  result.ih = -matrix.il;
endfunction
