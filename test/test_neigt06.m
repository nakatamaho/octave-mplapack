% Focused NEIGT06 Toeplitz/symmetric controls.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "neig_tiers"));
addpath (fullfile (test_root, "examples", "neig_tiers", "private"));
saved_bits = mpbits ();
unwind_protect
  small = net_toeplitz_model (2, 4, "original", 256);
  assert (small.relation_exact);
  small_reference = net_toeplitz_reference (2, 4, 384);
  assert (all (abs (small_reference.overlaps - mp (3) / mp (2)) ...
               < mp ("1e-100")));
  for representation = {"original", "explicitly_symmetric"}
    fixture = net_toeplitz_model (16, 4, representation{1}, 512);
    assert (fixture.relation_exact);
    audit = net_toeplitz_audit (fixture, 640);
    assert (strcmp (audit.status, "MEASURED"));
    target = net_pow2 (-200, 512);
    assert (audit.symmetric_eig_match.threshold < target);
    assert (audit.nobalance_metrics.right_residual < target);
    assert (audit.nobalance_metrics.left_residual < target);
    assert (audit.condition_separation.matrix_and_eigenvalue_conditions_separate);
    assert (audit.condition_separation.scaling_D > mp (1));
  endfor
  fprintf ("PASS: NEIGT06 Toeplitz relation, MP references, and symmetric control\n");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
