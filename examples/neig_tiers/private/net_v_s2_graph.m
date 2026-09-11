% Conservative verified invariant-graph checker from CERTIFICATES.md.
% Candidate preparation and this proof are deliberately separate: the proof
% only trusts the supplied point A/X and checks every required nonsingularity
% and contraction inequality with outward rectangles.
function result = net_v_s2_graph (A, X, k, q, options)
  if (nargin < 4 || nargin > 5)
    error ("mplapack:neigt:VS2", "expected A, X, k, q, and optional options");
  endif
  if (nargin == 4)
    options = struct ();
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (q);
    result = graph_failure_template ("INCONCLUSIVE");
    if (! valid_inputs (A, X, k, q))
      result.status = "ERROR_INVALID_INPUT";
      return;
    endif
    transpose_mode = "nonconjugating";
    if (isfield (options, "transpose_mode"))
      transpose_mode = options.transpose_mode;
    endif
    if (! ischar (transpose_mode) || ! strcmp (transpose_mode, "nonconjugating"))
      result.status = "UNSUPPORTED_WRONG_KRONECKER_TRANSPOSE";
      result.claim_status = "UNSUPPORTED_DOMAIN";
      return;
    endif

    n = rows (A);
    h = n - k;
    I = mp (eye (n));
    % These are auxiliary point operations.  They are retained separately
    % from the outward proof below and never replace it.
    R_candidate = X \ I;
    C0 = X \ (A * X);
    result.candidate_inverse = R_candidate;
    result.candidate_C0 = C0;
    result.candidate_C0_hash = net_raw_hash (C0, "VS2_candidate_C0");

    similarity = certified_similarity (A, X, R_candidate, C0, q, options);
    result.similarity = similarity;
    if (! similarity.basis_nonsingular)
      result.status = "INCONCLUSIVE_BASIS_INVERSE";
      result.claim_status = "INCONCLUSIVE";
      return;
    endif
    C = similarity.C_box;
    C11 = matrix_block (C, 1:k, 1:k);
    C12 = matrix_block (C, 1:k, (k + 1):n);
    C21 = matrix_block (C, (k + 1):n, 1:k);
    C22 = matrix_block (C, (k + 1):n, (k + 1):n);
    K = net_iv_cmatrix_sub ...
      (net_iv_cmatrix_kron (net_iv_cmatrix_eye (k, q), C22, q), ...
       net_iv_cmatrix_kron (nonconjugating_transpose (C11), ...
                            net_iv_cmatrix_eye (h, q), q), q);
    K_mid = midpoint_matrix (K, q);
    if (isfield (options, "preconditioner"))
      R_s = options.preconditioner;
      if (! isa (R_s, "mp") || ! isequal (size (R_s), [h * k, h * k]))
        result.status = "INCONCLUSIVE_BAD_PRECONDITIONER";
        result.claim_status = "INCONCLUSIVE";
        return;
      endif
    else
      R_s = K_mid \ mp (eye (h * k));
    endif
    result.preconditioner = R_s;
    K_residual = net_iv_cmatrix_sub ...
      (net_iv_cmatrix_eye (h * k, q), ...
       net_iv_cmatrix_mul (net_iv_cmatrix_point (R_s, q), K, q), q);
    e = net_iv_cmatrix_inf_upper (K_residual, q);
    c_vector = net_iv_cmatrix_mul (net_iv_cmatrix_point (R_s, q), ...
                                   vector_box (C21, q), q);
    c = net_iv_cmatrix_inf_upper (c_vector, q);
    r_norm = net_iv_cmatrix_inf_upper (net_iv_cmatrix_point (R_s, q), q);
    c12_max = max_entry_modulus (C12, q);
    kh = mp (k * h);
    g = net_iv_primitive ("mul", r_norm, kh, q).hi;
    g = net_iv_primitive ("mul", g, c12_max, q).hi;
    result.e = e;
    result.c = c;
    result.g = g;
    result.K = K;
    result.K_mid = K_mid;
    result.preconditioner_residual_pass = e < mp (1);
    if (! result.preconditioner_residual_pass)
      result.status = "INCONCLUSIVE_PRECONDITIONER_RESIDUAL";
      result.claim_status = "INCONCLUSIVE";
      return;
    endif

    [initial_exponent, initial_bound] = initial_radius (c, e, q);
    result.initial_radius_bound = initial_bound;
    result.initial_radius_exponent = initial_exponent;
    trials = struct ([]);
    accepted = false;
    accepted_t = mp (0);
    for trial_index = 0:7
      t = net_pow2 (initial_exponent + trial_index, q);
      trial = radius_trial (c, e, g, t, q, trial_index + 1);
      if (isempty (trials))
        trials = trial;
      else
        trials(end + 1) = trial;
      endif
      if (trial.self_map && trial.contraction)
        accepted = true;
        accepted_t = t;
        break;
      endif
      if (! trial.contraction_possible)
        break;
      endif
    endfor
    result.trials = trials;
    result.radius_trial_count = numel (trials);
    result.contraction_pass = accepted;
    if (! accepted)
      result.status = "INCONCLUSIVE_CONTRACTION";
      result.claim_status = "INCONCLUSIVE";
      return;
    endif

    % The polydisk proof is complete before the larger rectangle is formed.
    % The rectangle below is only the returned enclosure of the fixed point.
    Z_box = constant_rectangle (h, k, -accepted_t, accepted_t, ...
                                -accepted_t, accepted_t);
    X1 = matrix_block (net_iv_cmatrix_point (X, q), 1:n, 1:k);
    X2 = matrix_block (net_iv_cmatrix_point (X, q), 1:n, (k + 1):n);
    Y1_box = net_iv_cmatrix_add (X1, net_iv_cmatrix_mul (X2, Z_box, q), q);
    M_box = net_iv_cmatrix_add (C11, net_iv_cmatrix_mul (C12, Z_box, q), q);
    result.Z_box = Z_box;
    result.Z_radius = accepted_t;
    result.Y1_box = Y1_box;
    result.M_box = M_box;
    % The lower-left block of the exact graph similarity is zero and the
    % complementary diagonal block is D2=C22-Z*C12.  Keep this enclosure
    % separate so NEIGT16 can prove spectral separation without treating a
    % graph-existence result as an isolated-cluster result.
    result.D2_box = net_iv_cmatrix_sub (C22, ...
                                        net_iv_cmatrix_mul (Z_box, C12, q), q);
    result.k = k;
    result.h = h;
    result.n = n;
    result.method = "neigt_riccati_graph_v1";
    result.paper_algorithm_reproduction = false;
    result.claim_status = "CERTIFIED_INVARIANT_BASIS";
    result.claim_quality = "not_identified";
    result.status = "CERTIFIED_INVARIANT_BASIS";
    result.pass = true;
    result.nontrivial = (k > 0 && k < n);
    result.full_space_triviality = false;
    result.candidate_source = "computed_candidate_basis_bounded_schedule";
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function value = valid_inputs (A, X, k, q)
  value = isa (A, "mp") && isa (X, "mp") && rows (A) == columns (A) ...
    && isequal (size (A), size (X)) && isscalar (k) && k == fix (k) ...
    && k >= 1 && k < rows (A) && q >= 64 && q <= 4096;
