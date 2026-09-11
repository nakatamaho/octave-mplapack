% NEIGT14: counted all-spectrum verification on raw highest-work candidates.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "neig_tiers"));
addpath (fullfile (test_root, "examples", "neig_tiers", "private"));

saved_bits = mpbits ();
unwind_protect
  result = mp_neig_verify_examples ("smoke", struct ("tier", "V-S"));
  assert (result.scope_ok);
  assert (result.coverage.verification_job_count == 16);
  assert (result.coverage.vs1_job_count == 8);
  assert (result.coverage.vs1_complete);
  vs1 = result.jobs (strncmp ({result.jobs.id}, "VS1-", 4));
  assert (numel (vs1) == 8);
  for index = 1:numel (vs1)
    certificate = vs1(index).certificate;
    assert (strcmp (vs1(index).status, "PASS"));
    assert (vs1(index).pass);
    assert (strcmp (certificate.method, "neigt_similarity_gershgorin_v1"));
    assert (! certificate.paper_algorithm_reproduction);
    assert (certificate.all_roots);
    assert (certificate.counted_roots == certificate.n);
    assert (certificate.singleton_count == certificate.n);
    assert (certificate.singleton_useful);
    assert (certificate.useful);
    assert (certificate.max_radius / certificate.verified_frobenius_upper ...
            <= certificate.usefulness_target);
    assert (! isempty (vs1(index).raw_V_hash));
    assert (! isempty (vs1(index).raw_D_hash));
    assert (! isempty (vs1(index).raw_W_hash));
  endfor

  % A singular inverse candidate must fail closed and never create a count.
  mpbits (256);
  A = mp ([1, 2; 0, 3]);
  X = mp (eye (2));
  T = A;
  R = mp (zeros (2));
  failed = net_v_s1_gershgorin (A, X, T, R, 256, -40);
  assert (! failed.coverage);
  assert (! failed.inverse_residual_pass);
  assert (strcmp (failed.status, "INCONCLUSIVE_INVERSE_RESIDUAL"));

  % A touching pair is a connected component, not two certified singletons.
  R = mp (eye (2));
  touching = net_v_s1_gershgorin (A, X, T, R, 256, -40);
  assert (touching.counted_roots == 2);
  assert (touching.component_count == 1);
  assert (! touching.singleton_useful);
  assert (strcmp (touching.status, "CERTIFIED_ALL_NOT_USEFUL"));
  fprintf ("PASS: NEIGT14 counted all-spectrum certificates and fail-closed negatives\n");
unwind_protect_cleanup
  mpbits (saved_bits);
  if (any (strcmp (strsplit (path (), pathsep), ...
             fullfile (test_root, "examples", "neig_tiers", "private"))))
    rmpath (fullfile (test_root, "examples", "neig_tiers", "private"));
  endif
  if (any (strcmp (strsplit (path (), pathsep), ...
             fullfile (test_root, "examples", "neig_tiers"))))
    rmpath (fullfile (test_root, "examples", "neig_tiers"));
  endif
end_unwind_protect
