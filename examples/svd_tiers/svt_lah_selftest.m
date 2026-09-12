## SPDX-License-Identifier: BSD-2-Clause

function report = svt_lah_selftest ()
  ## SVT06 constructor and measured-row gate.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_lah_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  mpbits (256);

  leading = svt_make_lah ("S3-LAH-4", struct ("n", 4), 256);
  expected = mp ([1, 0, 0, 0; 2, 1, 0, 0; 6, 6, 1, 0; 24, 36, 12, 1]);
  assert (all (all (leading.A == expected)));
  assert (all (all (tril (leading.A) == leading.A)));
  assert (all (all (diag (leading.A) == mp (ones (4, 1)))));
  assert (leading.det_model == mp (1) && leading.full_rank);

  manifest = svt_load_manifest ();
  profile_names = {"smoke", "demo"};
  measured_rows = 0;
  for profile_index = 1:numel (profile_names)
    profile = svt_manifest_profile (manifest, profile_names{profile_index});
    for case_index = 1:numel (profile.cases)
      entry = profile.cases(case_index);
      if (! strcmp (entry.family, "lah"))
        continue;
      endif
      for bits_index = 1:numel (profile.work_bits)
        fixture = svt_make_lah (entry.id, entry.parameters, ...
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
  assert (measured_rows == 8 + 12);
  assert (mpbits () == 256);
  report = struct ("ok", true, "known_fixture", true, "unit_lower", true, ...
                   "guard", true, "measured_rows", measured_rows, "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_lah_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
