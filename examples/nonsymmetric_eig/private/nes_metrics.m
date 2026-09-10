% High-precision diagnostics for an actual returned eigentriple.
function result = nes_metrics (A_input_q, V_q, D_q, W_q, reference)
  if (nargin != 5 || ! isa (A_input_q, "mp") || ! isa (V_q, "mp")
      || ! isa (D_q, "mp") || ! isa (W_q, "mp") || ! isa (reference, "mp"))
    error ("NEIG:MetricArguments", "nes_metrics expects five mp values");
  endif
  if (rows (A_input_q) != columns (A_input_q)
      || rows (V_q) != rows (A_input_q) || columns (V_q) != rows (A_input_q)
      || rows (W_q) != rows (A_input_q) || columns (W_q) != rows (A_input_q)
      || rows (D_q) != rows (A_input_q) || columns (D_q) != rows (A_input_q))
    error ("NEIG:MetricShape", "A, V, D, and W must be compatible square eigensystem values");
  endif
  values = diag (D_q);
  n = rows (A_input_q);
  if (numel (reference) != n)
    error ("NEIG:MetricReference", "reference spectrum has the wrong size");
  endif
  if (! all (isfinite (A_input_q)) || ! all (isfinite (V_q))
      || ! all (isfinite (D_q)) || ! all (isfinite (W_q))
      || ! all (isfinite (reference)))
    error ("NEIG:MetricFinite", "eigensystem diagnostics require finite values");
  endif

  a_norm = norm (A_input_q, "fro");
  v_norm = norm (V_q, "fro");
  w_norm = norm (W_q, "fro");
  right_numerator = norm (A_input_q * V_q - V_q * D_q, "fro");
  left_numerator = norm (ctranspose (W_q) * A_input_q ...
                         - D_q * ctranspose (W_q), "fro");
  right_denominator = a_norm * v_norm;
  left_denominator = a_norm * w_norm;
  if (right_denominator == mp ("0") || left_denominator == mp ("0"))
    error ("NEIG:MetricDenominator", "eigensystem residual denominator is zero");
  endif

  eta_right = mp (zeros (n, 1));
  eta_left = mp (zeros (n, 1));
  condition = mp (zeros (n, 1));
  condition_status = "resolved";
  for column = 1:n
    v = V_q(:, column);
    w = W_q(:, column);
    nv = norm (v);
    nw = norm (w);
    if (nv == mp ("0") || nw == mp ("0"))
      error ("NEIG:MetricZeroVector", "eigensystem contains a zero eigenvector column");
    endif
    scale = a_norm + abs (values(column));
    if (scale == mp ("0"))
      error ("NEIG:MetricDenominator", "column residual denominator is zero");
    endif
    eta_right(column) = norm (A_input_q * v - v * values(column)) / (scale * nv);
    eta_left(column) = norm (ctranspose (A_input_q) * w ...
                              - w * conj (values(column))) / (scale * nw);
    overlap = abs (ctranspose (w) * v);
    if (overlap == mp ("0"))
      condition(column) = mp ("Inf");
      condition_status = "unresolved_zero_overlap";
    else
      condition(column) = nv * nw / overlap;
    endif
  endfor

  normalized = mp (zeros (n, n));
  for column = 1:n
    nv = norm (V_q(:, column));
    normalized(:, column) = V_q(:, column) * (mp ("1") / nv);
  endfor
  vector_condition = cond (normalized);
  absolute_match = nes_match (values, reference, "absolute");
  relative_match = nes_match (values, reference, "relative");
  result = struct ("values", values, "absolute_match", absolute_match, ...
                   "relative_match", relative_match, ...
                   "right_residual", right_numerator / right_denominator, ...
                   "left_residual", left_numerator / left_denominator, ...
                   "right_column_residual", max (eta_right), ...
                   "left_column_residual", max (eta_left), ...
                   "eta_right", eta_right, "eta_left", eta_left, ...
                   "condition_estimates", condition, ...
                   "condition_status", condition_status, ...
                   "vector_condition", vector_condition);
endfunction
