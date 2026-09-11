% Run one NEIGT18 compatible-factor job.
function result = net_v_a1_job (job, profile_data, profile)
  result = status_template ();
  result.id = job.id;
  result.tier = job.tier;
  result.kind = job.kind;
  result.candidate_source = job.candidate_source;
  result.candidate_bits = profile_data.source_bits;
  result.evaluation_bits = profile_data.evaluation_bits;
  source_bits = profile_data.source_bits;
  q = profile_data.evaluation_bits;
  saved_bits = mpbits ();
  unwind_protect
    try
      regime = char (job.fixture.regime);
      if (strcmp (regime, "real_simple"))
        model = net_v_a1_model (regime, job.fixture.n, source_bits);
      elseif (strcmp (regime, "complex_simple"))
        model = net_v_a1_model (regime, job.fixture.n, source_bits);
      elseif (strcmp (regime, "defective_block"))
        result = defective_guard (job, profile_data, profile);
        return;
      else
        error ("mplapack:neigt:VA1", "unsupported VA1 regime %s", regime);
      endif
      mpbits (source_bits);
      [V, D, W] = eig (model.A_frozen, "nobalance");
      result.raw_V = V;
      result.raw_D = D;
      result.raw_W = W;
      mpbits (q);
      A = net_widen (model.A_frozen, q, source_bits);
      Vq = net_widen (V, q, source_bits);
      Dq = net_widen (D, q, source_bits);
      exponent = -40;
      if (strcmp (profile, "demo"))
        exponent = -64;
      endif
      factors = net_v_a1_factors (A, Vq, Dq, q, exponent);
      result.certificate = factors;
      result.details = factors;
      result.status = factors.status;
      result.claim_status = factors.claim_status;
      result.claim_quality = factors.claim_quality;
      result.pass = factors.pass;
      result.milestone_pass = result.pass;
      result.raw_V_hash = factors.raw_V_hash;
      result.raw_D_hash = factors.raw_D_hash;
      result.raw_W_hash = net_raw_hash (W, [job.id, "_raw_W"]);
      result.raw_lambda_hash = factors.raw_lambda_hash;
      result.input_hash = net_raw_hash (model.A_frozen, [job.id, "_A_frozen"]);
      result.source = model.source;
      result.input_status = model.input_status;
    catch exception
      result.status = "FAILED_VERIFIER";
      result.claim_status = "ERROR";
      result.claim_quality = "not_identified";
      result.error_identifier = exception.identifier;
      result.error_message = exception.message;
    end_try_catch
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function result = defective_guard (job, profile_data, profile)
  bits = profile_data.source_bits;
  q = profile_data.evaluation_bits;
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    model = net_v_a1_model ("defective_block", job.fixture.n, bits);
    A = net_widen (model.A_frozen, q, bits);
    preparation = net_v_s2_candidate (model.A_frozen, mp (1), net_pow2 (-2, bits), 2, bits);
    X = net_widen (preparation.candidates{1}, q, bits);
    graph = net_v_s2_graph (A, X, 2, q);
    result = status_template ();
    result.id = job.id;
    result.tier = job.tier;
    result.kind = job.kind;
    result.candidate_source = job.candidate_source;
    result.candidate_bits = bits;
    result.evaluation_bits = q;
    result.certificate = graph;
    result.details = graph;
    result.claim_status = "INDIVIDUAL_FACTORS_REFUSED_DEFECTIVE_BLOCK";
    result.claim_quality = "fail_closed";
    result.status = "INCONCLUSIVE_DEFECTIVE_INDIVIDUAL";
    result.pass = false;
    result.milestone_pass = graph.pass && graph.nontrivial;
    result.input_hash = net_raw_hash (model.A_frozen, [job.id, "_A_frozen"]);
    result.source = model.source;
    result.input_status = model.input_status;
    result.error_message = "A true Jordan block is not diagonalizable; block Schur is NEIGT19.";
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function result = status_template ()
  result = struct ("id", "", "tier", "", "kind", "", "status", ...
    "NOT_IMPLEMENTED", "pass", false, "milestone_pass", false, ...
    "claim_status", "", "claim_quality", "", "details", [], ...
    "candidate_source", "", "candidate_bits", NaN, "evaluation_bits", NaN, ...
    "raw_V_hash", "", "raw_D_hash", "", "raw_W_hash", "", ...
    "raw_B_hash", "", "raw_U_hash", "", "raw_s_hash", "", ...
    "raw_lambda_hash", "", "certificate", [], "input_hash", "", ...
    "source", "", "input_status", "", "target", "", "raw_V", [], ...
    "raw_D", [], "raw_W", [], "error_identifier", "", "error_message", "");
endfunction
