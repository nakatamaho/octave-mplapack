% Run one verified positive Perron root/vector job.
function result = net_v_a3_job (job, profile_data, profile)
  result = status_template (job, profile_data);
  bits = profile_data.source_bits;
  q = profile_data.evaluation_bits;
  saved_bits = mpbits ();
  unwind_protect
    try
      stage = "model";
      fixture = job.fixture;
      if (strcmp (char (fixture.representation), "stochastic"))
        markov = net_markov_model (fixture.n, fixture.epsilon_exponent, bits);
        A_model = markov.P_frozen;
        source = markov.source;
        input_status = markov.input_status;
        base_markov = markov;
      elseif (strcmp (char (fixture.representation), "positive_similarity"))
        perron = net_perron_model (fixture.n, fixture.epsilon_exponent, bits);
        A_model = perron.A_frozen;
        source = perron.source;
        input_status = perron.input_status;
        base_markov = perron.markov;
      else
        error ("mplapack:neigt:VA3", "unsupported Perron representation");
      endif
      if (fixture.transpose)
        A_model = ctranspose (A_model);
        source = [source, "_TRANSPOSE"];
      endif
      result.source = source;
      result.input_status = input_status;
      result.input_hash = net_raw_hash (A_model, [job.id, "_A_frozen"]);
      result.base_input_hash = net_raw_hash (base_markov.P_frozen, [job.id, "_P_frozen"]);

      mpbits (bits);
      stage = "right-eig";
      [V, D, W_unused] = eig (A_model, "nobalance");
      values = diag (D);
      index = select_perron (values);
      x0 = real (V(:, index));
      x0 = orient_positive (x0);
      x0_sum = mp (0);
      for x_index = 1:numel (x0)
        x0_sum = x0_sum + real (x0(x_index));
      endfor
      x0 = x0 / x0_sum;
      lambda0 = real (values(index));
      result.raw_V = V;
      result.raw_D = D;
      result.raw_W = W_unused;
      result.raw_V_hash = net_raw_hash (V, [job.id, "_raw_V"]);
      result.raw_D_hash = net_raw_hash (D, [job.id, "_raw_D"]);
      result.raw_W_hash = net_raw_hash (W_unused, [job.id, "_raw_W"]);
      result.candidate_index = index;
      result.candidate_lambda = lambda0;
      result.candidate_source = "computed_normalized_positive_pair";
      result.candidate_bits = bits;
      result.evaluation_bits = q;

      mpbits (q);
      stage = "collatz";
      A = net_widen (A_model, q, bits);
      xq = net_widen (x0, q, bits);
      lq = net_widen (lambda0, q, bits);
      collatz = net_v_a3_collatz (A, xq, q);
      stage = "pair";
      pair = net_v_a3_pair (A, xq, lq, q);
      result.collatz = collatz;
      result.pair = pair;
      result.root_status = collatz.status;
      result.root_interval = net_iv_real (collatz.cw_lower, collatz.cw_upper);
      if (pair.pass)
        pair_interval = net_iv_real (pair.Y_box.lambda_lower, ...
                                     pair.Y_box.lambda_upper);
        result.lambda_pair_interval = pair_interval;
        result.lambda_intersection = interval_intersection (collatz, pair_interval);
      else
        result.lambda_pair_interval = net_iv_real (mp (0), mp (0));
        result.lambda_intersection = struct ("nonempty", false);
      endif

      % An independently prepared left candidate is retained separately from
      % the right-pair contraction.  It is normalized by w'*x=1 and checked
      % against the original A, including the nontrivial stationary case.
      stage = "left-eig";
      [VL, DL] = eig (ctranspose (A_model), "nobalance");
      left_values = diag (DL);
      left_index = select_perron (left_values);
      w0 = orient_positive (real (VL(:, left_index)));
      w0 = w0 / (ctranspose (w0) * x0);
      stage = "left-residual";
      Wq = net_widen (w0, q, bits);
      left_lambda = net_widen (real (left_values(left_index)), q, bits);
      stage = "left-mul";
      left_row = net_iv_cmatrix_conjtrans (net_iv_cmatrix_point (Wq, q));
      left_matrix = net_iv_cmatrix_point (A, q);
      left_A = net_iv_cmatrix_mul (left_row, left_matrix, q);
      stage = "left-scale";
      left_rhs = row_scale (left_row, left_lambda, q);
      stage = "left-sub";
      left_residual = net_iv_cmatrix_sub ...
        (left_A, left_rhs, q);
      result.raw_left_V = VL;
      result.raw_left_D = DL;
      result.raw_left_V_hash = net_raw_hash (VL, [job.id, "_raw_left_V"]);
      result.left_candidate = Wq;
      result.left_residual_box = left_residual;
      result.left_residual_norm_upper = net_iv_cmatrix_fro_upper (left_residual, q);
      result.left_strictly_positive = all (real (Wq(:)) > mp (0)) ...
                                       && all (imag (Wq(:)) == mp (0));
      result.left_normalization = ctranspose (Wq) * net_widen (x0, q, bits);

      result.stationary = [];
      if (strcmp (char (fixture.representation), "stochastic"))
        result.stationary = independent_stationary (base_markov.P_frozen, bits);
      endif
      result.root_width_target = net_pow2 (-64, q);
      result.root_width_pass = collatz.pass ...
                               && collatz.width <= result.root_width_target;
      result.pass = collatz.pass && result.root_width_pass && pair.pass ...
                    && result.lambda_intersection.nonempty ...
                    && result.left_strictly_positive ...
                    && result.left_residual_norm_upper <= result.root_width_target ...
                    && (isempty (result.stationary) || result.stationary.pass);
      if (result.pass)
        result.status = "CERTIFIED_PERRON_PAIR";
        result.claim_status = "CERTIFIED_PERRON_ROOT_AND_PAIR";
        result.claim_quality = "strict_positive_graph_collatz_contraction";
        result.milestone_pass = true;
      else
        result.status = "INCONCLUSIVE_PERRON_PAIR";
        result.claim_status = "INCONCLUSIVE";
        result.milestone_pass = false;
      endif
    catch exception
      result.status = "FAILED_VERIFIER";
      result.claim_status = "ERROR";
      result.error_identifier = exception.identifier;
      result.error_message = exception.message;
      result.failure_stage = stage;
    end_try_catch
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function result = row_scale (row, scalar, q)
  result = net_iv_cmatrix_point (mp (zeros (1, columns (row.rl))), q);
  scalar_box = net_iv_complex_point (scalar, q);
  for j = 1:columns (row.rl)
    value = net_iv_complex (row.rl(1,j), row.rh(1,j), ...
                            row.il(1,j), row.ih(1,j));
    product = net_iv_complex_mul (scalar_box, value, q);
    result.rl(1,j) = product.rl;
    result.rh(1,j) = product.rh;
    result.il(1,j) = product.il;
    result.ih(1,j) = product.ih;
  endfor
