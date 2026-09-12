## SPDX-License-Identifier: BSD-2-Clause

function report = svt_nro_companion_selftest ()
  ## SVT11 NRO companion and measured-row gate.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_nro_companion_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  mpbits (256);

  small = svt_make_nro_companion ("A6-NRO-SMALL", ...
                                  struct ("n", 8, "nu", 16), 256);
  assert (small.horner_matches_k);
  assert (all (all (abs (small.A) <= mp (small.entry_bound))));
  assert (small.det_model == mp (-1));
  assert (small.full_rank && small.rank == 8);
  assert (all (all (small.published_left_error == mp (0))));
  assert (all (all (small.published_right_error == mp (0))));

  manifest = svt_load_manifest ();
  profile_names = {"smoke", "demo"};
  measured_rows = 0;
  for profile_index = 1:numel (profile_names)
    profile = svt_manifest_profile (manifest, profile_names{profile_index});
    for case_index = 1:numel (profile.cases)
      entry = profile.cases(case_index);
      if (! strcmp (entry.family, "nro_companion"))
        continue;
      endif
      for bits_index = 1:numel (profile.work_bits)
        fixture = svt_make_nro_companion (entry.id, entry.parameters, ...
                                          profile.work_bits(bits_index));
        assert (fixture.horner_matches_k);
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
  assert (measured_rows == 8 + 12);
  assert (mpbits () == 256);
  report = struct ("ok", true, "horner", true, "entry_bound", true, ...
                   "published_inverse", true, "measured_rows", measured_rows, ...
                   "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_nro_companion_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
