% Focused NEIGT03 matching, metrics, and reference-role test.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "neig_tiers"));
addpath (fullfile (test_root, "examples", "neig_tiers", "private"));
saved_bits = mpbits ();
unwind_protect
  mpbits (256);
  match = net_match (mp ([3; 1; 2]), mp ([1; 2; 3]), "absolute");
  assert (match.threshold == mp (0));
  assert (match.mapping == [3, 1, 2]);
  duplicate = net_match (mp ([0; 0; 2]), mp ([0; 1; 2]), "absolute");
  assert (duplicate.threshold == mp (1));
  augment = net_match (mp ([2; 0]), mp ([1; 3]), "absolute");
  assert (augment.threshold == mp (1));
  mpbits (2048);
  tiny_value = net_pow2 (-1500, 2048);
  zero_value = mp (0);
  one_value = mp (1);
  computed_tiny = [tiny_value; one_value];
  reference_tiny = [zero_value; one_value];
  tiny = net_match (computed_tiny, reference_tiny, "absolute");
  assert (tiny.threshold == tiny_value);

  fixture = net_similarity_model ("simple", 6, 80, 512);
  reference = net_reference (fixture, 1024);
  mpbits (1024);
  [V, D, W] = eig (net_widen (fixture.A_frozen, 1024, 512), "nobalance");
  metrics = net_metrics (fixture.A_frozen + mp (zeros (6)), V, D, W, ...
                         reference.values, struct ("simple_mask", true (6, 1)));
  assert (strcmp (metrics.status, "MEASURED"));
  assert (metrics.absolute_match.threshold >= mp (0));
  bad_left = ctranspose (W);
  bad = net_metrics (fixture.A_frozen + mp (zeros (6)), V, D, bad_left, ...
                     reference.values, struct ("simple_mask", true (6, 1)));
  assert (bad.left_residual > metrics.left_residual);

  jordan = net_similarity_model ("jordan", 6, 80, 512);
  jordan_reference = net_reference (jordan, 1024);
  [Vj, Dj, Wj] = eig (net_widen (jordan.A_frozen, 1024, 512), "nobalance");
  defective = net_metrics (jordan.A_frozen + mp (zeros (6)), Vj, Dj, Wj, ...
                           jordan_reference.values, struct ("simple_mask", ...
                                                            [false; false; true; true; true; true]));
  assert (strcmp (defective.condition_status{1}, "not_applicable_simple_root"));
  fprintf ("PASS: NEIGT03 MP bottleneck matching, left convention, references, and metrics\n");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
