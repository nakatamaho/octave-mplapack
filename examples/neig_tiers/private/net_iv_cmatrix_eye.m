function result = net_iv_cmatrix_eye (n, q)
  net_iv_q (q);
  if (nargin != 2 || ! isnumeric (n) || ! isscalar (n) || n != fix (n) || n < 1)
    error ("mplapack:neigt:MatrixInterval", "invalid identity size");
  endif
  result = net_iv_cmatrix_point (mp (eye (n)), q);
endfunction
