% Identify a separated V-S2 cluster and bound the raw-basis projector error.
% This checker is independent of candidate preparation.  It consumes only the
% outward graph boxes and the point candidate supplied to the graph proof.
function result = net_v_s2_cluster (graph, X, center, job, profile, q)
  if (nargin != 6)
    error ("mplapack:neigt:VS2Cluster", ...
           "graph, X, center, job, profile, and q are required");
  endif
  result = cluster_template ();
  if (! isstruct (graph) || ! isfield (graph, "pass") || ! graph.pass ...
      || ! isfield (graph, "M_box") || ! isfield (graph, "D2_box") ...
      || ! isa (X, "mp") || ! isstruct (job) ...
      || ! isfield (job, "cluster_dimension") || ! isscalar (center) ...
      || ! isa (center, "mp") || ! isfinite (center) || q < 64 || q > 4096)
    result.status = "ERROR_INVALID_INPUT";
    result.claim_status = "ERROR";
    return;
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (q);
    k = job.cluster_dimension;
    n = rows (X);
    h = n - k;
    result.k = k;
    result.h = h;
    result.n = n;
    result.query_center = center;
    result.query_radius = net_dyadic_parameter (job.fixture.query_radius, q);
    result.power_order = power_order (job);
    if (strcmp (char (job.fixture.regime), "two_jordan"))
      result.refined_power_order = 4 * k;
    else
      result.refined_power_order = result.power_order;
    endif
    result.profile = profile;
    result.raw_X_hash = net_raw_hash (X, "VS2_raw_candidate_X");
    if (k < 1 || k >= n || columns (X) != n)
      result.status = "INCONCLUSIVE_FULL_SPACE_OR_DIMENSION";
      result.claim_status = "INCONCLUSIVE";
      return;
    endif

    M = graph.M_box;
    D2 = graph.D2_box;
    result.M_gershgorin = gershgorin_disks (M, q);
    result.D2_gershgorin = gershgorin_disks (D2, q);

    % The Gershgorin data are retained for a direct disk enclosure.  The
    % centered power disk is the required sharp region for defective blocks;
    % its center is the requested query center, not an assumed root.
    shifted = net_iv_cmatrix_sub (M, scalar_eye (center, k, q), q);
    required_power_box = scalar_power (shifted, result.power_order, q);
    required_power_norm = net_iv_cmatrix_inf_upper (required_power_box, q);
    required_power_radius = root_radius (required_power_norm, ...
                                         result.power_order, q);
    refined_power_box = scalar_power (shifted, result.refined_power_order, q);
    refined_power_norm = net_iv_cmatrix_inf_upper (refined_power_box, q);
    refined_power_radius = root_radius (refined_power_norm, ...
                                        result.refined_power_order, q);
    power_box = refined_power_box;
    power_norm = refined_power_norm;
    power_radius = refined_power_radius;
    gersh_radius = centered_gersh_radius (result.M_gershgorin, center, q);
    result.centered_power_box = power_box;
    result.centered_power_norm = power_norm;
    result.centered_power_radius = power_radius;
    result.required_centered_power_box = required_power_box;
    result.required_centered_power_norm = required_power_norm;
    result.required_centered_power_radius = required_power_radius;
    result.refined_centered_power_box = refined_power_box;
    result.refined_centered_power_norm = refined_power_norm;
    result.refined_centered_power_radius = refined_power_radius;
    result.M_gershgorin_centered_radius = gersh_radius;
    result.centered_power_required = strcmp (char (job.fixture.regime), ...
                                             "jordan") ...
                                      || strcmp (char (job.fixture.regime), ...
                                                 "two_jordan") ...
                                      || strcmp (char (job.fixture.regime), ...
                                                 "mks_zero");
    result.merged_polynomial = [];
    result.spectral_region_method = "centered_power";
    cluster_target = cluster_radius_target (job, profile, q);

    % A power disk contains every M eigenvalue.  For the complement use the
    % union of its interval Gershgorin disks, which is safe even when D2 is
    % nonnormal.  The selected query radius is only a quality target; it is
    % never used as a proof of the spectrum.
    region_radius = power_radius;
    if (strcmp (char (job.fixture.regime), "two_jordan"))
      % A centered raw power is deliberately retained above.  For two
      % distinct size-two defective groups it can be dominated by the
      % nilpotent term (M-cI)^16 even when the spectrum is much tighter.
      % The following independently proves a sharper disk from a polynomial
      % power of the computed M box; it does not consume known roots or a
      % generator basis.
      merged = merged_polynomial_certificate (M, center, cluster_target, q);
      result.merged_polynomial = merged;
      if (merged.pass)
        region_radius = cluster_target;
        result.spectral_region_method = "centered_polynomial_power";
      endif
    endif
    if (isfield (job, "adversarial_claimed_radius"))
      region_radius = job.adversarial_claimed_radius;
      result.adversarial_override = true;
    else
      result.adversarial_override = false;
    endif
    d2_separation = true;
    d2_disks = result.D2_gershgorin.disks;
    for index = 1:numel (d2_disks)
      disk = d2_disks(index);
      distance = net_iv_complex_abs (net_iv_complex_point (...
        center - disk.center, q), q).lo;
      sum_radius = net_iv_primitive ("add", region_radius, ...
                                     disk.radius, q).hi;
      disk.separation_distance = distance;
      disk.separation_limit = sum_radius;
      disk.separated = distance > sum_radius;
      d2_separation = d2_separation && disk.separated;
      d2_disks(index) = disk;
    endfor
    result.D2_gershgorin.disks = d2_disks;
    result.region_radius = region_radius;
    result.strict_separation = d2_separation;
    result.counted_M_roots = k;
    result.counted_D2_roots = h;
    result.counted_total_roots = k + h;
    result.counting_argument = "exact_graph_block_sizes_plus_strict_M_D2_separation";

    result.projector = raw_projector_bound (X, graph, k, q, profile);
    result.cluster_radius_target = cluster_target;
    result.projector_target = projector_target (profile, q);
    result.cluster_radius_pass = region_radius <= result.cluster_radius_target;
    result.projector_pass = result.projector.pass ...
                            && result.projector.bound <= result.projector_target;
    result.centered_power_pass = (! result.centered_power_required ...
                                  || power_radius <= result.cluster_radius_target ...
                                  || (isstruct (result.merged_polynomial) ...
                                      && result.merged_polynomial.pass));
    result.root_count_pass = d2_separation && result.counted_total_roots == n;
    result.cluster_pass = result.root_count_pass ...
                          && result.cluster_radius_pass ...
                          && result.centered_power_pass ...
                          && result.projector_pass ...
                          && ! result.adversarial_override;
    if (result.cluster_pass)
      result.status = "CERTIFIED_CLUSTER";
      result.claim_status = "CERTIFIED_CLUSTER";
      result.claim_quality = "resolved";
      result.pass = true;
      result.nontrivial = true;
    elseif (! d2_separation)
      result.status = "INCONCLUSIVE_CLUSTER_SEPARATION";
      result.claim_status = "CERTIFIED_INVARIANT_BASIS";
      result.claim_quality = "not_identified";
    elseif (! result.projector_pass)
      result.status = "INCONCLUSIVE_PROJECTOR";
      result.claim_status = "CERTIFIED_INVARIANT_BASIS";
      result.claim_quality = "not_identified";
    else
      result.status = "INCONCLUSIVE_CLUSTER_RADIUS";
      result.claim_status = "CERTIFIED_INVARIANT_BASIS";
      result.claim_quality = "not_identified";
    endif
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function value = power_order (job)
  regime = char (job.fixture.regime);
  if (strcmp (regime, "jordan") || strcmp (regime, "two_jordan") ...
      || strcmp (regime, "mks_zero"))
    % The required defective fixtures have nilpotent block length two.  For
    % the merged job this is deliberately the block dimension, not the total
    % selected cluster dimension four.
    value = 2;
  else
    value = job.cluster_dimension;
  endif