endfunction

function result = graph_failure_template (status)
  result = struct ("method", "neigt_riccati_graph_v1", ...
    "paper_algorithm_reproduction", false, "status", status, "pass", false, ...
    "claim_status", "INCONCLUSIVE", "claim_quality", "not_identified", ...
    "nontrivial", false, "full_space_triviality", false, ...
    "basis_nonsingular", false, "preconditioner_residual_pass", false, ...
    "contraction_pass", false, "candidate_source", "", ...
    "candidate_C0_hash", "", "trials", struct ([]));
endfunction

function result = certified_similarity (A, X, R, C0, q, options)
  n = rows (A);
  A_box = net_iv_cmatrix_point (A, q);
  if (isfield (options, "A_box"))
    if (! isstruct (options.A_box) || ! isequal (size (options.A_box.rl), size (A)))
      result = struct ("E_box", [], "e", mp ("NaN"), "basis_nonsingular", false, ...
                       "C0", C0, "C_box", [], "RF_box", [], "c", mp ("NaN"), ...
                       "eta", mp ("NaN"));
      return;
    endif
    A_box = options.A_box;
  endif
  X_box = net_iv_cmatrix_point (X, q);
  R_box = net_iv_cmatrix_point (R, q);
  E_box = net_iv_cmatrix_sub (net_iv_cmatrix_eye (n, q), ...
                              net_iv_cmatrix_mul (R_box, X_box, q), q);
  e = net_iv_cmatrix_inf_upper (E_box, q);
  result = struct ("E_box", E_box, "e", e, "basis_nonsingular", e < mp (1), ...
                   "C0", C0, "C_box", [], "RF_box", [], "c", mp ("NaN"), ...
                   "eta", mp ("NaN"));
  if (e >= mp (1))
    return;
  endif
  F_box = net_iv_cmatrix_sub ...
    (net_iv_cmatrix_mul (A_box, X_box, q), ...
     net_iv_cmatrix_mul (X_box, net_iv_cmatrix_point (C0, q), q), q);
  RF_box = net_iv_cmatrix_mul (R_box, F_box, q);
  c = net_iv_cmatrix_inf_upper (RF_box, q);
  denominator = net_iv_primitive ("sub", mp (1), e, q);
  eta = net_iv_primitive ("div", c, denominator.lo, q).hi;
  C_box = expand_modulus (net_iv_cmatrix_point (C0, q), eta, q);
  result.F_box = F_box;
  result.RF_box = RF_box;
  result.c = c;
  result.eta = eta;
  result.C_box = C_box;
