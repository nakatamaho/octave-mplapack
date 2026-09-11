function result = net_iv_cmatrix_add (left, right, q)
  net_iv_q (q);
  if (! valid_matrix_local (left) || ! valid_matrix_local (right) ...
      || ! isequal (size (left.rl), size (right.rl)))
    error ("mplapack:neigt:MatrixInterval", "incompatible interval matrices");
  endif
  result = left;
  for index = 1:numel (left.rl)
    box = net_iv_complex_add (entry_box_local (left, index), ...
                              entry_box_local (right, index), q);
    result.rl(index) = box.rl;
    result.rh(index) = box.rh;
    result.il(index) = box.il;
    result.ih(index) = box.ih;
  endfor
endfunction

function value = valid_matrix_local (matrix)
  value = isstruct (matrix) && isfield (matrix, "kind") ...
    && strcmp (matrix.kind, "complex_matrix") && isfield (matrix, "rl") ...
    && isfield (matrix, "rh") && isfield (matrix, "il") && isfield (matrix, "ih");
endfunction

function result = entry_box_local (matrix, index)
  result = net_iv_complex (matrix.rl(index), matrix.rh(index), ...
                           matrix.il(index), matrix.ih(index));
endfunction
