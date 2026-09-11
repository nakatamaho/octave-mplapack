% Verified finite generalized-pencil reduction for NEIGT20.
% The only spectral candidate is eig(C0), where C0 is obtained by a public
% solve.  The proof is made against an outward enclosure of the exact
% C=B^(-1)A and then mapped back to the original A,B pencil.
function result = net_v_a2_job (job, profile_data, profile)
  result = status_template (job, profile_data);
  bits = profile_data.source_bits;
  q = profile_data.evaluation_bits;
  regime = char (job.fixture.regime);
  saved_bits = mpbits ();
  unwind_protect
    try
      model = net_v_a2_model (regime, job.fixture.n, bits);
      result.source = model.source;
      result.input_status = model.input_status;
      result.input_hash_A = net_raw_hash (model.A_frozen, [job.id, "_A_frozen"]);
      result.input_hash_B = net_raw_hash (model.B_frozen, [job.id, "_B_frozen"]);
      result.input_hash_C = net_raw_hash (model.C_frozen, [job.id, "_C_model"]);

      % Candidate solve reduction.  These values remain separately recorded
      % from the exact model and from every interval proof target.
      mpbits (bits);
      I = mp (eye (rows (model.B_frozen)));
      RB_candidate = model.B_frozen \ I;
      C0_candidate = RB_candidate * model.A_frozen;
      result.candidate_source = "solve_reduction_finite_pencil";
      result.candidate_bits = bits;
      result.raw_RB_hash = net_raw_hash (RB_candidate, [job.id, "_raw_RB"]);
      result.raw_C0_hash = net_raw_hash (C0_candidate, [job.id, "_raw_C0"]);

      % Prove B nonsingular and enclose C=B^(-1)A entrywise.
      mpbits (q);
      RB = net_widen (RB_candidate, q, bits);
      C0 = net_widen (C0_candidate, q, bits);
      A = net_widen (model.A_frozen, q, bits);
      B = net_widen (model.B_frozen, q, bits);
      reduction = net_v_a2_reduction (A, B, RB, C0, q);
      result.reduction = reduction;
      result.eB = reduction.eB;
      result.fB = reduction.fB;
      result.etaB = reduction.etaB;
      result.B_inverse_residual = reduction.B_inverse_residual;
      result.A_minus_BC0 = reduction.A_minus_BC0;
      result.RB_A_minus_BC0 = reduction.RB_A_minus_BC0;
      result.B_nonsingular_proof = reduction.B_nonsingular;
      if (! reduction.pass)
        result.status = reduction.status;
        result.claim_status = "INCONCLUSIVE";
        result.milestone_pass = false;
        return;
      endif
      A_box = reduction.A_box;
      B_box = reduction.B_box;
      C_box = reduction.C_box;
      result.C0_candidate = C0_candidate;
      result.C_box = C_box;
      result.reduction_method = "proved_solve_reduction_finite_pencil";

      % Public eig supplies candidates only.  V-S1 sees the proved C box.
      [V, D, Wc] = eig (C0, "nobalance");
      result.raw_V = V;
      result.raw_D = D;
      result.raw_Wc = Wc;
      result.raw_V_hash = net_raw_hash (V, [job.id, "_raw_V_C0"]);
      result.raw_D_hash = net_raw_hash (D, [job.id, "_raw_D_C0"]);
      result.raw_W_hash = net_raw_hash (Wc, [job.id, "_raw_W_C0"]);
      Vq = net_widen (V, q, bits);
      Dq = net_widen (D, q, bits);
      Rq = Vq \ mp (eye (rows (Vq)));
      finite = net_v_s1_gershgorin (C0, Vq, Dq, Rq, q, -32, ...
                                     struct ("A_box", C_box));
      result.finite_certificate = finite;
      result.finite_root_count = finite.counted_roots;
      result.finite_root_coverage = finite.coverage ...
                                    && finite.counted_roots == rows (C0);
      result.finite_pass = result.finite_root_coverage ...
                           && finite.inverse_residual_pass;

      % Map the left C eigenvectors back by B^(-H).  This is a candidate
      % calculation; the original-pencil residual is independently widened.
      W = ctranspose (net_widen (model.B_frozen, q, bits)) \ net_widen (Wc, q, bits);
      result.raw_W_pencil_hash = net_raw_hash (W, [job.id, "_raw_W_pencil"]);
      result.right_residual_box = net_iv_cmatrix_sub ...
        (net_iv_cmatrix_mul (A_box, net_iv_cmatrix_point (Vq, q), q), ...
         net_iv_cmatrix_mul (net_iv_cmatrix_mul (B_box, ...
          net_iv_cmatrix_point (Vq, q), q), net_iv_cmatrix_point (Dq, q), q), q);
      left_A = net_iv_cmatrix_mul (net_iv_cmatrix_conjtrans (net_iv_cmatrix_point (W, q)), A_box, q);
      left_B = net_iv_cmatrix_mul (net_iv_cmatrix_conjtrans (net_iv_cmatrix_point (W, q)), B_box, q);
      % For columns W satisfying C'*W=W*D', the pencil convention is
      % W'*A-D*W'*B; the diagonal factor is D, not ctranspose(D).
      left_rhs = net_iv_cmatrix_mul (net_iv_cmatrix_point (Dq, q), left_B, q);
      result.left_residual_box = net_iv_cmatrix_sub (left_A, left_rhs, q);
      % These are residual evaluations of approximate candidates, not exact
      % identities.  Therefore zero containment is diagnostic only; the
      % acceptance predicate uses their outward finite norm bounds.
      result.right_residual_norm_upper = net_iv_cmatrix_fro_upper ...
        (result.right_residual_box, q);
      result.left_residual_norm_upper = net_iv_cmatrix_fro_upper ...
        (result.left_residual_box, q);
      result.right_residual_encloses_zero = contains_zero (result.right_residual_box);
      result.left_residual_encloses_zero = contains_zero (result.left_residual_box);
      result.residual_target = net_pow2 (-64, q);
      result.residual_accuracy_pass = result.right_residual_norm_upper <= result.residual_target ...
                                      && result.left_residual_norm_upper <= result.residual_target;
      result.finite_pass = result.finite_pass && result.residual_accuracy_pass;

      result.graph = [];
      result.cluster = [];
      result.original_pencil_graph_residual = [];
      if (strcmp (regime, "defective_cluster"))
        preparation = net_v_s2_candidate (C0, mp (1), net_pow2 (-2, bits), ...
                                          job.leading_cluster_dimension, bits);
        result.graph_candidate_source = preparation.candidate_source;
        result.graph_candidate_bits = bits;
        graph = [];
        cluster = [];
        selected_X = [];
        % Both bounded candidate strategies are candidate-only.  The proof
        % below decides which, if either, has a separated complement.
        for strategy = 1:min (2, numel (preparation.candidates))
          X_try = net_widen (preparation.candidates{strategy}, q, bits);
          graph_try = net_v_s2_graph (C0, X_try, ...
            job.leading_cluster_dimension, q, struct ("A_box", C_box));
          if (graph_try.pass && graph_try.nontrivial)
            % VA2 uses a fixed 2^-16 cluster-radius target.  This is a
            % separation/usefulness contract for the n=6 pencil, not a
            % post-result tolerance and not the VS2 target.
            cluster_job = struct ("fixture", struct ("regime", "jordan", ...
              "query_radius", "1/4"), "cluster_dimension", ...
              job.leading_cluster_dimension, "cluster_radius_target_exponent", ...
              job.cluster_radius_target_exponent);
            cluster_try = net_v_s2_cluster (graph_try, X_try, mp (1), ...
                                            cluster_job, profile, q);
          else
            cluster_try = [];
          endif
          graph = graph_try;
          cluster = cluster_try;
          selected_X = X_try;
          if (! isempty (cluster_try) && cluster_try.pass)
            break;
          endif
        endfor
        result.graph = graph;
        result.cluster = cluster;
        if (graph.pass && graph.nontrivial && isstruct (cluster) ...
            && cluster.pass)
          Y1 = graph.Y1_box;
          MY = net_iv_cmatrix_mul (B_box, Y1, q);
          pencil_lhs = net_iv_cmatrix_mul (A_box, Y1, q);
          pencil_rhs = net_iv_cmatrix_mul (MY, graph.M_box, q);
          result.original_pencil_graph_residual = net_iv_cmatrix_sub ...
            (pencil_lhs, pencil_rhs, q);
          result.original_pencil_graph_encloses_zero = contains_zero ...
            (result.original_pencil_graph_residual);
        else
          result.original_pencil_graph_encloses_zero = false;
        endif
      else
        result.original_pencil_graph_encloses_zero = true;
      endif
      if (! result.finite_pass)
        result.status = "INCONCLUSIVE_FINITE_ROOT_COVERAGE";
        result.claim_status = "INCONCLUSIVE";
        result.pass = false;
      elseif (strcmp (regime, "defective_cluster") ...
              && (! isstruct (result.cluster) || ! result.cluster.pass ...
                  || ! result.original_pencil_graph_encloses_zero))
        result.status = "INCONCLUSIVE_DEFECTIVE_CLUSTER";
        result.claim_status = "INCONCLUSIVE";
        result.pass = false;
      else
        result.status = "CERTIFIED_ALL_FINITE";
        result.claim_status = "CERTIFIED_ALL_FINITE";
        if (strcmp (regime, "defective_cluster"))
          result.claim_status = "CERTIFIED_ALL_FINITE_AND_CLUSTER";
        endif
        result.pass = true;
      endif
      result.milestone_pass = result.pass;
      result.claim_quality = "proved_reduction_binds_original_A_B";
    catch exception
      result.status = "FAILED_VERIFIER";
      result.claim_status = "ERROR";
      result.claim_quality = "not_identified";
      result.error_identifier = exception.identifier;
      result.error_message = exception.message;
      result.pass = false;
      result.milestone_pass = false;
    end_try_catch
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function result = status_template (job, profile_data)
  result = struct ("id", job.id, "tier", job.tier, "kind", job.kind, ...
    "status", "NOT_IMPLEMENTED", "pass", false, "milestone_pass", false, ...
    "claim_status", "", "claim_quality", "", "candidate_source", "", ...
    "candidate_bits", profile_data.source_bits, ...
    "evaluation_bits", profile_data.evaluation_bits, "source", "", ...
    "input_status", "", "input_hash_A", "", "input_hash_B", "", ...
    "input_hash_C", "", "raw_RB_hash", "", "raw_C0_hash", "", ...
    "raw_V_hash", "", "raw_D_hash", "", "raw_W_hash", "", ...
    "raw_W_pencil_hash", "", "raw_V", [], "raw_D", [], "raw_Wc", [], ...
    "finite_certificate", [], "graph", [], "cluster", [], ...
    "finite_root_count", 0, "finite_root_coverage", false, ...
    "finite_pass", false, "eB", mp ("NaN"), "fB", mp ("NaN"), ...
    "etaB", mp ("NaN"), "right_residual_norm_upper", mp ("NaN"), ...
    "left_residual_norm_upper", mp ("NaN"), ...
    "right_residual_encloses_zero", false, "left_residual_encloses_zero", false, ...
    "residual_accuracy_pass", false, "original_pencil_graph_encloses_zero", false, ...
    "error_identifier", "", "error_message", "");
endfunction

function result = contains_zero (matrix)
  result = all (matrix.rl(:) <= mp (0) & matrix.rh(:) >= mp (0) ...
                & matrix.il(:) <= mp (0) & matrix.ih(:) >= mp (0));
endfunction