endfunction

function [exponent, bound] = initial_radius (c, e, q)
  if (c == mp (0))
    exponent = -floor (q / 2);
    bound = mp (0);
    return;
  endif
  numerator = net_iv_primitive ("mul", mp (2), c, q).hi;
  denominator = net_iv_primitive ("sub", mp (1), e, q).lo;
  bound = net_iv_primitive ("div", numerator, denominator, q).hi;
  exponent = net_ufp (bound);
  t = net_pow2 (exponent, q);
  if (t <= bound)
    exponent += 1;
  endif
endfunction

function result = radius_trial (c, e, g, t, q, index)
  t2 = net_iv_primitive ("mul", t, t, q).hi;
  et = net_iv_primitive ("mul", e, t, q).hi;
  gt2 = net_iv_primitive ("mul", g, t2, q).hi;
  first = net_iv_primitive ("add", c, et, q).hi;
  self_bound = net_iv_primitive ("add", first, gt2, q).hi;
  two_g = net_iv_primitive ("mul", mp (2), g, q).hi;
  two_gt = net_iv_primitive ("mul", two_g, t, q).hi;
  contraction_bound = net_iv_primitive ("add", e, two_gt, q).hi;
  result = struct ("index", index, "t", t, "self_bound", self_bound, ...
                   "contraction_bound", contraction_bound, ...
                   "self_map", self_bound < t, "contraction", contraction_bound < mp (1), ...
                   "contraction_possible", contraction_bound < mp (1));
endfunction

function result = matrix_block (matrix, rows_selected, cols_selected)
  result = matrix;
  result.rl = matrix.rl(rows_selected, cols_selected);
  result.rh = matrix.rh(rows_selected, cols_selected);
  result.il = matrix.il(rows_selected, cols_selected);
  result.ih = matrix.ih(rows_selected, cols_selected);
endfunction

function result = vector_box (matrix, q)
  result = matrix;
  result.rl = matrix.rl(:);
  result.rh = matrix.rh(:);
  result.il = matrix.il(:);
  result.ih = matrix.ih(:);
endfunction

