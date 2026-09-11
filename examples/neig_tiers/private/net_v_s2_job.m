% Run one bounded computed V-S2 candidate schedule and full cluster proof.
function result = net_v_s2_job (job, profile_data, profile)
  if (nargin != 3 || ! isstruct (job) || ! isfield (job, "fixture") ...
      || ! isfield (job, "cluster_dimension"))
    error ("mplapack:neigt:VS2", "invalid V-S2 job");
  endif
  candidate_bits = profile_data.work_bits(end);
  q = profile_data.evaluation_bits;
  fixture = job.fixture;
  model = make_fixture (fixture, candidate_bits);
  center = parse_center (fixture.query_center, candidate_bits);
  radius = net_dyadic_parameter (fixture.query_radius, candidate_bits);
  preparation = net_v_s2_candidate (model.A_frozen, center, radius, ...
                                     job.cluster_dimension, candidate_bits);
  if (strcmp (char (fixture.regime), "mks_zero"))
    [mks_candidate, mks_record] = mks_eigen_complement (...
      model.A_frozen, center, radius, preparation, job.cluster_dimension, ...
      candidate_bits);
    preparation.candidates = {mks_candidate, preparation.candidates{1}};
    preparation.candidate_source = "computed_subspace_plus_mks_eigen_complement";
    preparation.mks_complement = mks_record;
  endif
  attempts = struct ([]);
  graph = [];
  cluster = [];
  selected_strategy = 0;
  selected_X = [];
  selected_newton = [];
  A = net_widen (model.A_frozen, q, candidate_bits);
  for strategy = 1:min (2, numel (preparation.candidates))
    candidate_X = net_widen (preparation.candidates{strategy}, q, candidate_bits);
    mpbits (q);
    newton = candidate_newton_for_basis (A, candidate_X, ...
                                         job.cluster_dimension, q);
    corrected_X = candidate_X;
    if (newton.success)
      corrected_X = transform_basis (candidate_X, newton.final_Z, ...
                                     job.cluster_dimension, q);
    endif
    cluster_try = [];
    try
      graph_try = net_v_s2_graph (A, corrected_X, ...
                                  job.cluster_dimension, q);
      if (graph_try.pass)
        cluster_try = net_v_s2_cluster (graph_try, corrected_X, center, ...
                                        job, profile, q);
      endif
    catch exception
      graph_try = graph_exception (exception, rows (A), job.cluster_dimension);
    end_try_catch
    attempt = struct ("strategy", strategy, ...
      "candidate_source", preparation.candidate_source, ...
      "candidate_bits", candidate_bits, "evaluation_bits", q, ...
      "raw_candidate", candidate_X, "newton", newton, ...
      "corrected_candidate", corrected_X, "graph", graph_try, ...
      "cluster", cluster_try, "status", graph_try.status, ...
      "pass", ! isempty (cluster_try) && cluster_try.pass);
    if (isempty (attempts))
      attempts = attempt;
    else
      attempts(end + 1) = attempt;
    endif
    if (! isempty (cluster_try) && cluster_try.pass)
      graph = graph_try;
      cluster = cluster_try;
      selected_strategy = strategy;
      selected_X = corrected_X;
      selected_newton = newton;
      break;
    endif
    graph = graph_try;
    cluster = cluster_try;
  endfor
  if (selected_strategy == 0)
    selected_strategy = 1;
  endif
  % Assign fields incrementally.  This avoids Octave's struct constructor
  % expansion rules when a nested candidate record contains a struct array.
  result = struct ();
  result.id = job.id;
  result.tier = job.tier;
  result.kind = job.kind;
  if (! isempty (cluster)
      && isfield (cluster, "status") && cluster.pass)
    result.status = cluster.status;
    result.claim_status = cluster.claim_status;
    result.claim_quality = cluster.claim_quality;
    result.pass = true;
  else
    result.status = graph.status;
    result.claim_status = graph.claim_status;
    result.claim_quality = graph.claim_quality;
    if (! isempty (cluster) && isfield (cluster, "status"))
      result.status = cluster.status;
      result.claim_status = cluster.claim_status;
      result.claim_quality = cluster.claim_quality;
    endif
    result.pass = false;
  endif
  result.milestone_pass = result.pass && graph.nontrivial;
  result.expected_claim = job.expected;
  result.candidate_source = preparation.candidate_source;
  result.candidate_bits = candidate_bits;
  result.evaluation_bits = q;
  result.fixture = fixture;
  result.model_source = model.source;
  result.model_input_status = model.input_status;
  result.query_center = center;
  result.query_radius = radius;
  result.candidate_preparation = preparation;
  result.candidate_attempts = attempts;
  result.selected_strategy = selected_strategy;
  result.selected_candidate = selected_X;
  result.selected_newton = selected_newton;
  result.graph = graph;
  result.cluster = cluster;
  result.error_identifier = "";
  result.error_message = "";
endfunction