endfunction

function result = cluster_template ()
  result = struct ("method", "neigt_cluster_power_projector_v1", ...
    "paper_algorithm_reproduction", false, "status", "INCONCLUSIVE", ...
    "pass", false, "claim_status", "INCONCLUSIVE", ...
    "claim_quality", "not_identified", "nontrivial", false, ...
    "strict_separation", false, "root_count_pass", false, ...
    "centered_power_required", false, "centered_power_pass", false, ...
    "cluster_radius_pass", false, "projector_pass", false, ...
    "adversarial_override", false, "counted_M_roots", 0, ...
    "counted_D2_roots", 0, "counted_total_roots", 0);
endfunction

function result = scalar_eye (center, n, q)
  result = net_iv_cmatrix_point (center * mp (eye (n)), q);
endfunction

function result = scalar_power (base, exponent, q)
  result = net_iv_cmatrix_eye (rows (base.rl), q);
  for index = 1:exponent
    result = net_iv_cmatrix_mul (result, base, q);
  endfor
endfunction

function value = root_radius (bound, exponent, q)
  if (bound == mp (0))
    value = mp (0);
    return;
  endif
  exponent2 = floor (net_ufp (bound) / exponent);
  value = net_pow2 (exponent2, q);
  while (point_power_upper (value, exponent, q) < bound)
    exponent2 += 1;
    value = net_pow2 (exponent2, q);
  endwhile
endfunction

