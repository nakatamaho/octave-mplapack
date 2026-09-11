% Verified induced infinity upper norm for a rectangle matrix.
function result = net_iv_cmatrix_inf_upper (matrix, q)
  net_iv_q (q);
  if (! valid_matrix_norm (matrix))
    error ("mplapack:neigt:MatrixInterval", "invalid rectangle matrix");
  endif
  result = mp (0);
  for i = 1:rows (matrix.rl)
    row_sum = net_iv_real (mp (0), mp (0));
    for j = 1:columns (matrix.rl)
      magnitude = net_iv_complex_abs (entry_box_norm (matrix, i, j), q);
      row_sum = net_iv_real_add (row_sum, magnitude, q);
    endfor
    if (row_sum.hi > result)
      result = row_sum.hi;
    endif
  endfor
endfunction

function value = valid_matrix_norm (matrix)
  value = isstruct (matrix) && isfield (matrix, "kind") ...
    && strcmp (matrix.kind, "complex_matrix") && isfield (matrix, "rl") ...
    && isfield (matrix, "rh") && isfield (matrix, "il") && isfield (matrix, "ih");
endfunction

function result = entry_box_norm (matrix, i, j)
  if (isscalar (matrix.rl))
    result = net_iv_complex (matrix.rl, matrix.rh, matrix.il, matrix.ih);
  else
    result = net_iv_complex (matrix.rl(i,j), matrix.rh(i,j), ...
                             matrix.il(i,j), matrix.ih(i,j));
  endif
endfunction
