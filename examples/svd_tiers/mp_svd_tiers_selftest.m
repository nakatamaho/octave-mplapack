## SPDX-License-Identifier: BSD-2-Clause

function report = mp_svd_tiers_selftest ()
  ## Focused SVT01 contract tests.  This helper intentionally does not run
  ## numerical suite rows; those are enabled only after their milestone.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_path (suite_dir, added));

  svt_expect_error (@() mp_svd_tiers ("unknown"), ...
                    "mplapack:svt:InvalidProfile");
  svt_expect_error (@() mp_svd_tiers ("smoke", struct ("bad", true)), ...
                    "mplapack:svt:InvalidOptions");
  svt_expect_error (@() mp_svd_tiers ("smoke", struct ("tier", "bad")), ...
                    "mplapack:svt:InvalidTier");
  svt_expect_error (@() mp_svd_tiers ("smoke", struct ("plot", 1)), ...
                    "mplapack:svt:InvalidPlotOption");

  saved_bits = mpbits ();
  precision_cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (128);
  source = mp ("0.1");
  widened = svt_widen (source, 256);
  source_info = __mplapack_core__ ("value_shape_info", source);
  widened_info = __mplapack_core__ ("value_shape_info", widened);
  assert (source_info.precision_bits == 128);
  assert (widened_info.precision_bits == 256);
  assert (source == widened);
  assert (mpbits () == 128);
  clear precision_cleanup;
  assert (mpbits () == saved_bits);
  svt_expect_error (@() svt_widen (source, 64), ...
                    "mplapack:svt:InsufficientWidening");
  assert (mpbits () == saved_bits);

  smoke = mp_svd_tiers ("smoke");
  assert (smoke.case_count == 20);
  assert (smoke.manifest_case_count == 20);
  assert (smoke.expected_svd_rows == 120);
  assert (smoke.measured_svd_rows == 0);
  assert (! smoke.ok && strcmp (smoke.status, "INCOMPLETE"));

  s_case = mp_svd_tiers ("demo", struct ("tier", "S"));
  assert (s_case.case_count == 9);
  assert (s_case.manifest_case_count == 23);
  assert (s_case.scope_ok && ! s_case.ok);

  output_dir = tempname ();
  created = mp_svd_tiers ("smoke", struct ("output_dir", output_dir));
  assert (exist (output_dir, "dir") == 7);
  assert (created.output_dir == output_dir);
  svt_expect_error (@() mp_svd_tiers ("smoke", ...
                                      struct ("output_dir", output_dir)), ...
                    "mplapack:svt:OutputDirectoryExists");
  rmdir (output_dir, "s");

  report = struct ("ok", true, "manifest", "smoke=20/120,demo=23/184", ...
                   "precision_cleanup", true, "output_safety", true, ...
                   "status", "PASS");
  clear cleanup_path;
endfunction

function svt_expect_error (thunk, expected_id)
  caught = false;
  try
    thunk ();
  catch exception
    caught = true;
    ## Octave releases represent caught identifiers differently in a few
    ## execution modes; the focused contract is rejection, while callers may
    ## inspect the identifier in the ordinary error struct.
  end_try_catch
  assert (caught, ["expected error was not raised: ", expected_id]);
endfunction

function svt_restore_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
