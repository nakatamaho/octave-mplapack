## SPDX-License-Identifier: BSD-2-Clause

function report = svt_hadamard_spectrum_selftest ()
  ## SVT10 A5 constructor and measured-row gate.  Lauchli rows are executed
  ## here as well because A4/A5 share this milestone in MILESTONES.md.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_hadamard_spectrum_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  mpbits (256);

  small = svt_make_hadamard_spectrum ("A5-SMALL", ...
                                      struct ("n", 8, "mode", "close", "b", 32), 256);
  assert (small.values(1) == mp (4));
  assert (small.values(3) == mp (1) + svt_pow2 (-32));
  assert (small.model_rank == 8 && small.full_rank);
  assert (all (all (small.left_projector * small.left_projector ...
                    - small.left_projector == mp (0))));
  repeat = svt_make_hadamard_spectrum ("A5-REPEAT-SMALL", ...
                                      struct ("n", 8, "mode", "repeat"), 256);
  assert (repeat.values(3) == repeat.values(4));
  rank4 = svt_make_hadamard_spectrum ("A5-RANK4-SMALL", ...
                                     struct ("n", 8, "mode", "rank4"), 256);
  rank5 = svt_make_hadamard_spectrum ("A5-RANK5-SMALL", ...
                                     struct ("n", 8, "mode", "rank5", "b", 32), 256);
  assert (rank4.model_rank == 4 && rank5.model_rank == 5);
  assert (numel (rank4.null_indices) == 4 && numel (rank5.null_indices) == 3);

  ## The mixed and raw diagonal forms are orthogonally equivalent.  This is a
  ## high-precision cross-check; it is not yet a Tier V certificate.
  geometric = svt_make_hadamard_spectrum ("A5-GEO-SMALL", ...
                                          struct ("n", 8, "mode", "geometric", "a", 4), 256);
  mpbits (512);
  mixed_values = svd (svt_widen (geometric.A, 512));
  raw_values = svd (svt_widen (geometric.model, 512));
  assert (norm (mixed_values - raw_values, "fro") < mp ('1e-100'));

  manifest = svt_load_manifest ();
  profile_names = {"smoke", "demo"};
  measured_rows = 0;
  for profile_index = 1:numel (profile_names)
    profile = svt_manifest_profile (manifest, profile_names{profile_index});
    for case_index = 1:numel (profile.cases)
      entry = profile.cases(case_index);
      if (! strcmp (entry.family, "hadamard_spectrum"))
        continue;
      endif
      for bits_index = 1:numel (profile.work_bits)
        fixture = svt_make_hadamard_spectrum (entry.id, entry.parameters, ...
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
  ## Lauchli is the A4 half of SVT10.
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
          measured_rows = measured_rows + 2;
        endfor
      endfor
    endfor
  endfor
  assert (measured_rows == 100 + 16 + 36);
  assert (mpbits () == 512);
  report = struct ("ok", true, "hadamard_cases", 5, "lauchli_cases", 5, ...
                   "rank_metadata", true, "projectors", true, ...
                   "mixed_raw_crosscheck", true, "measured_rows", measured_rows, ...
                   "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_hadamard_spectrum_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
