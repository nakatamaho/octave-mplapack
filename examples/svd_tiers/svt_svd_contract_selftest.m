## SPDX-License-Identifier: BSD-2-Clause

function report = svt_svd_contract_selftest ()
  ## Focused SVT03 tests on the measured runner and provisional metric layer.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_svd_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));

  mpbits (256);
  real_input = mp ({'1', '3', '5'; '2', '4', '6'});
  values_row = svt_run_svd (real_input, "values", 512);
  econ_row = svt_run_svd (real_input, "econ", 512);
  assert (! values_row.has_factors);
  assert (econ_row.has_factors);
  assert (values_row.value_info.count == 2);
  assert (econ_row.input_unchanged);
  assert (econ_row.metrics.status == "PASS");
  assert (econ_row.metrics.rho_rec < mp ('1e-70'));
  assert (size (econ_row.U) == [2, 2]);
  assert (size (econ_row.S) == [2, 2]);
  assert (size (econ_row.V) == [3, 2]);

  complex_input = mp ({'(1,1)', '(3,-2)'; '(2,-1)', '(4,2)'});
  complex_row = svt_run_svd (complex_input, "econ", 512);
  assert (! isreal (complex_row.U) && isreal (complex_row.S) ...
          && ! isreal (complex_row.V));
  assert (complex_row.metrics.rho_rec < mp ('1e-70'));

  zero_input = mp (zeros (2, 3));
  zero_row = svt_run_svd (zero_input, "econ", 512);
  assert (zero_row.metrics.zero_norm_branch);
  assert (zero_row.metrics.status == "ZERO_NORM_ABSOLUTE_DIAGNOSTICS");
  assert (zero_row.metrics.reconstruction == mp (0));

  saved_for_reference = mpbits ();
  mpbits (128);
  small_input = diag (mp ([1, 2 ^ (-100)]));
  low = svt_reference (small_input, 128);
  high = svt_reference (small_input, 256);
  comparison = svt_compare_references (low, high);
  assert (! comparison.resolved(2));
  assert (strcmp (comparison.status, "consistent_reference"));
  mpbits (saved_for_reference);

  ## The runner itself restores the ambient default after the SVD call.
  mpbits (73);
  ambient_input = mp ({'1', '0'; '0', '2'});
  svt_run_svd (ambient_input, "values", 256);
  assert (mpbits () == 73);

  report = struct ("ok", true, "values_mode", true, "economy_mode", true, ...
                   "complex_V_not_VT", true, "zero_reference", true, ...
                   "below_resolution", true, "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_svd_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
