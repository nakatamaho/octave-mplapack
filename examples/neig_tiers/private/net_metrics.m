% MP diagnostics for raw nonsymmetric eigentriples.
function result = net_metrics (A, V, D, W, reference, options)
  if (nargin < 5 || nargin > 6 || ! isa (A, "mp") || ! isa (V, "mp") ...
      || ! isa (D, "mp") || ! isa (W, "mp") || ! isa (reference, "mp"))
    error ("mplapack:neigt:Metrics", "invalid eigentriple metric arguments");
  endif
  if (nargin == 5 || isempty (options))
    options = struct ();
  endif
  n = rows (A);
  if (columns (A) != n || rows (V) != n || columns (V) != n ...
      || rows (W) != n || columns (W) != n ...
      || rows (D) != n || columns (D) != n || numel (reference) != n)
    error ("mplapack:neigt:Metrics", "incompatible eigentriple dimensions");
  endif
  if (! all (isfinite (A)) || ! all (isfinite (V)) ...
      || ! all (isfinite (D)) || ! all (isfinite (W)) ...
      || ! all (isfinite (reference)))
    error ("mplapack:neigt:Metrics", "metrics require finite MP values");
  endif
  if (isfield (options, "simple_mask"))
    simple_mask = logical (options.simple_mask(:));
    if (numel (simple_mask) != n)
      error ("mplapack:neigt:Metrics", "simple_mask has the wrong size");
    endif
  else
    simple_mask = true (n, 1);
  endif
  values = diag (D);
  a_norm = norm (A, "fro");
  v_norm = norm (V, "fro");
  w_norm = norm (W, "fro");
  right_numerator = norm (A * V - V * D, "fro");
  left_numerator = norm (ctranspose (W) * A - D * ctranspose (W), "fro");
  if (a_norm == mp (0))
    right_residual = right_numerator;
    left_residual = left_numerator;
  else
    right_residual = right_numerator / (a_norm * v_norm);
    left_residual = left_numerator / (a_norm * w_norm);
  endif
  right_column = mp (zeros (n, 1));
  left_column = mp (zeros (n, 1));
  condition = mp (zeros (n, 1));
  condition_status = repmat ({"not_applicable_simple_root"}, n, 1);
  for index = 1:n
    v = V(:, index);
    w = W(:, index);
    nv = norm (v);
    nw = norm (w);
    if (nv == mp (0) || nw == mp (0))
      error ("mplapack:neigt:Metrics", "zero eigvector column");
    endif
    scale = a_norm + abs (values(index));
    if (scale == mp (0))
      right_column(index) = norm (A * v - values(index) * v) / nv;
      left_column(index) = norm (ctranspose (A) * w ...
                                  - conj (values(index)) * w) / nw;
    else
      right_column(index) = norm (A * v - values(index) * v) / (scale * nv);
      left_column(index) = norm (ctranspose (A) * w ...
                                 - conj (values(index)) * w) / (scale * nw);
    endif
    if (simple_mask(index))
      overlap = abs (ctranspose (w) * v);
      if (overlap == mp (0))
        condition(index) = mp ("Inf");
        condition_status{index} = "unresolved_zero_overlap";
      else
        condition(index) = nv * nw / overlap;
        condition_status{index} = "resolved_simple_root";
      endif
    endif
  endfor
  absolute = net_match (values, reference, "absolute");
  has_zero = any (reference == mp (0));
  if (has_zero)
    relative = struct ("status", "undefined_zero_reference", ...
                       "method", "minimum_bottleneck_bijective_v1");
  else
    relative = net_match (values, reference, "relative");
  endif
  result = struct ("values", values, "absolute_match", absolute, ...
                   "relative_match", relative, ...
                   "right_residual", right_residual, ...
                   "left_residual", left_residual, ...
                   "right_column_residual", max (right_column), ...
                   "left_column_residual", max (left_column), ...
                   "eta_right", right_column, "eta_left", left_column, ...
                   "condition_estimates", condition, ...
                   "condition_status", {condition_status}, ...
                   "simple_mask", simple_mask, "status", "MEASURED");
endfunction
