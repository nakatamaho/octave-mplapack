% Focused NEIGT08 Hadamard/Frank reuse and independent-reference tests.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "neig_tiers"));
addpath (fullfile (test_root, "examples", "neig_tiers", "private"));
saved_bits = mpbits ();
unwind_protect
  had = net_hadamard_model (8, 16, 512);
  href = net_hadamard_reference (8, 16, 640);
  assert (all (diag (had.T) == href.eigenvalues));
  [V, D, W] = eig (had.A, "nobalance");
  hmetrics = net_metrics (had.A, V, D, W, href.eigenvalues);
  assert (hmetrics.absolute_match.threshold < net_pow2 (-200, 512));
  assert (hmetrics.right_residual < net_pow2 (-180, 512));
  assert (hmetrics.left_residual < net_pow2 (-180, 512));
  assert (all (href.condition_numbers > mp (0)));

  f5 = net_frank_audit (5, 512, 640);
  assert (f5.reflected_exact && all (f5.characteristic_checks));
  assert (f5.polynomial.coefficients == mp ([1, -15, 55, -55, 15, -1]));
  assert (f5.positive_reference && f5.reference.central_exact);
  assert (f5.match_F0.threshold < net_pow2 (-180, 512));
  assert (f5.match_F1.threshold < net_pow2 (-180, 512));
  assert (f5.reflected_transpose_match.threshold < net_pow2 (-180, 512));
  assert (f5.reciprocal_error < net_pow2 (-180, 640));

  f8 = net_frank_audit (8, 512, 640);
  assert (f8.reflected_exact && all (f8.characteristic_checks));
  assert (f8.positive_reference);
  assert (f8.match_F0.threshold < net_pow2 (-180, 512));
  assert (f8.match_F1.threshold < net_pow2 (-180, 512));
  assert (f8.reciprocal_error < net_pow2 (-180, 640));
  fprintf ("PASS: NEIGT08 Hadamard/Frank reuse, recurrence, and Hermite-Jacobi reference\n");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
