% Focused NEIGT10 Grcar/MKS exact model and reference tests.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "neig_tiers"));
addpath (fullfile (test_root, "examples", "neig_tiers", "private"));
saved_bits = mpbits ();
unwind_protect
  g = net_grcar_audit (6, 3, 128, 256);
  expected = mp (zeros (6, 6));
  for i = 1:6
    for j = 1:6
      if (j >= i && j - i <= 3)
        expected(i, j) = mp (1);
      elseif (i - j == 1)
        expected(i, j) = mp (-1);
      endif
    endfor
  endfor
  assert (g.model.A_model == expected);
  assert (g.reference.agreement.threshold < net_pow2 (-100, 320));
  assert (g.metrics.right_residual < net_pow2 (-100, 320));

  delta = net_pow2 (-3, 256);
  m = net_mks_audit (6, 3, delta, 256, 256);
  assert (m.model.ell == 2);
  assert (m.model.zero_algebraic_multiplicity == 4);
  assert (m.model.zero_geometric_multiplicity == 2);
  expected_q = mp (zeros (1, 3));
  expected_q(1) = mp (1);
  expected_q(2) = -mp (3) / mp (4);
  expected_q(3) = -mp (3) / mp (8);
  assert (m.model.q_coefficients == expected_q);
  assert (all (m.determinant_checks));
  assert (m.nonzero_simple_guard);
  assert (m.reference.nonzero_agreement.threshold < net_pow2 (-160, 320));
  assert (m.metrics.absolute_match.threshold < net_pow2 (-100, 320));
  fprintf ("PASS: NEIGT10 Grcar references and MKS zero/nonzero audit\n");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
