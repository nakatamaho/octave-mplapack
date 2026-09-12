## SPDX-License-Identifier: BSD-2-Clause

function report = svt_v1_projector_selftest ()
  ## SVT14 cluster-projector certificate and adversarial gate.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_v1_projector_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  mpbits (256);
  a = mp (diag ([4, 2, 2, 1]));
  [u, s, v] = svd (a, "econ");
  cluster = svt_certify_projector (a, u, s, v, 256, [2, 3]);
  assert (strcmp (cluster.status, "CERTIFIED"));
  assert (cluster.delta_lower > mp (0) && cluster.bU.hi < mp ('1e-50'));

  ## Swapping columns inside the repeated group preserves the subspace.
  permutation = [1, 3, 2, 4];
  permuted = svt_certify_projector (a, u(:, permutation), s, v(:, permutation), ...
                                    256, [2, 3]);
  assert (strcmp (permuted.status, "CERTIFIED"));

  ## A genuine internal orthogonal rotation of a repeated pair is accepted.
  rotation = mp (eye (4));
  rotation(2, 2) = mp (3) / mp (5);
  rotation(2, 3) = -mp (4) / mp (5);
  rotation(3, 2) = mp (4) / mp (5);
  rotation(3, 3) = mp (3) / mp (5);
  rotated = svt_certify_projector (a, u * rotation, s, v * rotation, 256, [2, 3]);
  assert (strcmp (rotated.status, "CERTIFIED"));

  ## A column from outside the cluster breaks the factorization and must not
  ## receive a certified cluster claim.
  wrong = svt_certify_projector (a, u(:, [2, 1, 3, 4]), s, v, 256, [2, 3]);
  assert (! strcmp (wrong.status, "CERTIFIED"));

  ## Rectangular dilation includes structural zero eigenvalues in its gap.
  tall = mp ([4, 0; 0, 2; 0, 0]);
  [ut, st, vt] = svd (tall, "econ");
  tall_cluster = svt_certify_projector (tall, ut, st, vt, 256, [2]);
  assert (strcmp (tall_cluster.status, "CERTIFIED"));
  assert (tall_cluster.complement_count > 0);

  ## Mixing a target column with an exterior value collapses the certified gap.
  gap_rotation = mp (eye (4));
  gap_rotation(1, 1) = mp (1) / sqrt (mp (2));
  gap_rotation(1, 2) = -mp (1) / sqrt (mp (2));
  gap_rotation(2, 1) = mp (1) / sqrt (mp (2));
  gap_rotation(2, 2) = mp (1) / sqrt (mp (2));
  collapsed = svt_certify_projector (a, u * gap_rotation, s, v * gap_rotation, ...
                                     256, [2]);
  assert (! strcmp (collapsed.status, "CERTIFIED"));
  assert (mpbits () == 256);
  report = struct ("ok", true, "repeat", true, "permutation", true, ...
                   "internal_rotation", true, "wrong_column_rejected", true, ...
                   "structural_zero_gap", true, "exterior_gap_collapse", true, ...
                   "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_v1_projector_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
