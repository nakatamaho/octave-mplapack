% NEIGT20: finite generalized-pencil reduction and original-pencil binding.
test_root = fileparts (fileparts (mfilename ("fullpath")));
private_root = fullfile (test_root, "examples", "neig_tiers", "private");
addpath (private_root);

saved_bits = mpbits ();
unwind_protect
  mpbits (128);
  exact = net_v_a2_model ("real_simple", 6, 128);
  assert (norm (exact.A_frozen - exact.B_frozen * exact.C_frozen, "fro") == mp (0));

  bundle = net_manifest ();
  profile_data = bundle.jobs.profiles.smoke;
  real_job = net_v_a2_job (profile_data.jobs{20}, profile_data, "smoke");
  complex_job = net_v_a2_job (profile_data.jobs{21}, profile_data, "smoke");
  defective_job = net_v_a2_job (profile_data.jobs{22}, profile_data, "smoke");
  for item = {real_job, complex_job}
    current = item{1};
    assert (current.pass && current.milestone_pass);
    assert (strcmp (current.status, "CERTIFIED_ALL_FINITE"));
    assert (current.B_nonsingular_proof && current.finite_root_coverage);
    assert (current.finite_root_count == 6);
    assert (current.residual_accuracy_pass);
    assert (current.right_residual_norm_upper <= current.residual_target);
    assert (current.left_residual_norm_upper <= current.residual_target);
    assert (numel (current.input_hash_A) == 64 && numel (current.input_hash_B) == 64);
    assert (strcmp (current.reduction_method, ...
                    "proved_solve_reduction_finite_pencil"));
  endfor
  assert (defective_job.pass && defective_job.milestone_pass);
  assert (strcmp (defective_job.claim_status, ...
                  "CERTIFIED_ALL_FINITE_AND_CLUSTER"));
  assert (defective_job.graph.pass && defective_job.graph.nontrivial);
  assert (defective_job.cluster.pass);
  assert (defective_job.original_pencil_graph_encloses_zero);
  assert (defective_job.finite_root_count == 6);

  % Singular B and a deliberately useless inverse candidate must fail closed.
  A = mp (eye (3));
  B = A;
  B(3,3) = mp (0);
  singular = net_v_a2_reduction (A, B, A, A, 128);
  assert (! singular.pass);
  assert (strcmp (singular.status, "INCONCLUSIVE_B_NONSINGULARITY"));
  B = mp (eye (3));
  zero_R = mp (zeros (3));
  zero_candidate = net_v_a2_reduction (A, B, zero_R, zero_R, 128);
  assert (! zero_candidate.pass);
  assert (zero_candidate.eB >= mp (1));
  assert (strcmp (zero_candidate.status, "INCONCLUSIVE_B_NONSINGULARITY"));
  fprintf ("PASS: NEIGT20 finite pencils, mapped residuals, defective cluster, and fail-closed reductions\n");
unwind_protect_cleanup
  mpbits (saved_bits);
  if (any (strcmp (strsplit (path (), pathsep), private_root)))
    rmpath (private_root);
  endif
end_unwind_protect
