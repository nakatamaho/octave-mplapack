% NEIGT15: bounded candidate preparation and verified invariant graphs.
test_root = fileparts (fileparts (mfilename ("fullpath")));
private_root = fullfile (test_root, "examples", "neig_tiers", "private");
addpath (private_root);

saved_bits = mpbits ();
unwind_protect
  mpbits (256);
  % An exact synthetic graph with a nonzero quadratic term.  Its invariant
  % graph is used only as an independent construction check, never as input
  % to the computed verification jobs.
  Z_true = mp ([1/16, -1/32; 1/64, 1/128]);
  C11 = mp ([1, 0; 0, 2]);
  C22 = mp ([4, 0; 0, 5]);
  C12 = mp ([1, 1/2; 1/4, 1]);
  C21 = -(C22 * Z_true) + Z_true * C11 + Z_true * C12 * Z_true;
  C = [C11, C12; C21, C22];

  newton = net_v_s2_newton (C, 2, mp (zeros (2)), 256);
  assert (newton.candidate_only && newton.success);
  assert (newton.steps_used <= 4);
  assert (newton.steps(end).residual_after < net_pow2 (-64, 256));

  graph = net_v_s2_graph (C, mp (eye (4)), 2, 256);
  assert (graph.pass && graph.nontrivial);
  assert (strcmp (graph.status, "CERTIFIED_INVARIANT_BASIS"));
  assert (strcmp (graph.method, "neigt_riccati_graph_v1"));
  assert (! graph.paper_algorithm_reproduction);
  assert (graph.preconditioner_residual_pass && graph.contraction_pass);
  assert (numel (graph.trials) >= 1 && numel (graph.trials) <= 8);
  assert (graph.trials(end).self_map && graph.trials(end).contraction);
  assert (isequal (size (graph.Z_box.rl), [2, 2]));
  assert (isequal (size (graph.Y1_box.rl), [4, 2]));

  wrong_transpose = net_v_s2_graph (C, mp (eye (4)), 2, 256, ...
                                    struct ("transpose_mode", "conjugating"));
  assert (! wrong_transpose.pass);
  assert (strcmp (wrong_transpose.status, ...
                  "UNSUPPORTED_WRONG_KRONECKER_TRANSPOSE"));

  singular_preconditioner = net_v_s2_graph ...
    (C, mp (eye (4)), 2, 256, struct ("preconditioner", mp (zeros (4))));
  assert (! singular_preconditioner.pass);
  assert (! singular_preconditioner.preconditioner_residual_pass);

  C_large = C;
  C_large(1,3) = net_pow2 (200, 256);
  failed_contraction = net_v_s2_graph (C_large, mp (eye (4)), 2, 256);
  assert (! failed_contraction.pass);
  assert (strcmp (failed_contraction.status, "INCONCLUSIVE_CONTRACTION"));

  manifest = net_manifest ();
  for job_index = 9:10
    job = manifest.jobs.profiles.smoke.jobs{job_index};
    computed = net_v_s2_job (job, manifest.cases.profiles.smoke, "smoke");
    assert (computed.milestone_pass);
    assert (strcmp (computed.claim_status, "CERTIFIED_INVARIANT_BASIS"));
    assert (computed.graph.nontrivial);
    assert (strcmp (computed.candidate_source, ...
                    "computed_subspace_bounded_schedule"));
    assert (numel (computed.candidate_preparation.records) == 3);
    assert (computed.candidate_preparation.records(1).node_count == 16);
    assert (computed.candidate_preparation.records(2).node_count == 32);
    assert (computed.candidate_preparation.records(3).node_count == 64);
    assert (computed.candidate_preparation.records(3).failed_nodes == 0);
    assert (computed.selected_strategy >= 1 && computed.selected_strategy <= 2);
  endfor

  fprintf ("PASS: NEIGT15 bounded candidates, Riccati graph, and fail-closed negatives\n");
unwind_protect_cleanup
  mpbits (saved_bits);
  if (any (strcmp (strsplit (path (), pathsep), private_root)))
    rmpath (private_root);
  endif
end_unwind_protect
