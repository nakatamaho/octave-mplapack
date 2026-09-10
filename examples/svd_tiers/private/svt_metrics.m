## SPDX-License-Identifier: BSD-2-Clause

function metrics = svt_metrics (input, u, s, v, evaluation_bits)
  ## Reevaluate ordinary residual/orthogonality diagnostics at q from widened
  ## returned values.  These are diagnostics, not Tier V certificates.
  if (isempty (evaluation_bits))
    input_info = __mplapack_core__ ("value_shape_info", input);
    evaluation_bits = max ([input_info.precision_bits, 64]);
  endif
  aq = svt_widen (input, evaluation_bits);
  uq = svt_widen (u, evaluation_bits);
  sq = svt_widen (s, evaluation_bits);
  vq = svt_widen (v, evaluation_bits);
  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (evaluation_bits);
  [m, n] = size (aq);
  k = min (m, n);
  identity_u = mp (eye (k));
  identity_v = mp (eye (k));
  reconstruction = aq - uq * sq * vq';
  right_triplet = aq * vq - uq * sq;
  left_triplet = aq' * uq - vq * sq;
  orth_u = uq' * uq - identity_u;
  orth_v = vq' * vq - identity_v;
  norm_a = norm (aq, "fro");
  reconstruction_abs = norm (reconstruction, "fro");
  right_abs = norm (right_triplet, "fro");
  left_abs = norm (left_triplet, "fro");
  orth_u_abs = norm (orth_u, "fro");
  orth_v_abs = norm (orth_v, "fro");
  metrics = struct ();
  metrics.evaluation_bits = evaluation_bits;
  metrics.norm_A = norm_a;
  metrics.reconstruction = reconstruction_abs;
  metrics.triplet_R = right_abs;
  metrics.triplet_L = left_abs;
  metrics.orthogonality_U = orth_u_abs;
  metrics.orthogonality_V = orth_v_abs;
  metrics.sigma_max = sq(1, 1);
  metrics.sigma_min = sq(k, k);
  metrics.zero_norm_branch = (norm_a == mp (0));
  if (metrics.zero_norm_branch)
    metrics.rho_rec = mp (0);
    metrics.rho_R = mp (0);
    metrics.rho_L = mp (0);
    metrics.status = "ZERO_NORM_ABSOLUTE_DIAGNOSTICS";
  else
    metrics.rho_rec = reconstruction_abs / norm_a;
    metrics.rho_R = right_abs / (norm_a * norm (vq, "fro"));
    metrics.rho_L = left_abs / (norm_a * norm (uq, "fro"));
    metrics.status = "PASS";
  endif
  u_shape = size (uq);
  s_shape = size (sq);
  v_shape = size (vq);
  metrics.factor_shapes = [u_shape; s_shape; v_shape];
  u_real = isreal (uq);
  s_real = isreal (sq);
  v_real = isreal (vq);
  metrics.factor_real = [u_real, s_real, v_real];
  clear cleanup;
endfunction