endfunction

function index = select_perron (values)
  index = 1;
  for i = 2:numel (values)
    if (real (values(i)) > real (values(index)))
      index = i;
    endif
  endfor
endfunction

function result = orient_positive (value)
  result = value;
  [~, index] = max (abs (result));
  if (result(index) < mp (0))
    result = -result;
  endif
endfunction

function result = interval_intersection (collatz, pair_interval)
  lower = collatz.cw_lower;
  if (pair_interval.lo > lower)
    lower = pair_interval.lo;
  endif
  upper = collatz.cw_upper;
  if (pair_interval.hi < upper)
    upper = pair_interval.hi;
  endif
  result = struct ("lower", lower, "upper", upper, "nonempty", lower <= upper);
endfunction

function result = independent_stationary (P, bits)
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    n = rows (P);
    M = ctranspose (P) - mp (eye (n));
    rhs = mp (zeros (n, 1));
    M(n,:) = mp (ones (1, n));
    rhs(n) = mp (1);
    pi = M \ rhs;
    pi_sum = sum_real_vector (pi);
    pi = pi / pi_sum;
    pi_sum = sum_real_vector (pi);
    equation = ctranspose (P) * pi - pi;
    normalization_error = abs (pi_sum - mp (1));
    result = struct ("method", "independent_stationary_normalized_solve", ...
      "vector", pi, "sum", pi_sum, "normalization_error", normalization_error, ...
      "positive", all (pi > mp (0)), ...
      "residual", equation, "residual_norm", norm (equation), ...
      "pass", all (pi > mp (0)) && normalization_error <= net_pow2 (-64, bits) ...
                && norm (equation) <= net_pow2 (-64, bits));
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function result = sum_real_vector (items)
  result = mp (0);
  for i = 1:numel (items)
    result = result + real (items(i));
  endfor
endfunction

function result = status_template (job, profile_data)
  result = struct ("id", job.id, "tier", job.tier, "kind", job.kind, ...
    "status", "NOT_IMPLEMENTED", "pass", false, "milestone_pass", false, ...
    "claim_status", "", "claim_quality", "", "candidate_source", "", ...
    "candidate_bits", profile_data.source_bits, ...
    "evaluation_bits", profile_data.evaluation_bits, "source", "", ...
    "input_status", "", "input_hash", "", "base_input_hash", "", ...
    "raw_V_hash", "", "raw_D_hash", "", "raw_W_hash", "", ...
    "raw_V", [], "raw_D", [], "raw_W", [], "error_identifier", "", ...
    "error_message", "", "failure_stage", "");
endfunction
