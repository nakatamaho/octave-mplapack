% NEIGT18: compatible simple eigenfactor boxes and individual-claim traps.
test_root = fileparts (fileparts (mfilename ("fullpath")));
private_root = fullfile (test_root, "examples", "neig_tiers", "private");
addpath (private_root);

saved_bits = mpbits ();
unwind_protect
  mpbits (256);
  bundle = net_manifest ();
  jobs = bundle.jobs.profiles.smoke.jobs;
  real_job = net_v_a1_job (jobs{17}, bundle.jobs.profiles.smoke, "smoke");
  complex_job = net_v_a1_job (jobs{18}, bundle.jobs.profiles.smoke, "smoke");
  defective_job = net_v_a1_job (jobs{19}, bundle.jobs.profiles.smoke, "smoke");
  assert (real_job.pass && real_job.milestone_pass);
  assert (complex_job.pass && complex_job.milestone_pass);
  assert (defective_job.milestone_pass && ! defective_job.pass);
  assert (strcmp (real_job.status, "CERTIFIED_EIGENFACTORS"));
  assert (strcmp (complex_job.status, "CERTIFIED_EIGENFACTORS"));
  assert (strcmp (defective_job.status, "INCONCLUSIVE_DEFECTIVE_INDIVIDUAL"));
  assert (real_job.certificate.roots_disjoint);
  assert (complex_job.certificate.roots_disjoint);
  assert (real_job.certificate.inverse_witness.nonsingular);
  assert (complex_job.certificate.inverse_witness.nonsingular);
  assert (real_job.certificate.compatibility.encloses_zero);
  assert (complex_job.certificate.compatibility.encloses_zero);
  assert (real_job.certificate.width_ratio <= real_job.certificate.useful_target);
  assert (complex_job.certificate.width_ratio <= complex_job.certificate.useful_target);

  % An arbitrary coherent phase gauge remains a valid simultaneous factor.
  q = 768;
  mpbits (q);
  pair = net_exact_similarity (4, q);
  J = mp (zeros (4, 4));
  simple_diagonal = [1, 2, 4, 8];
  for diagonal_index = 1:4
    J(diagonal_index,diagonal_index) = mp (simple_diagonal(diagonal_index));
  endfor
  real_A = pair.Y * J * pair.X;
  phase = mp (eye (4));
  phase(1,1) = net_mp_complex (mp (0), mp (1));
  phased_E = net_iv_cmatrix_mul (real_job.certificate.E_box, ...
                                 net_iv_cmatrix_point (phase, q), q);
  phased = net_v_a1_validate_assembly (real_A, phased_E, ...
                                       real_job.certificate.Lambda_box, q);
  assert (phased.encloses_zero);

  % A duplicated factor column and a Lambda-only permutation are rejected;
  % neither can manufacture a false compatible factorization.
  E_bad = real_job.certificate.E_box;
  E_bad.rl(:,2) = E_bad.rl(:,1);
  E_bad.rh(:,2) = E_bad.rh(:,1);
  E_bad.il(:,2) = E_bad.il(:,1);
  E_bad.ih(:,2) = E_bad.ih(:,1);
  rejected_duplicate = net_v_a1_validate_assembly (real_A, ...
                                                   E_bad, real_job.certificate.Lambda_box, q);
  assert (! rejected_duplicate.encloses_zero);
  Lambda_bad = real_job.certificate.Lambda_box;
  Lambda_bad.rl(1,1) = real_job.certificate.Lambda_box.rl(2,2);
  Lambda_bad.rh(1,1) = real_job.certificate.Lambda_box.rh(2,2);
  Lambda_bad.il(1,1) = real_job.certificate.Lambda_box.il(2,2);
  Lambda_bad.ih(1,1) = real_job.certificate.Lambda_box.ih(2,2);
  Lambda_bad.rl(2,2) = real_job.certificate.Lambda_box.rl(1,1);
  Lambda_bad.rh(2,2) = real_job.certificate.Lambda_box.rh(1,1);
  Lambda_bad.il(2,2) = real_job.certificate.Lambda_box.il(1,1);
  Lambda_bad.ih(2,2) = real_job.certificate.Lambda_box.ih(1,1);
  rejected_permutation = net_v_a1_validate_assembly (real_A, ...
                                                     real_job.certificate.E_box, Lambda_bad, q);
  assert (! rejected_permutation.encloses_zero);

  % Repeated-root individual vectors are not promoted to an all-simple
  % eigenfactorization; the non-isolated graph attempt must fail closed.
  repeated = net_similarity_model ("semisimple", 4, 0, 256);
  [Vr, Dr] = eig (repeated.A_frozen, "nobalance");
  Vr = net_widen (Vr, q, 256);
  Dr = net_widen (Dr, q, 256);
  repeated_factor = net_v_a1_factors (net_widen (repeated.A_frozen, q, 256), ...
                                      Vr, Dr, q, -40);
  assert (! repeated_factor.pass);
  assert (any (strcmp (repeated_factor.status, ...
                       {"INCONCLUSIVE_GRAPH", "INCONCLUSIVE_NONISOLATED_ROOTS", ...
                        "INCONCLUSIVE_FACTOR_INVERSE"})));
  fprintf ("PASS: NEIGT18 compatible eigenfactor boxes, gauges, and repeated-root traps\n");
unwind_protect_cleanup
  mpbits (saved_bits);
  if (any (strcmp (strsplit (path (), pathsep), private_root)))
    rmpath (private_root);
  endif
end_unwind_protect