function value = point_power_upper (base, exponent, q)
  value = mp (1);
  for index = 1:exponent
    value = net_iv_primitive ("mul", value, base, q).hi;
  endfor
endfunction

function result = gershgorin_disks (matrix, q)
  n = rows (matrix.rl);
  disks = repmat (struct ("center", mp (0), "radius", mp (0), ...
                          "diagonal_uncertainty", mp (0), ...
                          "offdiagonal_radius", mp (0), ...
                          "separation_distance", mp (0), ...
                          "separation_limit", mp (0), "separated", false), n, 1);
  for i = 1:n
    diagonal = entry (matrix, i, i);
    center = midpoint (diagonal, q);
    deviation = net_iv_complex_sub (diagonal, ...
                                    net_iv_complex_point (center, q), q);
    diagonal_uncertainty = net_iv_complex_abs (deviation, q).hi;
    offdiag = mp (0);
    for j = 1:n
      if (i != j)
        offdiag = net_iv_primitive ("add", offdiag, ...
          net_iv_complex_abs (entry (matrix, i, j), q).hi, q).hi;
      endif
    endfor
    disks(i).center = center;
    disks(i).diagonal_uncertainty = diagonal_uncertainty;
    disks(i).offdiagonal_radius = offdiag;
    disks(i).radius = net_iv_primitive ("add", diagonal_uncertainty, ...
                                        offdiag, q).hi;
  endfor
  result = struct ("method", "neigt_interval_gershgorin_v1", ...
                   "disks", disks, "count", n);
endfunction

function value = centered_gersh_radius (record, center, q)
  value = mp (0);
  for index = 1:numel (record.disks)
    distance = net_iv_complex_abs (net_iv_complex_point (...
      record.disks(index).center - center, q), q).hi;
    total = net_iv_primitive ("add", distance, record.disks(index).radius, q).hi;
    if (total > value)
      value = total;
    endif
  endfor
endfunction

function result = raw_projector_bound (X, graph, k, q, profile)
  n = rows (X);
  h = n - k;
  X1 = net_iv_cmatrix_point (X(:, 1:k), q);
  X2 = net_iv_cmatrix_point (X(:, (k + 1):n), q);
  gram_error = net_iv_cmatrix_sub (...
    net_iv_cmatrix_mul (net_iv_cmatrix_conjtrans (X1), X1, q), ...
    net_iv_cmatrix_eye (k, q), q);
  g1 = net_iv_cmatrix_fro_upper (gram_error, q);
  result = struct ("method", "neigt_raw_basis_projector_bound_v1", ...
                   "g1", g1, "alo", mp (0), "b", mp (0), ...
                   "sine_bound", mp (0), "subspace_projector_bound", mp (0), ...
                   "raw_projector_bound", mp (0), "bound", mp (0), ...
                   "pass", false, ...
                   "gram_error", gram_error, "X1_hash", ...
                   net_raw_hash (X(:, 1:k), "VS2_raw_X1"));
  if (g1 >= mp (1))
    result.status = "INCONCLUSIVE_RAW_BASIS_GRAM";
    return;
  endif
  one_minus = net_iv_primitive ("sub", mp (1), g1, q).lo;
  alo = net_iv_real_sqrt (net_iv_real (one_minus, one_minus), q).lo;
  result.alo = alo;
  x2_norm = net_iv_cmatrix_fro_upper (X2, q);
  factor = net_iv_real_sqrt (net_iv_real (mp (h * k), mp (h * k)), q).hi;
  t = graph.Z_radius;
  b = net_iv_primitive ("mul", x2_norm, factor, q).hi;
  b = net_iv_primitive ("mul", b, t, q).hi;
  result.b = b;
  if (b >= alo)
    result.status = "INCONCLUSIVE_PROJECTOR_DENOMINATOR";
    return;
  endif
  denominator = net_iv_primitive ("sub", alo, b, q).lo;
  sine = net_iv_primitive ("div", b, denominator, q).hi;
  result.sine_bound = sine;
  factor_projector = net_iv_real_sqrt (...
    net_iv_real (mp (2 * k), mp (2 * k)), q).hi;
  subspace = net_iv_primitive ("mul", factor_projector, sine, q).hi;
  total = net_iv_primitive ("add", subspace, g1, q).hi;
  result.subspace_projector_bound = subspace;
  result.raw_projector_bound = total;
  result.bound = total;
  result.status = "COMPUTED";
  result.pass = true;
endfunction

function value = cluster_radius_target (job, profile, q)
  if (isfield (job, "cluster_radius_target_exponent"))
    value = net_pow2 (job.cluster_radius_target_exponent, q);
    return;
  endif
  if (strcmp (profile, "demo"))
    target = net_pow2 (-48, q);
  else
    target = net_pow2 (-24, q);
  endif
  if (strcmp (char (job.fixture.regime), "two_jordan"))
    gap = net_pow2 (-job.fixture.gap_exponent, q);
    target = net_iv_primitive ("mul", mp (2), gap, q).hi + target;
  endif
  value = target;
