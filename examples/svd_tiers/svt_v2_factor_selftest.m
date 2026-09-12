## SPDX-License-Identifier: BSD-2-Clause

function report = svt_v2_factor_selftest ()
  ## SVT15 compatible factor-box and common-phase gate.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_v2_factor_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  mpbits (256);

  base = mp ([3, 0; 0, 1; 0, 0]);
  [u, s, v] = svd (base, "econ");
  boxes = svt_certify_factor_boxes (base, u, s, v, 256, [1, 2]);
  assert (strcmp (boxes.status, "CERTIFIED"));
  assert (boxes.common_phase && boxes.boxes_U.real_lower(1, 1) < u(1, 1));
  assert (boxes.boxes_U.real_upper(1, 1) > u(1, 1));

  left_phase = mp (eye (3));
  right_phase = mp (eye (2));
  left_phase(1, 1) = mp ('0', '1');
  right_phase(2, 2) = -mp (1);
  complex_base = left_phase * base * right_phase';
  [uc, sc, vc] = svd (complex_base, "econ");
  complex_boxes = svt_certify_factor_boxes (complex_base, uc, sc, vc, 256, [1, 2]);
  assert (strcmp (complex_boxes.status, "CERTIFIED"));

  ## Common signs/phases on both members preserve compatibility.
  common_u = u;
  common_v = v;
  common_u(:, 1) = -common_u(:, 1);
  common_v(:, 1) = -common_v(:, 1);
  common = svt_certify_factor_boxes (base, common_u, s, common_v, 256, [1, 2]);
  assert (strcmp (common.status, "CERTIFIED"));
  only_v_matrix = v;
  only_v_matrix(:, 1) = -only_v_matrix(:, 1);
  only_v = svt_certify_factor_boxes (base, u, s, only_v_matrix, 256, 1);
  assert (! strcmp (only_v.status, "CERTIFIED"));

  repeated_input = mp (diag ([2, 2]));
  [ur, sr, vr] = svd (repeated_input, "econ");
  repeated = svt_certify_factor_boxes (repeated_input, ur, sr, vr, 256, [1, 2]);
  assert (strcmp (repeated.status, "UNSUPPORTED_MULTIPLICITY"));

  geometric = svt_make_hadamard_spectrum ("A5-GEO-BOX", ...
                                          struct ("n", 8, "mode", "geometric", "a", 4), 256);
  [ug, sg, vg] = svd (geometric.A, "econ");
  geometric_boxes = svt_certify_factor_boxes (geometric.A, ug, sg, vg, 256, 1:8);
  assert (strcmp (geometric_boxes.status, "CERTIFIED"));

  ## Deliberate target/exterior mixing leaves the factorization uncertified.
  mixing = mp (eye (3));
  mixing(1, 1) = mp (1) / sqrt (mp (2));
  mixing(1, 2) = -mp (1) / sqrt (mp (2));
  mixing(2, 1) = mp (1) / sqrt (mp (2));
  mixing(2, 2) = mp (1) / sqrt (mp (2));
  narrow = mp (diag ([3, 2, 1]));
  [un, sn, vn] = svd (narrow, "econ");
  insufficient_gap = svt_certify_factor_boxes (narrow, un * mixing, sn, vn, 256, 2);
  assert (! strcmp (insufficient_gap.status, "CERTIFIED"));
  assert (mpbits () == 256);
  report = struct ("ok", true, "real_rectangular", true, "complex", true, ...
                   "common_phase", true, "single_phase_rejected", true, ...
                   "multiplicity", true, "geometric", true, ...
                   "gap_failure", true, "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_v2_factor_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
