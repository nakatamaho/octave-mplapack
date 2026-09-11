% Run one bounded computed V-S2 candidate schedule and invariant-graph proof.
% Cluster separation and projector claims are intentionally deferred to the
% next milestone; this job records only the nontrivial invariant basis.
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
  attempts = struct ([]);
  graph = [];
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
    graph_try = net_v_s2_graph (A, corrected_X, ...
                                job.cluster_dimension, q);
    attempt = struct ("strategy", strategy, ...
      "candidate_source", preparation.candidate_source, ...
      "candidate_bits", candidate_bits, "evaluation_bits", q, ...
      "raw_candidate", candidate_X, "newton", newton, ...
      "corrected_candidate", corrected_X, "graph", graph_try, ...
      "status", graph_try.status, "pass", graph_try.pass);
    if (isempty (attempts))
      attempts = attempt;
    else
      attempts(end + 1) = attempt;
    endif
    if (graph_try.pass)
      graph = graph_try;
      selected_strategy = strategy;
      selected_X = corrected_X;
      selected_newton = newton;
      break;
    endif
    graph = graph_try;
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
  result.status = graph.status;
  result.claim_status = graph.claim_status;
  result.claim_quality = graph.claim_quality;
  result.pass = false;
  result.milestone_pass = graph.pass && graph.nontrivial;
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
  result.error_identifier = "";
  result.error_message = "";
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
