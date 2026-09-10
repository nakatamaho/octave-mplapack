## SPDX-License-Identifier: BSD-2-Clause

function certificate = svt_certify_inverse (a, x, q)
  ## V3 verified inverse residual and inverse-norm/sigma-min bounds.
  certificate = struct ("schema", "svt-v3-inverse-certificate-v1", ...
                        "method", "svt_neumann_inverse_v1", "status", "ERROR", ...
                        "paper_algorithm_reproduction", false, "q", q);
  if (! isa (a, "mp") || ! isa (x, "mp") || ndims (a) != 2 || ndims (x) != 2)
    error ("mplapack:svt:InverseInput", "V3 requires 2-D mp matrices");
  endif
  [m, n] = size (a);
  if (m != n)
    certificate.status = "UNSUPPORTED_RECTANGULAR";
    certificate.reason = "Neumann inverse route requires a square matrix";
    return;
  endif
  if (size (x, 1) != n || size (x, 2) != n)
    error ("mplapack:svt:InverseShape", "approximate inverse has the wrong shape");
  endif
  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (q);
  svt_v0_contract (q);
  aq = svt_iv ("matrix_point", a, q);
  xq = svt_iv ("matrix_point", x, q);
  identity = svt_iv ("matrix_point", mp (eye (n)), q);
  residual = svt_iv ("matrix_sub", identity, svt_iv ("matrix_mul", aq, xq));
  r = svt_iv ("matrix_fro_upper", residual);
  certificate.residual = r;
  certificate.input_shape = [m, n];
  certificate.inverse_source_precision = __mplapack_core__ ("value_shape_info", x).precision_bits;
  if (r.hi >= mp (1))
    certificate.status = "INCONCLUSIVE";
    certificate.reason = "verified residual does not satisfy r<1";
    clear cleanup;
    return;
  endif
  x_norm = svt_iv ("matrix_fro_upper", xq);
  column_lower = svt_iv ("matrix_column_lower", xq);
  x_lower = column_lower(1);
  for index = 2:numel (column_lower)
    if (column_lower(index) > x_lower), x_lower = column_lower(index); endif
  endfor
  certificate.x_norm_upper = x_norm;
  certificate.x_column_lower = column_lower;
  certificate.x_norm_lower = x_lower;
  if (x_norm.hi == mp (0))
    certificate.status = "INCONCLUSIVE";
    certificate.reason = "inverse norm upper bound is zero";
    clear cleanup;
    return;
  endif
  one = svt_iv ("point", mp (1), q);
  one_minus_r = svt_iv ("sub", one, r);
  one_plus_r = svt_iv ("add", one, r);
  sigma_lower = svt_iv ("div", one_minus_r, x_norm).lo;
  certificate.sigma_min_lower = sigma_lower;
  certificate.inverse_norm_lower = svt_iv ("div", ...
                                           svt_iv ("point", x_lower, q), one_plus_r).lo;
  if (x_lower > mp (0))
    certificate.inverse_norm_upper = svt_iv ("div", one_plus_r, ...
                                             svt_iv ("point", x_lower, q)).hi;
    certificate.inverse_norm_upper_status = "FINITE";
  else
    certificate.inverse_norm_upper = [];
    certificate.inverse_norm_upper_status = "UNAVAILABLE_ZERO_COLUMN_LOWER";
  endif
  certificate.status = "CERTIFIED";
  certificate.claim = "A is nonsingular and sigma_min(A) has a positive verified lower bound";
  clear cleanup;
endfunction
