% Explicit interval matrix multiplication; no padded ordinary GEMM is used.
function result = net_iv_cmatrix_mul (left, right, q)
  net_iv_q (q);
  if (! valid_matrix (left) || ! valid_matrix (right) ...
      || columns (left.rl) != rows (right.rl))
    error ("mplapack:neigt:MatrixInterval", "incompatible interval matrices");
  endif
  m = rows (left.rl);
  n = columns (right.rl);
  inner = columns (left.rl);
  result = zero_matrix (m, n, q);
  for i = 1:m
    for j = 1:n
      sum_box = net_iv_complex (mp (0), mp (0), mp (0), mp (0));
      for k = 1:inner
        term = net_iv_complex_mul (entry_box (left, i, k), ...
                                    entry_box (right, k, j), q);
        sum_box = net_iv_complex_add (sum_box, term, q);
      endfor
      result.rl(i,j) = sum_box.rl;
      result.rh(i,j) = sum_box.rh;
      result.il(i,j) = sum_box.il;
      result.ih(i,j) = sum_box.ih;
    endfor
  endfor
endfunction

function value = valid_matrix (matrix)
  value = isstruct (matrix) && isfield (matrix, "kind") ...
    && strcmp (matrix.kind, "complex_matrix") && isfield (matrix, "rl") ...
    && isfield (matrix, "rh") && isfield (matrix, "il") && isfield (matrix, "ih") ...
    && isequal (size (matrix.rl), size (matrix.rh)) ...
    && isequal (size (matrix.rl), size (matrix.il)) ...
    && isequal (size (matrix.rl), size (matrix.ih));
endfunction

function result = zero_matrix (m, n, q)
  result = struct ("kind", "complex_matrix", ...
    "rl", mp (zeros (m,n)), "rh", mp (zeros (m,n)), ...
    "il", mp (zeros (m,n)), "ih", mp (zeros (m,n)));
endfunction

function result = entry_box (matrix, i, j)
  result = net_iv_complex (matrix.rl(i,j), matrix.rh(i,j), ...
                           matrix.il(i,j), matrix.ih(i,j));
endfunction
