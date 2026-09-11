% Focused NEIGT07 Forsythe split/scaled/zero tests.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "neig_tiers"));
addpath (fullfile (test_root, "examples", "neig_tiers", "private"));
saved_bits = mpbits ();
unwind_protect
  for n = [7, 8]
    reference = net_forsythe_reference (n, 4, 640);
    assert (reference.unit_roots(1) == mp ("(1,0)"));
    assert (abs (reference.unit_roots .* conj (reference.unit_roots) ...
                 - mp (1)) < net_pow2 (-450, 640));
    for representation = {"original", "explicitly_scaled"}
      fixture = net_forsythe_model (n, 4, representation{1}, 512);
      assert (fixture.relation_exact);
      audit = net_forsythe_audit (fixture, 640);
      assert (audit.circle_match.threshold < net_pow2 (-180, 512));
      assert (audit.metrics.right_residual < net_pow2 (-180, 512));
      assert (audit.metrics.left_residual < net_pow2 (-180, 512));
    endfor
  endfor
  zero = net_forsythe_model (8, 4, "zero_limit", 512);
  zero_audit = net_forsythe_audit (zero, 640);
  assert (zero_audit.first_n_minus_one_nonzero && zero_audit.nth_power_zero);
  assert (strcmp (zero_audit.unique_eigenvector_target, "NOT_APPLICABLE"));
  fprintf ("PASS: NEIGT07 Forsythe circle, scaling identity, and zero-limit Jordan audit\n");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
