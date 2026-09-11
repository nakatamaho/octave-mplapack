% Focused NEIGT09 Wilkinson recurrence and polynomial error tests.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "neig_tiers"));
addpath (fullfile (test_root, "examples", "neig_tiers", "private"));
saved_bits = mpbits ();
unwind_protect
  w4 = net_wilkinson_model (4, 128);
  assert (w4.guard_bits == 4 * net_ceil_log2_integer (5) + 2);
  assert (w4.coefficients == mp ([1, -10, 35, -50, 24]));
  assert (w4.A_model(1, :) == mp ([10, -35, 50, -24]));
  r4 = net_wilkinson_reference (4, 256);
  assert (all (r4.horner_exact_zero));

  w6 = net_wilkinson_audit (6, 256, 512);
  assert (all (w6.reference.horner_exact_zero));
  assert (w6.metrics.absolute_match.threshold < net_pow2 (-180, 256));
  assert (all (w6.model_eta_poly < net_pow2 (-180, 512)));
  assert (all (w6.frozen_eta_poly < net_pow2 (-180, 512)));
  z = net_mp_complex (mp (2), net_pow2 (-700, 512));
  indicator = net_polynomial_backward_error (z, w6.model.coefficients, 512);
  assert (indicator.eta >= mp (0) && strcmp (indicator.status, "finite"));
  zero_case = net_polynomial_backward_error (mp (0), mp ([0, 0]), 128);
  assert (zero_case.eta == mp (0));
  assert (strcmp (zero_case.status, "denominator_zero_exact_zero"));
  fprintf ("PASS: NEIGT09 Wilkinson recurrence, Horner zeros, and polynomial backward error\n");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
