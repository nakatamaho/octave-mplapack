% NEIGT21: positive Perron root, normalized pair, and stationary-vector checks.
test_root = fileparts (fileparts (mfilename ("fullpath")));
private_root = fullfile (test_root, "examples", "neig_tiers", "private");
addpath (private_root);

saved_bits = mpbits ();
unwind_protect
  bundle = net_manifest ();
  profile_data = bundle.jobs.profiles.smoke;
  jobs = profile_data.jobs;
  checked = cell (1, 4);
  for index = 1:4
    checked{index} = net_v_a3_job (jobs{22 + index}, profile_data, "smoke");
    current = checked{index};
    assert (current.pass && current.milestone_pass);
    assert (strcmp (current.status, "CERTIFIED_PERRON_PAIR"));
    assert (current.collatz.pass && current.collatz.irreducible ...
            && current.collatz.strictly_positive);
    assert (current.root_width_pass && current.pair.pass);
    assert (current.lambda_intersection.nonempty);
    assert (current.left_strictly_positive);
    assert (current.left_residual_norm_upper <= current.root_width_target);
    if (index <= 2)
      assert (current.stationary.pass);
      assert (current.stationary.positive);
    endif
  endfor
  assert (checked{1}.collatz.cw_lower > mp (0));
  assert (checked{3}.collatz.cw_lower > mp (1));

  % Negative entry, reducibility, and nonpositive trial vectors fail closed.
  negative = mp (ones (3));
  negative(1,2) = mp (-1);
  neg_result = net_v_a3_collatz (negative, mp (ones (3,1)), 128);
  assert (! neg_result.pass && strcmp (neg_result.status, ...
                                       "UNSUPPORTED_NEGATIVE_ENTRY"));
  reducible = mp (eye (3));
  red_result = net_v_a3_collatz (reducible, mp (ones (3,1)), 128);
  assert (! red_result.pass && strcmp (red_result.status, ...
                                       "INCONCLUSIVE_NOT_IRREDUCIBLE"));
  nonpositive = net_v_a3_collatz (mp (ones (3)), ...
                                  mp ([-1; 1; 1]), 128);
  assert (! nonpositive.pass && strcmp (nonpositive.status, ...
                                        "INCONCLUSIVE_NONPOSITIVE_TRIAL"));
  A = mp (ones (3));
  x = mp (ones (3, 1)) / mp (3);
  mpbits (128);
  good_pair = net_v_a3_pair (A, x, mp (3), 128);
  bad_R = mp (2) * good_pair.R;
  bad_pair = net_v_a3_pair (A, x, mp (3), 128, struct ("R", bad_R));
  assert (! bad_pair.pass);
  assert (strcmp (bad_pair.status, "INCONCLUSIVE_PAIR_CONTRACTION"));
  assert (bad_pair.trials(end).e >= mp (1));
  fprintf ("PASS: NEIGT21 positive graph, Collatz--Wielandt, Perron pair, stationary vector, and fail-closed negatives\n");
unwind_protect_cleanup
  mpbits (saved_bits);
  if (any (strcmp (strsplit (path (), pathsep), private_root)))
    rmpath (private_root);
  endif
end_unwind_protect
