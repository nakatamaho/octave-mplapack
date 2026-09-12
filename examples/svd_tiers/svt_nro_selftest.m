## SPDX-License-Identifier: BSD-2-Clause

function report = svt_nro_selftest ()
  ## Constructor and invariant gate for SVT04.  Measured row execution is
  ## included for the three smoke fixtures; the complete profile wall is
  ## repeated by the profile runner once all families are registered.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_nro_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  mpbits (256);

  two = svt_make_nro ("S1-NRO-TWO", struct ("m", 4, "mode", "two", "b", 12), 256);
  three = svt_make_nro ("S1-NRO-THREE", struct ("m", 4, "mode", "three", "b", 12), 256);
  graded = svt_make_nro ("S1-NRO-GRADED", struct ("m", 4, "mode", "graded", "g", 4), 256);
  cases = {two, three, graded};
  for case_index = 1:numel (cases)
    fixture = cases{case_index};
    assert (norm (fixture.A * fixture.inverse_formula - mp (eye (8)), "fro") == mp (0));
    assert (fixture.rank == 8 && fixture.full_rank);
    assert (fixture.det_model == mp (1));
    assert (all (all (fixture.analytic_values >= mp (0))));
    assert (all (all (fixture.analytic_values(1:end-1) ...
                      >= fixture.analytic_values(2:end))));
    for index = 1:4
      pair = fixture.unscaled_analytic_values(2 * index - 1:2 * index);
      assert (abs (pair(1) * pair(2) - mp (1)) < mp ('1e-70') ...
              || fixture.weights(index) == mp (0));
    endfor
  endfor

  zero_level = svt_make_nro ("S1-NRO-B0", ...
                             struct ("m", 4, "mode", "two", "b", 0), 128);
  assert (zero_level.analytic_values(1) > mp (1));
  assert (abs (zero_level.unscaled_analytic_values(1) ...
               * zero_level.unscaled_analytic_values(2) - mp (1)) < mp ('1e-30'));
  scaled = svt_make_nro ("S1-NRO-SCALE", ...
                         struct ("m", 4, "mode", "two", "b", 12, ...
                                 "scale_bits", 600), 256);
  assert (all (all (scaled.A == two.A * svt_pow2 (600))));
  assert (all (all (scaled.inverse_formula * scaled.A - mp (eye (8)) == mp (0))));
  rejected = false;
  try
    svt_make_nro ("bad", struct ("m", 6, "mode", "two", "b", 1), 128);
  catch
    rejected = true;
  end_try_catch
  assert (rejected);

  ## SVT04's measured family wall: every S1 smoke/demo MP precision, explicit
  ## native comparison, and values/economy mode.  These are real rows only;
  ## complex rows are added by the later Lauchli phase-control milestone.
  manifest = svt_load_manifest ();
  profile_names = {"smoke", "demo"};
  measured_rows = 0;
  for profile_index = 1:numel (profile_names)
    profile = svt_manifest_profile (manifest, profile_names{profile_index});
    for case_index = 1:numel (profile.cases)
      entry = profile.cases(case_index);
      if (! strcmp (entry.family, "nro_block"))
        continue;
      endif
      for bits_index = 1:numel (profile.work_bits)
        fixture = svt_make_nro (entry.id, entry.parameters, ...
                                profile.work_bits(bits_index));
        for mode_index = 1:numel (profile.modes)
          mode = profile.modes{mode_index};
          measured = svt_run_svd (fixture.A, mode, profile.evaluation_bits);
          assert (strcmp (measured.status, "PASS"));
          if (strcmp (mode, "econ"))
            assert (strcmp (measured.metrics.status, "PASS"));
          endif
          native = svt_run_native_svd (fixture.A, mode);
          assert (strcmp (native.status, "PASS"));
          measured_rows = measured_rows + 2;
        endfor
      endfor
    endfor
  endfor
  assert (measured_rows == 24 + 60);
  assert (mpbits () == 256);
  report = struct ("ok", true, "variants", 3, "inverse_checks", true, ...
                   "reciprocal_checks", true, "b0", true, "scale", true, ...
                   "measured_rows", measured_rows, ...
                   "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_nro_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
