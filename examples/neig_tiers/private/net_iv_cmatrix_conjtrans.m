function result = net_iv_cmatrix_conjtrans (matrix)
  result = matrix;
  result.rl = ctranspose (matrix.rl);
  result.rh = ctranspose (matrix.rh);
  result.il = -ctranspose (matrix.ih);
  result.ih = -ctranspose (matrix.il);
endfunction
