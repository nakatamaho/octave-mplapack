% Outward contraction certificate for a normalized positive Perron pair.
function result = net_v_a3_pair (A, x0, lambda0, q, options)
  if (nargin < 4 || nargin > 5)
    error ("mplapack:neigt:VA3", "A, x0, lambda0, and q are required");
  endif
  if (nargin == 4)
    options = struct ();
  endif
  net_iv_q (q);
  n = rows (A);
  result = struct ("method", "neigt_positive_pair_contraction_v1", ...
    "paper_algorithm_reproduction", false, "status", "INCONCLUSIVE", ...
    "pass", false, "n", n, "candidate_source", "computed_eig_candidate", ...
    "c", mp ("NaN"), "e", mp ("NaN"), "trials", struct ([]), ...
    "radius_trial_count", 0, "contraction_pass", false, ...
    "positivity_pass", false, "x0", x0, "lambda0", lambda0, ...
    "R", [], "F0", [], "J0", [], "Y_box", [], ...
    "normalization_equation", "sum(x)-1=0");
  if (! isa (A, "mp") || ! isa (x0, "mp") || ! isa (lambda0, "mp") ...
      || rows (A) != columns (A) || ! isequal (size (x0), [n, 1]) ...
      || ! isscalar (lambda0) || ! all (isfinite (A(:))) ...
      || ! all (isfinite (x0(:))) || ! isfinite (lambda0) ...
      || q < 64 || q > 4096)
    result.status = "ERROR_INVALID_INPUT";
    return;
  endif
  if (any (imag (A(:)) != mp (0)) || any (imag (x0(:)) != mp (0)) ...
      || imag (lambda0) != mp (0))
    result.status = "UNSUPPORTED_COMPLEX_DOMAIN";
    return;
  endif
  x0_sum = mp (0);
  for i = 1:numel (x0)
    x0_sum = x0_sum + real (x0(i));
  endfor
  if (any (x0(:) <= mp (0)) || x0_sum <= mp (0))
    result.status = "INCONCLUSIVE_NONPOSITIVE_TRIAL";
    return;
  endif
  I = mp (eye (n + 1));
  x0 = real (x0);
  lambda0 = real (lambda0);
  F0 = mp (zeros (n + 1, 1));
  F0(1:n) = A * x0 - lambda0 * x0;
  F0(n + 1) = x0_sum - mp (1);
  J0 = mp (zeros (n + 1, n + 1));
  J0(1:n, 1:n) = A - lambda0 * mp (eye (n));
  J0(1:n, n + 1) = -x0;
  J0(n + 1, 1:n) = mp (ones (1, n));
  if (isfield (options, "R"))
    R = options.R;
    if (! isa (R, "mp") || ! isequal (size (R), size (J0)) ...
        || ! all (isfinite (R(:))))
      result.status = "ERROR_INVALID_INVERSE_CANDIDATE";
      return;
    endif
  else
    R = J0 \ I;
  endif
  F_box = net_iv_cmatrix_point (F0, q);
  R_box = net_iv_cmatrix_point (R, q);
  c = net_iv_cmatrix_inf_upper (net_iv_cmatrix_mul (R_box, F_box, q), q);
  result.c = c;
  result.R = R;
  result.F0 = F0;
  result.J0 = J0;
  if (c == mp (0))
    exponent = -floor (q / 2);
  else
    exponent = net_ufp (c) + 1;
    while (net_pow2 (exponent, q) <= mp (2) * c)
      exponent += 1;
    endwhile
  endif
  trials = struct ([]);
  accepted = false;
  accepted_t = mp (0);
  accepted_J = [];
  for index = 1:4
    t = net_pow2 (exponent + index - 1, q);
    J_box = jacobian_box (A, x0, lambda0, t, q);
    E_box = net_iv_cmatrix_sub (net_iv_cmatrix_point (I, q), ...
                                net_iv_cmatrix_mul (R_box, J_box, q), q);
    e = net_iv_cmatrix_inf_upper (E_box, q);
    et = net_iv_primitive ("mul", e, t, q).hi;
    self_bound = net_iv_primitive ("add", c, et, q).hi;
    positive = all (x0 - t > mp (0));
    trial = struct ("index", index, "t", t, "e", e, ...
      "self_bound", self_bound, "self_map", self_bound < t, ...
      "contraction", e < mp (1), "positive", positive, ...
      "pass", self_bound < t && e < mp (1) && positive);
    if (isempty (trials))
      trials = trial;
    else
      trials(end + 1) = trial;
    endif
    if (trial.pass)
      accepted = true;
      accepted_t = t;
      accepted_J = J_box;
      break;
    endif
  endfor
  result.trials = trials;
  result.radius_trial_count = numel (trials);
  result.contraction_pass = accepted;
  result.positivity_pass = accepted && all (x0 - accepted_t > mp (0));
  if (! accepted)
    result.status = "INCONCLUSIVE_PAIR_CONTRACTION";
    return;
  endif
  result.t = accepted_t;
  result.e = trials(end).e;
  result.Y_box = struct ("x_lower", x0 - accepted_t, ...
                         "x_upper", x0 + accepted_t, ...
                         "lambda_lower", lambda0 - accepted_t, ...
                         "lambda_upper", lambda0 + accepted_t);
  result.J_box = accepted_J;
  result.status = "CERTIFIED_PERRON_PAIR";
  result.claim_status = "CERTIFIED_PERRON_PAIR";
  result.claim_quality = "positive_normalized_unique_fixed_point";
  result.pass = true;
endfunction

function result = jacobian_box (A, x0, lambda0, t, q)
  n = rows (A);
  result = net_iv_cmatrix_point (mp (zeros (n + 1, n + 1)), q);
  for i = 1:n
    for j = 1:n
      value = A(i,j);
      if (i == j)
        center_box = net_iv_primitive ("sub", value, lambda0, q);
        result.rl(i,j) = net_iv_primitive ("sub", center_box.lo, t, q).lo;
        result.rh(i,j) = net_iv_primitive ("add", center_box.hi, t, q).hi;
      else
        result.rl(i,j) = value;
        result.rh(i,j) = value;
      endif
    endfor
    result.rl(i,n + 1) = net_iv_primitive ("sub", -x0(i), t, q).lo;
    result.rh(i,n + 1) = net_iv_primitive ("add", -x0(i), t, q).hi;
    result.il(i,n + 1) = mp (0);
    result.ih(i,n + 1) = mp (0);
  endfor
  for j = 1:n
    result.rl(n + 1,j) = mp (1);
    result.rh(n + 1,j) = mp (1);
  endfor
  result.rl(n + 1,n + 1) = mp (0);
  result.rh(n + 1,n + 1) = mp (0);
endfunction
