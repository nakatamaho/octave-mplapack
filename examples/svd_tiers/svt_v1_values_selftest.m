## SPDX-License-Identifier: BSD-2-Clause

function report = svt_v1_values_selftest ()
  ## SVT13 all-singular-value enclosure gate.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_v1_values_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  mpbits (256);

  diagonal = mp (diag ([3, 1]));
  [u, s, v] = svd (diagonal, "econ");
  exact = svt_certify_values (diagonal, u, s, v, 256);
  assert (strcmp (exact.status, "CERTIFIED"));
  assert (all (exact.values_lower <= svd (diagonal)));
  assert (all (exact.values_upper >= svd (diagonal)));
  assert (exact.epsilon.hi < mp ('1e-60'));

  tall = mp ([3, 0; 0, 1; 0, 0]);
  [ut, st, vt] = svd (tall, "econ");
  tall_certificate = svt_certify_values (tall, ut, st, vt, 256);
  assert (strcmp (tall_certificate.status, "CERTIFIED"));
  assert (tall_certificate.input_shape(1) == 3);

  complex_input = mp ({'(1,2)', '(0,0)'; '(0,0)', '(2,-1)'});
  [uc, sc, vc] = svd (complex_input, "econ");
  complex_certificate = svt_certify_values (complex_input, uc, sc, vc, 256);
  assert (strcmp (complex_certificate.status, "CERTIFIED"));
  assert (! isreal (uc) && isreal (sc) && ! isreal (vc));

  zero_input = mp (zeros (2, 3));
  [uz, sz, vz] = svd (zero_input, "econ");
  zero_certificate = svt_certify_values (zero_input, uz, sz, vz, 256);
  assert (strcmp (zero_certificate.status, "CERTIFIED"));
  assert (all (zero_certificate.values_lower == mp (0)));
  assert (all (zero_certificate.values_upper >= mp (0)));

  bad_gram = mp (ones (2, 2));
  bad_certificate = svt_certify_values (diagonal, bad_gram, s, v, 256);
  assert (strcmp (bad_certificate.status, "INCONCLUSIVE"));
  malformed = false;
  try
    svt_certify_values (diagonal, u, mp ([-1, 0; 0, 1]), v, 256);
  catch
    malformed = true;
  end_try_catch
  assert (malformed);
  assert (mpbits () == 256);
  report = struct ("ok", true, "exact_diagonal", true, "tall", true, ...
                   "complex", true, "zero", true, "bad_gram_inconclusive", true, ...
                   "malformed_rejected", true, "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_v1_values_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