endfunction

function value = projector_target (profile, q)
  if (strcmp (profile, "demo"))
    value = net_pow2 (-64, q);
  else
    value = net_pow2 (-40, q);
  endif
endfunction

function result = merged_polynomial_certificate (M, center, target, q)
  result = struct ("method", "neigt_centered_polynomial_power_v1", ...
    "paper_algorithm_reproduction", false, "pass", false, ...
    "status", "INCONCLUSIVE", "center", [], "second_moment", [], ...
    "polynomial_norm", mp ("NaN"), "local_radius", mp ("NaN"), ...
    "polynomial_lower_bound", mp ("NaN"));
  n = rows (M.rl);
  trace_M = net_iv_complex (mp (0), mp (0), mp (0), mp (0));
  for index = 1:n
    trace_M = net_iv_complex_add (trace_M, entry (M, index, index), q);
  endfor
  mean_box = divide_complex_box (trace_M, n, q);
  centered = net_iv_cmatrix_sub (M, scalar_interval_eye (mean_box, n, q), q);
  centered_square = net_iv_cmatrix_mul (centered, centered, q);
  trace_square = net_iv_complex (mp (0), mp (0), mp (0), mp (0));
  for index = 1:n
    trace_square = net_iv_complex_add (trace_square, ...
      entry (centered_square, index, index), q);
  endfor
  second_moment = divide_complex_box (trace_square, n, q);
  polynomial_base = net_iv_cmatrix_sub ...
    (centered_square, scalar_interval_eye (second_moment, n, q), q);
  polynomial_box = net_iv_cmatrix_mul (polynomial_base, polynomial_base, q);
  polynomial_norm = net_iv_cmatrix_inf_upper (polynomial_box, q);
  center_offset = net_iv_complex_abs (net_iv_complex_sub (mean_box, ...
    net_iv_complex_point (center, q), q), q).hi;
  local_radius_box = net_iv_primitive ("sub", target, center_offset, q);
  result.center = mean_box;
  result.second_moment = second_moment;
  result.polynomial_box = polynomial_box;
  result.polynomial_norm = polynomial_norm;
  result.center_offset_upper = center_offset;
  result.local_radius = local_radius_box.lo;
  if (local_radius_box.lo <= mp (0))
    result.status = "INCONCLUSIVE_CENTER_OFFSET";
    return;
  endif
  second_moment_abs = net_iv_complex_abs (second_moment, q).hi;
  local_square = net_iv_primitive ("mul", local_radius_box.lo, ...
                                   local_radius_box.lo, q).lo;
  radial_gap = net_iv_primitive ("sub", local_square, ...
                                 second_moment_abs, q).lo;
  if (radial_gap <= mp (0))
    result.status = "INCONCLUSIVE_POLYNOMIAL_SEPARATION";
    result.second_moment_abs_upper = second_moment_abs;
    return;
  endif
  lower_bound = net_iv_primitive ("mul", radial_gap, radial_gap, q).lo;
  result.second_moment_abs_upper = second_moment_abs;
  result.radial_gap = radial_gap;
  result.polynomial_lower_bound = lower_bound;
  result.pass = polynomial_norm < lower_bound;
  if (result.pass)
    result.status = "CERTIFIED_MERGED_DISK";
  else
    result.status = "INCONCLUSIVE_POLYNOMIAL_RESIDUAL";
  endif
endfunction

function result = divide_complex_box (box, denominator, q)
  denominator_box = net_iv_real (mp (denominator), mp (denominator));
  real_part = net_iv_real_div (net_iv_real (box.rl, box.rh), ...
                               denominator_box, q);
  imag_part = net_iv_real_div (net_iv_real (box.il, box.ih), ...
                               denominator_box, q);
  result = net_iv_complex (real_part.lo, real_part.hi, ...
                           imag_part.lo, imag_part.hi);
endfunction

function result = scalar_interval_eye (box, n, q)
  result = net_iv_cmatrix_point (mp (zeros (n, n)), q);
  for index = 1:n
    result.rl(index,index) = box.rl;
    result.rh(index,index) = box.rh;
    result.il(index,index) = box.il;
    result.ih(index,index) = box.ih;
  endfor
endfunction

function value = entry (matrix, i, j)
  value = net_iv_complex (matrix.rl(i,j), matrix.rh(i,j), ...
                          matrix.il(i,j), matrix.ih(i,j));
endfunction

function value = midpoint (box, q)
  re = (box.rl + box.rh) * mp ("0.5");
  im = (box.il + box.ih) * mp ("0.5");
  value = net_mp_complex (re, im);
endfunction
