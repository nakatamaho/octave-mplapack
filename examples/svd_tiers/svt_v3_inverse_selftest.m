## SPDX-License-Identifier: BSD-2-Clause

function report = svt_v3_inverse_selftest ()
  ## SVT16 inverse residual/norm gate.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_v3_inverse_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  mpbits (256);

  diagonal = mp (diag ([3, 1]));
  inverse = diagonal \ mp (eye (2));
  good = svt_certify_inverse (diagonal, inverse, 256);
  assert (strcmp (good.status, "CERTIFIED"));
  assert (good.residual.hi < mp ('1e-50'));
  assert (good.sigma_min_lower > mp (0));
  assert (good.inverse_norm_upper_status == "FINITE");

  fixture = svt_make_nro_companion ("A6-INVERSE", struct ("n", 8, "nu", 16), 256);
  inverse_fixture = fixture.A \ mp (eye (8));
  fixture_certificate = svt_certify_inverse (fixture.A, inverse_fixture, 256);
  assert (strcmp (fixture_certificate.status, "CERTIFIED"));
  assert (fixture_certificate.sigma_min_lower > mp (0));

  published = svt_make_nro_companion ("A6-PUBLISHED", struct ("n", 8, "nu", 16), 256);
  published_certificate = svt_certify_inverse (published.published_C, ...
                                               published.published_X, 256);
  assert (strcmp (published_certificate.status, "CERTIFIED"));

  poor = svt_certify_inverse (diagonal, mp (zeros (2, 2)), 256);
  assert (strcmp (poor.status, "INCONCLUSIVE"));
  singular = mp (diag ([1, 0]));
  singular_control = svt_certify_inverse (singular, mp (eye (2)), 256);
  assert (strcmp (singular_control.status, "INCONCLUSIVE"));
  rectangular = svt_certify_inverse (mp ([1, 0; 0, 1; 0, 0]), ...
                                     mp ([1, 0; 0, 1]), 256);
  assert (strcmp (rectangular.status, "UNSUPPORTED_RECTANGULAR"));
  assert (mpbits () == 256);
  report = struct ("ok", true, "good_inverse", true, "nro_inverse", true, ...
                   "published_inverse", true, "poor_inconclusive", true, ...
                   "singular_inconclusive", true, "rectangular_unsupported", true, ...
                   "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_v3_inverse_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
