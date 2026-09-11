% Focused NEIGT11 stochastic and positive-Perron tests.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "neig_tiers"));
addpath (fullfile (test_root, "examples", "neig_tiers", "private"));
saved_bits = mpbits ();
unwind_protect
  result = net_markov_audit (8, 24, 256, 256);
  assert (result.row_sum_exact);
  assert (result.positive_markov && result.positive_perron);
  assert (result.r_difference_max > net_pow2 (-20, 320));
  assert (max (abs (result.markov_reference.stationary_difference)) ...
          < net_pow2 (-180, 320));
  assert (max (abs (result.markov_reference.stationary_equation)) ...
          < net_pow2 (-180, 320));
  assert (max (abs (result.markov_reference.independent_equation)) ...
          < net_pow2 (-180, 320));
  assert (result.markov_metrics.absolute_match.threshold < net_pow2 (-150, 320));
  assert (result.perron_metrics.absolute_match.threshold < net_pow2 (-150, 320));
  assert (max (abs (result.perron_right_equation)) < net_pow2 (-180, 320));
  assert (max (abs (result.perron_left_equation)) < net_pow2 (-180, 320));
  assert (all (result.perron_right > mp (0)));
  assert (all (result.perron_left > mp (0)));
  assert (abs (sum (result.perron_right) - mp (1)) < net_pow2 (-200, 320));
  assert (abs (transpose (result.perron_left) * result.perron_right - mp (1)) ...
          < net_pow2 (-200, 320));
  fprintf ("PASS: NEIGT11 Markov spectrum, stationary solves, and Perron pair\n");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
