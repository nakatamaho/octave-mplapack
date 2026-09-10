## SPDX-License-Identifier: BSD-2-Clause

function report = svt_pascal_selftest ()
  ## SVT08 Pascal constructor and measured-row gate.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_pascal_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  mpbits (256);

  fixture = svt_make_pascal ("A1-PASCAL-SMALL", ...
                             struct ("n", 4, "representation", "symmetric"), 256);
  expected_q = mp ([1, 0, 0, 0; 1, 1, 0, 0; 1, 2, 1, 0; 1, 3, 3, 1]);
  expected_p = mp ([1, 1, 1, 1; 1, 2, 3, 4; 1, 3, 6, 10; 1, 4, 10, 20]);
  assert (all (all (fixture.Q == expected_q)));
  assert (all (all (fixture.P == expected_p)));
  assert (all (all (fixture.q_times_q_transpose_error == mp (0))));
  assert (all (all (tril (fixture.Q) == fixture.Q)));
  assert (all (all (diag (fixture.Q) == mp (ones (4, 1)))));

  manifest = svt_load_manifest ();
  profile_names = {"smoke", "demo"};
  measured_rows = 0;
  for profile_index = 1:numel (profile_names)
    profile = svt_manifest_profile (manifest, profile_names{profile_index});
    for case_index = 1:numel (profile.cases)
      entry = profile.cases(case_index);
      if (! strcmp (entry.family, "pascal"))
        continue;
      endif
      for bits_index = 1:numel (profile.work_bits)
        fixture = svt_make_pascal (entry.id, entry.parameters, ...
                                   profile.work_bits(bits_index));
        assert (all (all (fixture.q_times_q_transpose_error == mp (0))));
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
  report = struct ("ok", true, "known_q", true, "known_p", true, ...
                   "factor_identity", true, "measured_rows", measured_rows, ...
                   "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_pascal_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
