## SPDX-License-Identifier: BSD-2-Clause

function report = svt_vandermonde_selftest ()
  ## SVT09 dyadic Vandermonde and measured-row gate.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_vandermonde_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  mpbits (256);

  small = svt_make_vandermonde ("A2-VAND-SMALL", ...
                                struct ("n", 3, "node_den_bits", 3), 128);
  assert (small.nodes(1) == mp (1) / mp (8));
  assert (small.nodes(1) < small.nodes(2) && small.nodes(2) < small.nodes(3));
  assert (small.A(1, 2) == small.nodes(1));
  assert (small.A(1, 3) == small.nodes(1) * small.nodes(1));
  assert (small.full_rank && small.determinant_positive);

  manifest = svt_load_manifest ();
  profile_names = {"smoke", "demo"};
  measured_rows = 0;
  for profile_index = 1:numel (profile_names)
    profile = svt_manifest_profile (manifest, profile_names{profile_index});
    for case_index = 1:numel (profile.cases)
      entry = profile.cases(case_index);
      if (! strcmp (entry.family, "vandermonde"))
        continue;
      endif
      for bits_index = 1:numel (profile.work_bits)
        fixture = svt_make_vandermonde (entry.id, entry.parameters, ...
                                        profile.work_bits(bits_index));
        assert (fixture.full_rank && fixture.determinant_sign_proof);
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
  report = struct ("ok", true, "dyadic_nodes", true, "successive_powers", true, ...
                   "positive_determinant_proof", true, "measured_rows", measured_rows, ...
                   "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_vandermonde_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
