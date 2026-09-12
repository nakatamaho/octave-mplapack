## SPDX-License-Identifier: BSD-2-Clause

function certificate = svt_certify_values (a, u, s, v, q)
  ## V1a polar/Weyl certificate for all singular values.  The SVD factors are
  ## inputs to this checker; it never invokes SVD internally.
  certificate = struct ("schema", "svt-v1a-certificate-v1", ...
                        "method", "svt_polar_weyl_v1", "status", "ERROR", ...
                        "paper_algorithm_reproduction", false, "q", q);
  if (! isa (a, "mp") || ! isa (u, "mp") || ! isa (s, "mp") || ! isa (v, "mp") ...
      || ndims (a) != 2 || ndims (u) != 2 || ndims (s) != 2 || ndims (v) != 2)
    error ("mplapack:svt:CertificateInput", "V1a requires 2-D mp inputs");
  endif
  [m, n] = size (a);
  k = min (m, n);
  if (m < 1 || n < 1 || q != fix (q) || q < 64 || q > 4096)
    certificate.status = "UNSUPPORTED_EMPTY";
    return;
  endif
  if (size (u, 1) != m || size (u, 2) != k ...
      || size (v, 1) != n || size (v, 2) != k ...
      || size (s, 1) != k || size (s, 2) != k)
    error ("mplapack:svt:CertificateShape", "V1a factors do not have economy shapes");
  endif
  if (! isreal (s) || any (any (! isfinite (s))) ...
      || any (any (! isfinite (u))) || any (any (! isfinite (v))))
    error ("mplapack:svt:CertificateInput", "V1a factors must be finite");
  endif
  for row = 1:k
    if (s(row, row) < mp (0))
      error ("mplapack:svt:CertificateInput", "V1a singular values must be nonnegative");
    endif
    for column = 1:k
      if (row != column && s(row, column) != mp (0))
        error ("mplapack:svt:CertificateInput", "V1a S must be diagonal");
      endif
    endfor
    if (row < k && s(row, row) < s(row + 1, row + 1))
      error ("mplapack:svt:CertificateInput", "V1a singular values must be descending");
    endif
  endfor
  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (q);
  svt_v0_contract (q);
  aq = svt_iv ("matrix_point", a, q);
  uq = svt_iv ("matrix_point", u, q);
  sq = svt_iv ("matrix_point", s, q);
  vq = svt_iv ("matrix_point", v, q);
  identity = svt_iv ("matrix_point", mp (eye (k)), q);
  gram_u = svt_iv ("matrix_sub", ...
                   svt_iv ("matrix_mul", svt_iv ("matrix_ctranspose", uq), uq), identity);
  gram_v = svt_iv ("matrix_sub", ...
                   svt_iv ("matrix_mul", svt_iv ("matrix_ctranspose", vq), vq), identity);
  reconstruction = svt_iv ("matrix_sub", aq, ...
                           svt_iv ("matrix_mul", ...
                                   svt_iv ("matrix_mul", uq, sq), ...
                                   svt_iv ("matrix_ctranspose", vq)));
  g_u = svt_iv ("matrix_fro_upper", gram_u);
  g_v = svt_iv ("matrix_fro_upper", gram_v);
  residual = svt_iv ("matrix_fro_upper", reconstruction);
  certificate.gU = g_u;
  certificate.gV = g_v;
  certificate.residual = residual;
  certificate.input_shape = [m, n];
  u_shape = size (u);
  s_shape = size (s);
  v_shape = size (v);
  certificate.factor_shapes = [u_shape; s_shape; v_shape];
  a_info = __mplapack_core__ ("value_shape_info", a);
  u_info = __mplapack_core__ ("value_shape_info", u);
  s_info = __mplapack_core__ ("value_shape_info", s);
  v_info = __mplapack_core__ ("value_shape_info", v);
  certificate.source_precisions = [a_info.precision_bits, u_info.precision_bits, ...
                                   s_info.precision_bits, v_info.precision_bits];
  if (g_u.lo >= mp (1) || g_v.lo >= mp (1))
    certificate.status = "INCONCLUSIVE";
    certificate.reason = "raw factor Gram defect is not below one";
    clear cleanup;
    return;
  endif
  one = svt_iv ("point", mp (1), q);
  d_u = svt_iv ("div", g_u, svt_iv ("add", one, ...
                                    svt_iv ("sqrt", svt_iv ("sub", one, g_u))));
  d_v = svt_iv ("div", g_v, svt_iv ("add", one, ...
                                    svt_iv ("sqrt", svt_iv ("sub", one, g_v))));
  v_norm = svt_iv ("sqrt", svt_iv ("add", one, g_v));
  s_max = svt_iv ("point", s(1, 1), q);
  epsilon = svt_iv ("add", residual, svt_iv ("mul", s_max, ...
                         svt_iv ("add", svt_iv ("mul", d_u, v_norm), d_v)));
  certificate.dU = d_u;
  certificate.dV = d_v;
  certificate.v_norm = v_norm;
  certificate.epsilon = epsilon;
  values_lower = mp (zeros (k, 1));
  values_upper = mp (zeros (k, 1));
  for index = 1:k
    singular = svt_iv ("point", s(index, index), q);
    lower = svt_iv ("sub", singular, epsilon).lo;
    if (lower < mp (0)), lower = mp (0); endif
    values_lower(index) = lower;
    values_upper(index) = svt_iv ("add", singular, epsilon).hi;
  endfor
  certificate.values_lower = values_lower;
  certificate.values_upper = values_upper;
  certificate.status = "CERTIFIED";
  certificate.claim = "every ordered singular value of represented A is enclosed";
  clear cleanup;
endfunction