function result = graph_exception (exception, n, k)
  result = struct ("method", "neigt_riccati_graph_v1", ...
    "paper_algorithm_reproduction", false, "status", "FAILED_VERIFIER", ...
    "pass", false, "claim_status", "ERROR", "claim_quality", "not_identified", ...
    "nontrivial", k > 0 && k < n, "full_space_triviality", false, ...
    "basis_nonsingular", false, "preconditioner_residual_pass", false, ...
    "contraction_pass", false, "candidate_source", "", ...
    "candidate_C0_hash", "", "trials", struct ([]), ...
    "error_identifier", exception.identifier, "error_message", exception.message);
endfunction

function [candidate, result] = mks_eigen_complement (A, center, radius, ...
                                                     preparation, k, bits)
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    [V, D] = eig (A, "nobalance");
    values = diag (D);
    h = rows (A) - k;
    selected = false (1, columns (V));
    selected_indices = zeros (1, h);
    for target = 1:h
      best = 0;
      best_modulus = mp (0);
      for index = 1:numel (values)
        if (! selected(index) && abs (values(index) - center) > radius ...
            && (best == 0 || abs (values(index) - center) > best_modulus))
          best = index;
          best_modulus = abs (values(index) - center);
        endif
      endfor
      if (best == 0)
        error ("mplapack:neigt:VS2", ...
               "MKS computed eig complement did not find enough separated roots");
      endif
      selected(best) = true;
      selected_indices(target) = best;
    endfor
    q1 = preparation.selected_bases{end};
    candidate = [q1, V(:, selected_indices)];
    result = struct ("method", "computed_mks_nonzero_eigen_complement_v1", ...
      "candidate_only", true, "candidate_bits", bits, ...
      "selected_indices", selected_indices, "selected_values", values(selected_indices), ...
      "source", "public_eig_nobalance_outside_query_region", ...
      "query_center", center, "query_radius", radius, ...
      "raw_eigenvalue_hash", net_raw_hash (values, "VS2_MKS_complement_D"));
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function result = make_fixture (fixture, bits)
  regime = char (fixture.regime);
  n = fixture.n;
  if (strcmp (regime, "semisimple") || strcmp (regime, "jordan"))
    result = net_similarity_model (regime, n, 0, bits);
  elseif (strcmp (regime, "two_jordan"))
    result = net_similarity_model (regime, n, fixture.gap_exponent, bits);
  elseif (strcmp (regime, "mks_zero"))
    delta = net_dyadic_parameter (fixture.delta, bits);
    result = net_mks_model (n, fixture.m, delta, bits);
  else
    error ("mplapack:neigt:VS2", "unsupported V-S2 fixture %s", regime);
  endif
endfunction

function value = parse_center (text, bits)
  if (! ischar (text))
    error ("mplapack:neigt:VS2", "center must be a bounded string");
  endif
  if (! isempty (regexp (text, "^[0-9]+$", "once")))
    value = integer_mp (text, bits);
    return;
  endif
  token = regexp (text, "^1\\+2\\^(-[0-9]+)$", "tokens", "once");
  if (! isempty (token))
    exponent = integer_signed (token{1});
    value = mp (1) + net_pow2 (exponent, bits);
    return;
  endif
  error ("mplapack:neigt:VS2", "unsupported bounded center %s", text);
endfunction

function value = integer_mp (text, bits)
  value = mp (0);
  for index = 1:numel (text)
    value = value * mp (10) + mp (text(index) - "0");
  endfor
endfunction

function value = integer_signed (text)
  if (isempty (regexp (text, "^-[0-9]+$", "once")))
    error ("mplapack:neigt:VS2", "invalid signed bounded exponent");
  endif
  value = 0;
  for index = 2:numel (text)
    value = value * 10 - (text(index) - "0");
  endfor
endfunction

function result = candidate_newton_for_basis (A, X, k, q)
  result = struct ("method", "neigt_candidate_graph_newton_v1", ...
    "candidate_only", true, "success", false, "status", "NOT_RUN", ...
    "initial_Z", [], "final_Z", [], "steps", struct ([]), "steps_used", 0);
  try
    C0 = X \ (A * X);
    h = rows (A) - k;
    Z0 = -(C0((k + 1):rows(A), (k + 1):rows(A)) \ ...
           C0((k + 1):rows(A), 1:k));
    result = net_v_s2_newton (C0, k, Z0, q);
  catch exception
    result.status = "FAILED_PREPARATION";
    result.error_identifier = exception.identifier;
    result.error_message = exception.message;
  end_try_catch
endfunction

function result = transform_basis (X, Z, k, q)
  n = rows (X);
  h = n - k;
  transform = mp (zeros (n, n));
  transform(1:k, 1:k) = mp (eye (k));
  transform((k + 1):n, 1:k) = Z;
  transform((k + 1):n, (k + 1):n) = mp (eye (h));
  result = X * transform;
endfunction
