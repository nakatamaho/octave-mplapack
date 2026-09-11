% Positive-graph and Collatz--Wielandt root enclosure baseline.
function result = net_v_a3_collatz (A, x, q)
  net_iv_q (q);
  result = struct ("method", "neigt_collatz_wielandt_v1", ...
    "paper_algorithm_reproduction", false, "status", "INCONCLUSIVE", ...
    "pass", false, "irreducible", false, "strictly_positive", false, ...
    "cw_lower", mp ("NaN"), "cw_upper", mp ("NaN"), ...
    "width", mp ("NaN"), "trial_vector", x, "reachable", false);
  if (nargin != 3 || ! isa (A, "mp") || ! isa (x, "mp") ...
      || rows (A) != columns (A) || columns (x) != 1 ...
      || rows (x) != rows (A) || ! all (isfinite (A(:))) ...
      || ! all (isfinite (x(:))))
    result.status = "ERROR_INVALID_INPUT";
    return;
  endif
  n = rows (A);
  if (any (imag (A(:)) != mp (0)))
    result.status = "UNSUPPORTED_COMPLEX_DOMAIN";
    return;
  endif
  if (any (A(:) < mp (0)))
    result.status = "UNSUPPORTED_NEGATIVE_ENTRY";
    return;
  endif
  if (any (x(:) <= mp (0)))
    result.status = "INCONCLUSIVE_NONPOSITIVE_TRIAL";
    return;
  endif
  adjacency = false (n, n);
  for i = 1:n
    for j = 1:n
      adjacency(i,j) = A(i,j) > mp (0);
    endfor
  endfor
  reachable = adjacency | eye (n);
  for k = 1:n
    reachable = reachable | (reachable * reachable > 0);
  endfor
  strongly_connected = all (reachable(:));
  strictly_positive = all (A(:) > mp (0));
  result.reachable = strongly_connected;
  result.irreducible = strongly_connected;
  result.strictly_positive = strictly_positive;
  if (! strongly_connected)
    result.status = "INCONCLUSIVE_NOT_IRREDUCIBLE";
    return;
  endif
  A_box = net_iv_cmatrix_point (A, q);
  x_box = net_iv_cmatrix_point (x, q);
  ax_box = net_iv_cmatrix_mul (A_box, x_box, q);
  ratios = mp (zeros (n, 1));
  ratio_lower = mp (zeros (n, 1));
  ratio_upper = mp (zeros (n, 1));
  for i = 1:n
    numerator = net_iv_real (ax_box.rl(i), ax_box.rh(i));
    denominator = net_iv_real (x_box.rl(i), x_box.rh(i));
    ratio = net_iv_real_div (numerator, denominator, q);
    ratio_lower(i) = ratio.lo;
    ratio_upper(i) = ratio.hi;
    ratios(i) = (ratio.lo + ratio.hi) * mp ("0.5");
  endfor
  [lower, ~] = net_iv_minmax (ratio_lower);
  [~, upper] = net_iv_minmax (ratio_upper);
  result.ratios = ratios;
  result.ratio_lower = ratio_lower;
  result.ratio_upper = ratio_upper;
  result.cw_lower = lower;
  result.cw_upper = upper;
  result.width = upper - lower;
  result.pass = lower <= upper && lower >= mp (0);
  if (result.pass)
    result.status = "CERTIFIED_PERRON_ROOT";
  endif
endfunction
