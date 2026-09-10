## SPDX-License-Identifier: BSD-2-Clause

function report = svt_bidiagonal_selftest ()
  ## SVT10 bidiagonal constructor and measured-row gate.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_bidiagonal_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  mpbits (256);

  small_raw = svt_make_bidiagonal ("A3-BDI-RAW-SMALL", ...
                                   struct ("n", 4, "a", 2, "representation", "raw"), 256);
  small_mixed = svt_make_bidiagonal ("A3-BDI-MIXED-SMALL", ...
                                     struct ("n", 4, "a", 2, "representation", "mixed"), 256);
  assert (small_raw.raw(1, 1) == mp (1));
  assert (small_raw.raw(1, 2) == svt_pow2 (-1));
  assert (small_raw.raw(4, 4) == svt_pow2 (-6));
  assert (all (all (small_raw.raw == small_mixed.raw)));
  assert (small_raw.full_rank && small_mixed.full_rank);

  ## The two-sided Hadamard factors preserve singular values.  This is a
  ## numerical cross-check at high precision, not a Tier V certificate.
  mpbits (512);
  raw_values = svd (svt_widen (small_raw.raw, 512));
  mixed_values = svd (svt_widen (small_raw.mixed, 512));
  assert (norm (raw_values - mixed_values, "fro") < mp ('1e-100'));

  manifest = svt_load_manifest ();
  profile_names = {"smoke", "demo"};
  measured_rows = 0;
  for profile_index = 1:numel (profile_names)
    profile = svt_manifest_profile (manifest, profile_names{profile_index});
    for case_index = 1:numel (profile.cases)
      entry = profile.cases(case_index);
      if (! strcmp (entry.family, "bidiagonal"))
        continue;
      endif
      for bits_index = 1:numel (profile.work_bits)
        fixture = svt_make_bidiagonal (entry.id, entry.parameters, ...
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
  assert (mpbits () == 512);
  report = struct ("ok", true, "raw_construction", true, "mixed_construction", true, ...
                   "spectrum_crosscheck", true, "measured_rows", measured_rows, ...
                   "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_bidiagonal_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