function result = nonconjugating_transpose (matrix)
  result = matrix;
  result.rl = transpose (matrix.rl);
  result.rh = transpose (matrix.rh);
  result.il = transpose (matrix.il);
  result.ih = transpose (matrix.ih);
endfunction

function result = expand_modulus (matrix, eta, q)
  result = matrix;
  for index = 1:numel (matrix.rl)
    result.rl(index) = net_iv_primitive ("sub", matrix.rl(index), eta, q).lo;
    result.rh(index) = net_iv_primitive ("add", matrix.rh(index), eta, q).hi;
    result.il(index) = net_iv_primitive ("sub", matrix.il(index), eta, q).lo;
    result.ih(index) = net_iv_primitive ("add", matrix.ih(index), eta, q).hi;
  endfor
endfunction

function result = midpoint_matrix (matrix, q)
  result = mp (zeros (size (matrix.rl)));
  half = mp ("0.5");
  for index = 1:numel (result)
    re = (matrix.rl(index) + matrix.rh(index)) * half;
    im = (matrix.il(index) + matrix.ih(index)) * half;
    result(index) = net_mp_complex (re, im);
  endfor
endfunction

function result = max_entry_modulus (matrix, q)
  result = mp (0);
  for index = 1:numel (matrix.rl)
    value = net_iv_complex_abs (entry_box (matrix, index), q).hi;
    if (value > result)
      result = value;
    endif
  endfor
endfunction

function result = entry_box (matrix, index)
  if (isscalar (matrix.rl))
    result = net_iv_complex (matrix.rl, matrix.rh, matrix.il, matrix.ih);
  else
    result = net_iv_complex (matrix.rl(index), matrix.rh(index), ...
                             matrix.il(index), matrix.ih(index));
  endif
endfunction

function result = constant_rectangle (m, n, rl, rh, il, ih)
  result = struct ("kind", "complex_matrix", ...
    "rl", rl * mp (ones (m, n)), "rh", rh * mp (ones (m, n)), ...
    "il", il * mp (ones (m, n)), "ih", ih * mp (ones (m, n)));
endfunction

% Explicit interval Kronecker product.  The nonconjugating transpose is
% supplied by the caller; no public matrix kron is used on proof data.
function result = net_iv_cmatrix_kron (left, right, q)
  net_iv_q (q);
  if (! valid_matrix_local (left) || ! valid_matrix_local (right))
    error ("mplapack:neigt:MatrixInterval", "invalid Kronecker operands");
  endif
  m = rows (left.rl) * rows (right.rl);
  n = columns (left.rl) * columns (right.rl);
  result = struct ("kind", "complex_matrix", "rl", mp (zeros (m,n)), ...
                   "rh", mp (zeros (m,n)), "il", mp (zeros (m,n)), ...
                   "ih", mp (zeros (m,n)));
  for i = 1:rows (left.rl)
    for j = 1:columns (left.rl)
      for u = 1:rows (right.rl)
        for v = 1:columns (right.rl)
          value = net_iv_complex_mul (entry_box (left, sub2ind (size (left.rl), i, j)), ...
                                      entry_box (right, sub2ind (size (right.rl), u, v)), q);
          row = (i - 1) * rows (right.rl) + u;
          col = (j - 1) * columns (right.rl) + v;
          result.rl(row,col) = value.rl;
          result.rh(row,col) = value.rh;
          result.il(row,col) = value.il;
          result.ih(row,col) = value.ih;
        endfor
      endfor
    endfor
  endfor
endfunction

function value = valid_matrix_local (matrix)
  value = isstruct (matrix) && isfield (matrix, "kind") ...
    && strcmp (matrix.kind, "complex_matrix") && isfield (matrix, "rl") ...
    && isfield (matrix, "rh") && isfield (matrix, "il") && isfield (matrix, "ih") ...
    && isequal (size (matrix.rl), size (matrix.rh)) ...
    && isequal (size (matrix.rl), size (matrix.il)) ...
    && isequal (size (matrix.rl), size (matrix.ih));
endfunction
