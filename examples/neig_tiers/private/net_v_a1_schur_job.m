% Run NEIGT19 genuine triangular and defective block-Schur certificates.
function result = net_v_a1_schur_job (job, profile_data, profile)
  result = status_template ();
  regime = char (job.fixture.regime);
  bits = profile_data.source_bits;
  q = profile_data.evaluation_bits;
  saved_bits = mpbits ();
  unwind_protect
    try
      model = net_v_a1_model (regime, job.fixture.n, bits);
      A = net_widen (model.A_frozen, q, bits);
      mpbits (q);
      if (strcmp (regime, "real_simple") || strcmp (regime, "complex_simple"))
        base = net_v_a1_job (job, profile_data, profile);
        result = base;
        if (! base.pass)
          return;
        endif
        factors = base.certificate;
        qr = net_v_a1_interval_qr (factors.E_box, q);
        if (! qr.pass)
          result.status = qr.status;
          result.claim_status = "INCONCLUSIVE";
          result.pass = false;
          result.milestone_pass = false;
          result.certificate = qr;
          result.details = qr;
          return;
        endif
        schur = direct_schur (A, qr, 0, q);
        schur.factor_certificate = factors;
        result.certificate = schur;
        result.details = schur;
        result.status = schur.status;
        result.claim_status = schur.claim_status;
        result.claim_quality = schur.claim_quality;
        result.pass = schur.pass;
        result.milestone_pass = schur.pass;
      elseif (strcmp (regime, "defective_block"))
        [graph, X] = defective_graph (model, bits, q);
        if (! graph.pass || ! graph.nontrivial)
          result.status = "INCONCLUSIVE_DEFECTIVE_GRAPH";
          result.claim_status = "INCONCLUSIVE";
          result.error_message = "defective invariant graph did not pass";
          return;
        endif
        H = concatenate_columns (graph.Y1_box, ...
                                 column_range (net_iv_cmatrix_point (X, q), 3, 4));
        qr = net_v_a1_interval_qr (H, q);
        if (! qr.pass)
          result.status = qr.status;
          result.claim_status = "INCONCLUSIVE";
          result.certificate = qr;
          result.details = qr;
          return;
        endif
        schur = direct_schur (A, qr, 2, q);
        schur.graph = graph;
        schur.claim_status = "CERTIFIED_BLOCK_SCHUR";
        schur.status = "CERTIFIED_BLOCK_SCHUR";
        schur.pass = graph.pass && qr.pass && schur.lower_left_zero_proof;
        schur.milestone_pass = schur.pass;
        result.id = job.id;
        result.tier = job.tier;
        result.kind = job.kind;
        result.candidate_source = job.candidate_source;
        result.candidate_bits = bits;
        result.evaluation_bits = q;
        result.certificate = schur;
        result.details = schur;
        result.status = schur.status;
        result.claim_status = schur.claim_status;
        result.claim_quality = "invariant_block_existence";
        result.pass = schur.pass;
        result.milestone_pass = schur.pass;
        result.input_hash = net_raw_hash (model.A_frozen, [job.id, "_A_frozen"]);
        result.source = model.source;
        result.input_status = model.input_status;
      else
        error ("mplapack:neigt:VA1", "unsupported VA1 Schur regime %s", regime);
      endif
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

function [graph, X] = defective_graph (model, bits, q)
  preparation = net_v_s2_candidate (model.A_frozen, mp (1), net_pow2 (-2, bits), 2, bits);
  X = net_widen (preparation.candidates{1}, q, bits);
  graph = net_v_s2_graph (net_widen (model.A_frozen, q, bits), X, 2, q);
endfunction

function result = direct_schur (A, qr, block_dimension, q)
  Q = qr.Q_box;
  T_direct = net_iv_cmatrix_mul (net_iv_cmatrix_mul ...
    (net_iv_cmatrix_conjtrans (Q), net_iv_cmatrix_point (A, q), q), Q, q);
  T = T_direct;
  n = rows (T.rl);
  lower_zero = false;
  for i = 1:n
    for j = 1:(i - 1)
      if (block_dimension == 0)
        T = set_entry (T, i, j, net_iv_complex (mp (0), mp (0), mp (0), mp (0)));
      elseif (i > block_dimension && j <= block_dimension)
        T = set_entry (T, i, j, net_iv_complex (mp (0), mp (0), mp (0), mp (0)));
      endif
    endfor
  endfor
  if (block_dimension == 0)
    lower_zero = all_lower_zero (T);
  else
    lower_zero = lower_left_zero (T, block_dimension);
  endif
  if (block_dimension == 0)
    status = "CERTIFIED_SCHUR_TRIANGULAR";
    claim = status;
    quality = "algebraic_lower_zero_from_compatible_E";
  else
    status = "CERTIFIED_BLOCK_SCHUR";
    claim = status;
    quality = "algebraic_lower_left_zero_from_invariant_graph";
  endif
  result = struct ("method", "neigt_interval_qr_schur_v1", ...
    "paper_algorithm_reproduction", false, "status", status, ...
    "claim_status", claim, "claim_quality", quality, "pass", ...
    qr.pass && lower_zero, "milestone_pass", qr.pass && lower_zero, ...
    "Q_box", Q, "R_box", qr.R_box, "T_box", T, ...
    "T_direct", T_direct, "block_dimension", block_dimension, ...
    "lower_left_zero_proof", lower_zero, ...
    "lower_triangle_algebraically_forced", block_dimension == 0, ...
    "normalization_lower", qr.diagonal_lower, ...
    "normalization_upper", qr.diagonal_upper, ...
    "all_normalizations_positive", qr.all_normalizations_positive);
endfunction

function result = all_lower_zero (matrix)
  result = true;
  for i = 1:rows (matrix.rl)
    for j = 1:(i - 1)
      box = entry_box (matrix, i, j);
      result = result && box.rl == mp (0) && box.rh == mp (0) ...
               && box.il == mp (0) && box.ih == mp (0);
    endfor
  endfor
endfunction

function result = lower_left_zero (matrix, k)
  result = true;
  for i = (k + 1):rows (matrix.rl)
    for j = 1:k
      box = entry_box (matrix, i, j);
      result = result && box.rl == mp (0) && box.rh == mp (0) ...
               && box.il == mp (0) && box.ih == mp (0);
    endfor
  endfor
endfunction

function result = concatenate_columns (left, right)
  result = left;
  result.rl = [left.rl, right.rl];
  result.rh = [left.rh, right.rh];
  result.il = [left.il, right.il];
  result.ih = [left.ih, right.ih];
endfunction

function result = column_range (matrix, first, last)
  result = matrix;
  result.rl = matrix.rl(:, first:last);
  result.rh = matrix.rh(:, first:last);
  result.il = matrix.il(:, first:last);
  result.ih = matrix.ih(:, first:last);
endfunction

function result = set_entry (matrix, i, j, value)
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
  result = matrix;
endfunction

function result = entry_box (matrix, i, j)
  if (isscalar (matrix.rl))
    result = net_iv_complex (matrix.rl, matrix.rh, matrix.il, matrix.ih);
  else
    result = net_iv_complex (matrix.rl(i,j), matrix.rh(i,j), ...
                             matrix.il(i,j), matrix.ih(i,j));
  endif
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
