% Verified V-S3 point/cell pseudospectrum baseline.
% This is the finite polar/Weyl enclosure specified by CERTIFICATES.md;
% it is not a reproduction of a full pseudospectrum algorithm.
function result = net_v_s3_svd (A, z, epsilon, cell_box, source_bits, q)
  if (nargin != 6 || ! isa (A, "mp") || rows (A) != columns (A) ...
      || ! isa (z, "mp") || ! isscalar (z) || ! isfinite (real (z)) ...
      || ! isfinite (imag (z)) || ! isa (epsilon, "mp") ...
      || ! isscalar (epsilon) || ! isfinite (epsilon) || epsilon <= mp (0) ...
      || source_bits != fix (source_bits) || source_bits < 64 ...
      || q != fix (q) || q < source_bits)
    error ("mplapack:neigt:VS3", "invalid verified SVD arguments");
  endif
  if (! isempty (cell_box) && (! isstruct (cell_box) ...
      || ! isfield (cell_box, "real_halfwidth") ...
      || ! isfield (cell_box, "imag_halfwidth") ...
      || cell_box.real_halfwidth <= mp (0) ...
      || cell_box.imag_halfwidth <= mp (0)))
    error ("mplapack:neigt:VS3", "cell must have positive halfwidths");
  endif

  saved_bits = mpbits ();
  unwind_protect
    % Freeze the solver input and candidate outputs at source_bits.  The
    % proof below only widens these returned values; it never substitutes a
    % higher-precision solve or a known singular value.
    mpbits (source_bits);
    n = rows (A);
    B_candidate = z * mp (eye (n)) - A;
    [U, S, V] = svd (B_candidate);
    s = diag (S);
    if (rows (U) != n || columns (U) != n || rows (V) != n ...
        || columns (V) != n || numel (s) != n)
      error ("mplapack:neigt:VS3", "full square SVD output was not returned");
    endif
    if (! all (isfinite (real (U))) || ! all (isfinite (imag (U))) ...
        || ! all (isfinite (real (V))) || ! all (isfinite (imag (V))) ...
        || ! all (isfinite (s)) || any (s < mp (0)) ...
        || any (s(1:(n - 1)) < s(2:n)))
      error ("mplapack:neigt:VS3", ...
             "SVD candidate is not finite, nonnegative, and descending");
    endif
    raw = struct ("B_candidate", B_candidate, "U", U, "s", s, "V", V, ...
      "B_hash", net_raw_hash (B_candidate, "VS3_B_candidate"), ...
      "U_hash", net_raw_hash (U, "VS3_U_candidate"), ...
      "s_hash", net_raw_hash (s, "VS3_s_candidate"), ...
      "V_hash", net_raw_hash (V, "VS3_V_candidate"));

    % The exact target is the separate expression z*I-A.  Constructing this
    % as rectangle arithmetic retains the expression enclosure even when
    % z*I-A was rounded while forming the solver input above.
    mpbits (q);
    B_exact = net_iv_cmatrix_sub (net_iv_cmatrix_point (z * mp (eye (n)), q), ...
                                  net_iv_cmatrix_point (A, q), q);
    Ub = net_iv_cmatrix_point (net_widen (U, q, source_bits), q);
    Vb = net_iv_cmatrix_point (net_widen (V, q, source_bits), q);
    sb = net_iv_cmatrix_point (net_widen (s, q, source_bits), q);
    Sbox = diagonal_box (sb, n, q);
    gram_u = net_iv_cmatrix_sub (net_iv_cmatrix_mul ...
      (net_iv_cmatrix_conjtrans (Ub), Ub, q), net_iv_cmatrix_eye (n, q), q);
    gram_v = net_iv_cmatrix_sub (net_iv_cmatrix_mul ...
      (net_iv_cmatrix_conjtrans (Vb), Vb, q), net_iv_cmatrix_eye (n, q), q);
    gU = net_iv_cmatrix_fro_upper (gram_u, q);
    gV = net_iv_cmatrix_fro_upper (gram_v, q);
    if (gU >= mp (1) || gV >= mp (1))
      error ("mplapack:neigt:VS3", "candidate singular vectors are not certifiably close to unitary");
    endif
    reconstruction = net_iv_cmatrix_mul (net_iv_cmatrix_mul (Ub, Sbox, q), ...
                                         net_iv_cmatrix_conjtrans (Vb), q);
    residual_box = net_iv_cmatrix_sub (B_exact, reconstruction, q);
    r = net_iv_cmatrix_fro_upper (residual_box, q);
    fU = scalar_f (gU, q);
    fV = scalar_f (gV, q);
    one_plus_gv = net_iv_real (net_iv_primitive ("add", mp (1), gV, q).lo, ...
                               net_iv_primitive ("add", mp (1), gV, q).hi);
    term_u = net_iv_primitive ("mul", fU, ...
      net_iv_real_sqrt (net_iv_real (net_iv_primitive ("add", mp (1), gV, q).lo, ...
                                     net_iv_primitive ("add", mp (1), gV, q).hi), q).hi, q).hi;
    term_v = fV;
    % The formula uses fU*sqrt(1+gV)+fV.  Keep every scalar operation in
    % the audited outward primitive path; one_plus_gv is retained in the
    % record to make the proof data explicit.
    unused = one_plus_gv; %#ok<NASGU>
    bracket = net_iv_primitive ("add", term_u, term_v, q).hi;
    s1_upper = sb.rh(1);
    sn_lower = sb.rl(numel (s));
    sn_upper = sb.rh(numel (s));
    delta = net_iv_primitive ("add", r, ...
      net_iv_primitive ("mul", s1_upper, bracket, q).hi, q).hi;
    lower_s = net_iv_primitive ("sub", sn_lower, delta, q).lo;
    upper_s = net_iv_primitive ("add", sn_upper, delta, q).hi;
    lower = max (mp (0), lower_s);
    upper = upper_s;
    point_status = net_v_s3_classify (lower, upper, epsilon);
    A_norm = net_iv_cmatrix_fro_upper (net_iv_cmatrix_point (A, q), q);
    z_abs = net_iv_complex_abs (net_iv_complex_point (z, q), q);
    norm_margin = net_iv_primitive ("sub", z_abs.lo, A_norm, q).lo;
    norm_outside = norm_margin > epsilon;
    if (strcmp (point_status, "CERTIFIED_OUTSIDE") && norm_outside)
      % The norm witness can only strengthen an outside classification.  It
      % is never used to turn a straddling SVD enclosure into a claim.
      point_status = "CERTIFIED_OUTSIDE";
    endif

    result = struct ("method", "neigt_svd_pseudospectrum_point_v1", ...
      "paper_algorithm_reproduction", false, "status", point_status, ...
      "claim_status", point_status, "pass", true, "epsilon", epsilon, ...
      "source_bits", source_bits, "evaluation_bits", q, "raw", raw, ...
      "B_exact", B_exact, "candidate_singular_values", sb, ...
      "gU", gU, "gV", gV, "fU", fU, "fV", fV, "residual", r, ...
      "delta", delta, "lower", lower, "upper", upper, ...
      "A_fro_upper", A_norm, "z_abs_lower", z_abs.lo, ...
      "norm_margin_lower", norm_margin, ...
      "norm_outside_witness", norm_outside, ...
      "target", "exact_expression_zI_minus_A", "cell", []);

    if (! isempty (cell_box))
      hx = cell_box.real_halfwidth;
      hy = cell_box.imag_halfwidth;
      d = net_iv_primitive ("add", hx, hy, q).hi;
      cell_lower = max (mp (0), net_iv_primitive ("sub", lower, d, q).lo);
      cell_upper = net_iv_primitive ("add", upper, d, q).hi;
      cell_box_iv = net_iv_complex (real (z) - hx, real (z) + hx, ...
                                    imag (z) - hy, imag (z) + hy);
      cell_abs = net_iv_complex_abs (cell_box_iv, q);
      cell_norm_margin = net_iv_primitive ("sub", cell_abs.lo, A_norm, q).lo;
      cell_norm_outside = cell_norm_margin > epsilon;
      cell_status = net_v_s3_classify (cell_lower, cell_upper, epsilon);
      if (strcmp (cell_status, "CERTIFIED_OUTSIDE") && cell_norm_outside)
        cell_status = "CERTIFIED_OUTSIDE";
      endif
      cell_area = net_iv_primitive ("mul", ...
        net_iv_primitive ("mul", hx, hy, q).hi, mp (4), q).hi;
      result.cell = struct ("status", cell_status, "lower", cell_lower, ...
        "upper", cell_upper, "distance", d, "halfwidth_real", hx, ...
        "halfwidth_imag", hy, "area", cell_area, ...
        "positive_area", cell_area > mp (0), ...
        "norm_margin_lower", cell_norm_margin, ...
        "norm_outside_witness", cell_norm_outside, ...
        "lipschitz", "sigma_min is 1-Lipschitz in z under the 2-norm");
      result.method = "neigt_svd_pseudospectrum_cell_v1";
      result.status = cell_status;
      result.claim_status = cell_status;
    endif
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function result = scalar_f (g, q)
  root_arg = net_iv_real (net_iv_primitive ("sub", mp (1), g, q).lo, ...
                          net_iv_primitive ("sub", mp (1), g, q).hi);
  root = net_iv_real_sqrt (root_arg, q);
  denominator = net_iv_real (net_iv_primitive ("add", mp (1), root.lo, q).lo, ...
                             net_iv_primitive ("add", mp (1), root.hi, q).hi);
  result = net_iv_real_div (net_iv_real (g, g), denominator, q).hi;
endfunction

function result = diagonal_box (diagonal, n, q)
  result = net_iv_cmatrix_point (mp (zeros (n, n)), q);
  for index = 1:n
    result.rl(index,index) = diagonal.rl(index);
    result.rh(index,index) = diagonal.rh(index);
    result.il(index,index) = diagonal.il(index);
    result.ih(index,index) = diagonal.ih(index);
  endfor
endfunction
