## SPDX-License-Identifier: BSD-2-Clause

function report = svt_lauchli_selftest ()
  ## SVT11 Lauchli/projector and measured-row gate.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_lauchli_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  mpbits (256);

  tall = svt_make_lauchli ("A4-LAU-TALL-SMALL", ...
                           struct ("n", 4, "b", 20, "representation", "tall"), 256);
  wide = svt_make_lauchli ("A4-LAU-WIDE-SMALL", ...
                           struct ("n", 4, "b", 20, "representation", "wide"), 256);
  expected_normal = mp (ones (4, 4)) + tall.mu * tall.mu * mp (eye (4));
  assert (all (all (tall.normal_equations_model == expected_normal)));
  assert (norm (tall.tall' * tall.tall - expected_normal, "fro") == mp (0));
  assert (all (all (tall.right_projector * tall.right_projector ...
                    - tall.right_projector == mp (0))));
  assert (all (all (wide.A == tall.tall')));
  assert (tall.analytic_values(1) > tall.analytic_values(2));
  assert (all (all (tall.analytic_values(2:end) == tall.mu)));

  complex_fixture = svt_make_lauchli ("A4-LAU-COMPLEX-SMALL", ...
                                      struct ("n", 4, "b", 20, ...
                                              "representation", "tall", ...
                                              "quarter_turn_phases", true), 256);
  assert (! isreal (complex_fixture.A));
  phased_normal = complex_fixture.phase_right * expected_normal ...
                  * complex_fixture.phase_right';
  phase_normal_error = norm (complex_fixture.A' * complex_fixture.A ...
                             - phased_normal, "fro");
  assert (phase_normal_error < mp ('1e-200'));
  assert (all (all (complex_fixture.analytic_values == tall.analytic_values)));

  manifest = svt_load_manifest ();
  profile_names = {"smoke", "demo"};
  measured_rows = 0;
  for profile_index = 1:numel (profile_names)
    profile = svt_manifest_profile (manifest, profile_names{profile_index});
    for case_index = 1:numel (profile.cases)
      entry = profile.cases(case_index);
      if (! strcmp (entry.family, "lauchli"))
        continue;
      endif
      for bits_index = 1:numel (profile.work_bits)
        fixture = svt_make_lauchli (entry.id, entry.parameters, ...
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
  assert (measured_rows == 16 + 36);
  assert (mpbits () == 256);
  report = struct ("ok", true, "tall", true, "wide", true, ...
                   "phase", true, "projectors", true, "negative_control", true, ...
                   "measured_rows", measured_rows, "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_lauchli_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
