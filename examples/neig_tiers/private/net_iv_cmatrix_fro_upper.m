% Verified Frobenius upper norm for a rectangle matrix.
function result = net_iv_cmatrix_fro_upper (matrix, q)
  net_iv_q (q);
  if (! valid_matrix_norm (matrix))
    error ("mplapack:neigt:MatrixInterval", "invalid rectangle matrix");
  endif
  sum_box = net_iv_real (mp (0), mp (0));
  if (isscalar (matrix.rl))
    re = net_iv_real (matrix.rl, matrix.rh);
    im = net_iv_real (matrix.il, matrix.ih);
    sum_box = net_iv_real_add (sum_box, net_iv_real_square (re, q), q);
    sum_box = net_iv_real_add (sum_box, net_iv_real_square (im, q), q);
    result = net_iv_real_sqrt (sum_box, q).hi;
    return;
  endif
  for index = 1:numel (matrix.rl)
    re = net_iv_real (matrix.rl(index), matrix.rh(index));
    im = net_iv_real (matrix.il(index), matrix.ih(index));
    sum_box = net_iv_real_add (sum_box, net_iv_real_square (re, q), q);
    sum_box = net_iv_real_add (sum_box, net_iv_real_square (im, q), q);
  endfor
  result = net_iv_real_sqrt (sum_box, q).hi;
endfunction

function value = valid_matrix_norm (matrix)
  value = isstruct (matrix) && isfield (matrix, "kind") ...
    && strcmp (matrix.kind, "complex_matrix") && isfield (matrix, "rl") ...
    && isfield (matrix, "rh") && isfield (matrix, "il") && isfield (matrix, "ih");
endfunction
