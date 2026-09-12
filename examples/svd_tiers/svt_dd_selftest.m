## SPDX-License-Identifier: BSD-2-Clause

function report = svt_dd_selftest ()
  ## SVT07 constructor, analytic symmetric reference, and measured-row gate.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_dd_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  mpbits (256);

  symmetric = svt_make_dd_path ("S4-DD-SYM", ...
                                struct ("n", 8, "b", 32, "rho_num", 1, ...
                                        "rho_den", 1, "allow_below_guard", true), 256);
  assert (symmetric.symmetric && symmetric.tau == svt_pow2 (-32));
  assert (symmetric.analytic_values(1) == symmetric.tau);
  assert (all (all (symmetric.model == symmetric.model')));
  assert (all (all (symmetric.tau0_leading_principal_determinants == mp (1))));
  assert (symmetric.tau0_full_determinant == mp (0));

  nonsymmetric = svt_make_dd_path ("S4-DD-NONSYM", ...
                                   struct ("n", 8, "b", 32, "rho_num", 1, ...
                                           "rho_den", 2, "allow_below_guard", true), 256);
  assert (! nonsymmetric.symmetric && isempty (nonsymmetric.analytic_values));
  assert (nonsymmetric.tau0_full_determinant == mp (0));

  rounded = svt_make_dd_path ("S4-DD-ROUNDED", ...
                              struct ("n", 24, "b", 160, "rho_num", 1, ...
                                      "rho_den", 2, "allow_below_guard", true), 128);
  assert (rounded.below_guard && rounded.represented_tau_lost);
  assert (rounded.rank == 24 && rounded.tau0_full_determinant == mp (0));
  rejected = false;
  try
    svt_make_dd_path ("bad", struct ("n", 8, "b", 160, "rho_num", 1, ...
                                      "rho_den", 1), 128);
  catch
    rejected = true;
  end_try_catch
  assert (rejected);

  manifest = svt_load_manifest ();
  profile_names = {"smoke", "demo"};
  measured_rows = 0;
  for profile_index = 1:numel (profile_names)
    profile = svt_manifest_profile (manifest, profile_names{profile_index});
    for case_index = 1:numel (profile.cases)
      entry = profile.cases(case_index);
      if (! strcmp (entry.family, "dd_path"))
        continue;
      endif
      for bits_index = 1:numel (profile.work_bits)
        fixture = svt_make_dd_path (entry.id, entry.parameters, ...
                                    profile.work_bits(bits_index));
        for mode_index = 1:numel (profile.modes)
          mode = profile.modes{mode_index};
          mp_row = svt_run_svd (fixture.A, mode, profile.evaluation_bits);
          native_row = svt_run_native_svd (fixture.A, mode);
          assert (strcmp (mp_row.status, "PASS") && strcmp (native_row.status, "PASS"));
          if (strcmp (mode, "econ"))
            assert (strcmp (mp_row.metrics.status, "PASS"));
          endif
          measured_rows = measured_rows + 2;
        endfor
      endfor
    endfor
  endfor
  assert (measured_rows == 16 + 24);
  assert (mpbits () == 256);
  report = struct ("ok", true, "symmetric_formula", true, ...
                   "nonsymmetric_not_tau_claim", true, "rounded_tau_control", true, ...
                   "rank_proof", true, "measured_rows", measured_rows, "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_dd_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
