% NEIGT19: genuine triangular and defective block-Schur certificates.
test_root = fileparts (fileparts (mfilename ("fullpath")));
private_root = fullfile (test_root, "examples", "neig_tiers", "private");
addpath (private_root);

saved_bits = mpbits ();
unwind_protect
  mpbits (256);
  bundle = net_manifest ();
  jobs = bundle.jobs.profiles.smoke.jobs;
  real_result = net_v_a1_schur_job (jobs{17}, bundle.jobs.profiles.smoke, "smoke");
  complex_result = net_v_a1_schur_job (jobs{18}, bundle.jobs.profiles.smoke, "smoke");
  block_result = net_v_a1_schur_job (jobs{19}, bundle.jobs.profiles.smoke, "smoke");

  assert (real_result.pass && complex_result.pass && block_result.pass);
  assert (strcmp (real_result.status, "CERTIFIED_SCHUR_TRIANGULAR"));
  assert (strcmp (complex_result.status, "CERTIFIED_SCHUR_TRIANGULAR"));
  assert (strcmp (block_result.status, "CERTIFIED_BLOCK_SCHUR"));

  for current = {real_result, complex_result}
    certificate = current{1}.certificate;
    assert (certificate.all_normalizations_positive);
    assert (certificate.lower_triangle_algebraically_forced);
    assert (certificate.lower_left_zero_proof);
    assert (all (certificate.normalization_lower > mp (0)));
    for i = 1:4
      for j = 1:(i - 1)
        assert (certificate.T_box.rl(i,j) == mp (0));
        assert (certificate.T_box.rh(i,j) == mp (0));
        assert (certificate.T_box.il(i,j) == mp (0));
        assert (certificate.T_box.ih(i,j) == mp (0));
      endfor
    endfor
  endfor

  block_certificate = block_result.certificate;
  assert (block_certificate.block_dimension == 2);
  assert (! block_certificate.lower_triangle_algebraically_forced);
  assert (block_certificate.lower_left_zero_proof);
  for i = 3:4
    for j = 1:2
      assert (block_certificate.T_box.rl(i,j) == mp (0));
      assert (block_certificate.T_box.rh(i,j) == mp (0));
      assert (block_certificate.T_box.il(i,j) == mp (0));
      assert (block_certificate.T_box.ih(i,j) == mp (0));
    endfor
  endfor
  % The strictly lower entry inside the defective leading block is retained
  % from the direct Q'*A*Q enclosure rather than clipped to zero.
  block_lower = net_iv_complex (block_certificate.T_direct.rl(2,1), ...
                                block_certificate.T_direct.rh(2,1), ...
                                block_certificate.T_direct.il(2,1), ...
                                block_certificate.T_direct.ih(2,1));
  assert (block_lower.rl < mp (0) || block_lower.rh > mp (0) ...
          || block_lower.il < mp (0) || block_lower.ih > mp (0));

  % A zero column cannot be normalized and must fail closed.
  zero_column = net_iv_cmatrix_point (mp ([0, 0; 0, 1]), 256);
  bad_qr = net_v_a1_interval_qr (zero_column, 256);
  assert (! bad_qr.pass);
  assert (strcmp (bad_qr.status, "INCONCLUSIVE_QR_NORMALIZATION"));
  assert (! bad_qr.all_normalizations_positive);

  fprintf ("PASS: NEIGT19 interval QR, true triangular Schur, block Schur, and normalization traps\n");
unwind_protect_cleanup
  mpbits (saved_bits);
  if (any (strcmp (strsplit (path (), pathsep), private_root)))
    rmpath (private_root);
  endif
end_unwind_protect
