% Exact mathematical interval Gram-Schmidt/QR for a verified factor box.
% Positive diagonal lower bounds are a hard precondition; no normalization
% interval crossing zero is accepted.
function result = net_v_a1_interval_qr (E_box, q)
  if (nargin != 2 || ! isstruct (E_box) || q != fix (q) || q < 64)
    error ("mplapack:neigt:VA1", "invalid interval QR arguments");
  endif
  n = rows (E_box.rl);
  if (columns (E_box.rl) != n)
    error ("mplapack:neigt:VA1", "interval QR requires a square factor");
  endif
  Q = net_iv_cmatrix_point (mp (zeros (n, n)), q);
  R = net_iv_cmatrix_point (mp (zeros (n, n)), q);
  diagonal_lower = mp (zeros (n, 1));
  diagonal_upper = mp (zeros (n, 1));
  for j = 1:n
    original = column_box (E_box, j);
    residual = original;
    for i = 1:(j - 1)
      qi = column_box (Q, i);
      rij_matrix = net_iv_cmatrix_mul (net_iv_cmatrix_conjtrans (qi), ...
                                       original, q);
      rij = scalar_entry (rij_matrix);
      R = set_entry (R, i, j, rij);
      residual = net_iv_cmatrix_sub (residual, ...
        net_iv_cmatrix_mul (qi, scalar_matrix (rij, q), q), q);
    endfor
    lower_norm = lower_vector_norm (residual, q);
    upper_norm = net_iv_cmatrix_fro_upper (residual, q);
    diagonal_lower(j) = lower_norm;
    diagonal_upper(j) = upper_norm;
    if (lower_norm <= mp (0))
      result = failure (Q, R, diagonal_lower, diagonal_upper, j);
      return;
    endif
    rjj = net_iv_complex (lower_norm, upper_norm, mp (0), mp (0));
    R = set_entry (R, j, j, rjj);
    Q = set_column (Q, j, divide_by_positive_real (residual, ...
                                                     net_iv_real (lower_norm, upper_norm), q));
  endfor
  result = struct ("method", "neigt_interval_qr_v1", "status", "CERTIFIED_QR", ...
    "pass", true, "Q_box", Q, "R_box", R, ...
    "diagonal_lower", diagonal_lower, "diagonal_upper", diagonal_upper, ...
    "all_normalizations_positive", all (diagonal_lower > mp (0)), ...
    "paper_algorithm_reproduction", false);
endfunction

function result = lower_vector_norm (vector, q)
  sum_box = net_iv_real (mp (0), mp (0));
  for index = 1:numel (vector.rl)
    entry = scalar_at (vector, index);
    modulus = net_iv_complex_abs (entry, q);
    lower_point = net_iv_real (modulus.lo, modulus.lo);
    sum_box = net_iv_real_add (sum_box, net_iv_real_square (lower_point, q), q);
  endfor
  result = net_iv_real_sqrt (sum_box, q).lo;
endfunction

function result = divide_by_positive_real (vector, divisor, q)
  result = vector;
  for index = 1:numel (vector.rl)
    entry = scalar_at (vector, index);
    re = net_iv_real_div (net_iv_real (entry.rl, entry.rh), divisor, q);
    im = net_iv_real_div (net_iv_real (entry.il, entry.ih), divisor, q);
    result = set_linear_entry (result, index, ...
      net_iv_complex (re.lo, re.hi, im.lo, im.hi));
  endfor
endfunction

function result = scalar_matrix (value, q)
  result = struct ("kind", "complex_matrix", "rl", value.rl, "rh", value.rh, ...
                   "il", value.il, "ih", value.ih);
endfunction

function result = column_box (matrix, index)
  result = matrix;
  if (isscalar (matrix.rl))
    result.rl = matrix.rl;
    result.rh = matrix.rh;
    result.il = matrix.il;
    result.ih = matrix.ih;
  else
    result.rl = matrix.rl(:,index);
    result.rh = matrix.rh(:,index);
    result.il = matrix.il(:,index);
    result.ih = matrix.ih(:,index);
  endif
endfunction

function result = scalar_entry (matrix)
  if (! isscalar (matrix.rl))
    error ("mplapack:neigt:VA1", "expected a one-by-one interval matrix");
  endif
  result = net_iv_complex (matrix.rl, matrix.rh, matrix.il, matrix.ih);
endfunction

function result = scalar_at (matrix, index)
  if (isscalar (matrix.rl))
    result = net_iv_complex (matrix.rl, matrix.rh, matrix.il, matrix.ih);
  else
    result = net_iv_complex (matrix.rl(index), matrix.rh(index), ...
                             matrix.il(index), matrix.ih(index));
  endif
endfunction

function matrix = set_entry (matrix, i, j, value)
  if (isscalar (matrix.rl))
    matrix.rl = value.rl;
    matrix.rh = value.rh;
    matrix.il = value.il;
    matrix.ih = value.ih;
  else
    matrix.rl(i,j) = value.rl;
    matrix.rh(i,j) = value.rh;
    matrix.il(i,j) = value.il;
    matrix.ih(i,j) = value.ih;
  endif
endfunction

function matrix = set_linear_entry (matrix, index, value)
  if (isscalar (matrix.rl))
    matrix.rl = value.rl;
    matrix.rh = value.rh;
    matrix.il = value.il;
    matrix.ih = value.ih;
  else
    matrix.rl(index) = value.rl;
    matrix.rh(index) = value.rh;
    matrix.il(index) = value.il;
    matrix.ih(index) = value.ih;
  endif
endfunction

function matrix = set_column (matrix, index, column)
  if (isscalar (matrix.rl))
    matrix.rl = column.rl;
    matrix.rh = column.rh;
    matrix.il = column.il;
    matrix.ih = column.ih;
  else
    matrix.rl(:,index) = column.rl;
    matrix.rh(:,index) = column.rh;
    matrix.il(:,index) = column.il;
    matrix.ih(:,index) = column.ih;
  endif
endfunction

function result = failure (Q, R, diagonal_lower, diagonal_upper, index)
  result = struct ("method", "neigt_interval_qr_v1", ...
    "status", "INCONCLUSIVE_QR_NORMALIZATION", "pass", false, ...
    "Q_box", Q, "R_box", R, "diagonal_lower", diagonal_lower, ...
    "diagonal_upper", diagonal_upper, "failed_column", index, ...
    "all_normalizations_positive", false, "paper_algorithm_reproduction", false);
endfunction
