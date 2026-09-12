## SPDX-License-Identifier: BSD-2-Clause

function report = svt_construction_selftest ()
  ## Focused SVT02 tests for exact common constructors and identity metadata.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_construction_path (suite_dir, added));

  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  mpbits (256);

  for n = [1, 2, 4, 8, 16]
    [h, g] = svt_hadamard (n);
    identity = mp (eye (n));
    assert (all (all (h * h' == mp (n) * identity)));
    assert (all (all (g * g' == mp (n) * identity)));
  endfor

  [h, g] = svt_hadamard (8);
  assert (all (all (g == [h(8, :); h(1:7, :)])));
  phases = svt_phase_diagonal (8);
  assert (! isreal (phases));
  assert (all (all (phases * phases' == mp (eye (8)))));

  diagonal = diag (mp ([1, 2, 4, 8, 16, 32, 64, 128]));
  mixed = svt_mix (diagonal);
  assert (all (all (mixed == svt_mix (diagonal))));
  scale_up = mixed * svt_pow2 (600);
  scale_down = mixed * svt_pow2 (-600);
  assert (all (all (scale_up * svt_pow2 (-600) == mixed)));
  assert (all (all (scale_down * svt_pow2 (600) == mixed)));

  svt_require_guard (32, 256, "sufficient test");
  svt_expect_construction_error (@() svt_require_guard (33, 32, "below guard"));
  svt_expect_construction_error (@() svt_hadamard (3));
  svt_expect_construction_error (@() svt_ceil_log2_integer (0));

  identity = svt_case_identity ("TEST", "hadamard", diagonal, mixed, ...
                                256, "exact_dyadic", "SVT02 selftest");
  assert (strcmp (identity.schema, "svt-input-v1"));
  assert (identity.model_shape == [8, 8]);
  assert (identity.represented_precision_bits == 256);
  assert (identity.model_is_real && identity.represented_is_real);

  report = struct ("ok", true, "hadamard_orders", [1, 2, 4, 8, 16], ...
                   "phase_identity", true, "scale_round_trip", true, ...
                   "guard_rejection", true, "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_expect_construction_error (thunk)
  caught = false;
  try
    thunk ();
  catch
    caught = true;
  end_try_catch
  assert (caught, "expected SVT02 construction error was not raised");
endfunction

function svt_restore_construction_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
