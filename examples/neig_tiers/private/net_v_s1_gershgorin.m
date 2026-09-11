% Conservative counted all-spectrum inclusion from CERTIFICATES.md section 1.
function result = net_v_s1_gershgorin (A, X, T, R, q, usefulness_exponent)
  net_iv_q (q);
  if (nargin != 6 || ! isa (A, "mp") || ! isa (X, "mp") ...
      || ! isa (T, "mp") || ! isa (R, "mp") || rows (A) != columns (A) ...
      || ! isequal (size (A), size (X)) || ! isequal (size (A), size (T)) ...
      || ! isequal (size (A), size (R)))
    error ("mplapack:neigt:VS1", "invalid similarity certificate inputs");
  endif
  n = rows (A);
  A_box = net_iv_cmatrix_point (A, q);
  X_box = net_iv_cmatrix_point (X, q);
  T_box = net_iv_cmatrix_point (T, q);
  R_box = net_iv_cmatrix_point (R, q);
  stage = tic ();
  E_box = net_iv_cmatrix_sub (net_iv_cmatrix_eye (n, q), ...
    net_iv_cmatrix_mul (R_box, X_box, q), q);
  fprintf (2, "NEIGT14: certificate RX %.3fs\n", toc (stage));
  stage = tic ();
  F_box = net_iv_cmatrix_sub (net_iv_cmatrix_mul (A_box, X_box, q), ...
                              net_iv_cmatrix_mul (X_box, T_box, q), q);
  fprintf (2, "NEIGT14: certificate residual %.3fs\n", toc (stage));
  stage = tic ();
  RF_box = net_iv_cmatrix_mul (R_box, F_box, q);
  fprintf (2, "NEIGT14: certificate RF %.3fs\n", toc (stage));
  stage = tic ();
  e = net_iv_cmatrix_inf_upper (E_box, q);
  c = net_iv_cmatrix_inf_upper (RF_box, q);
  fprintf (2, "NEIGT14: certificate norms %.3fs\n", toc (stage));
  denominator = net_iv_primitive ("sub", mp (1), e, q);
  if (denominator.lo <= mp (0))
    result = failed_result ("INCONCLUSIVE_INVERSE_RESIDUAL", n, e, c);
    return;
  endif
  eta = net_iv_primitive ("div", c, denominator.lo, q).hi;
  stage = tic ();
  centers = diag (T);
  radii = mp (zeros (n, 1));
  for i = 1:n
    radius = net_iv_real (eta, eta);
    for j = 1:n
      if (j != i)
        radius_term = net_iv_complex_abs ...
          (net_iv_complex_point (T(i,j), q), q);
        radius = net_iv_real_add (radius, ...
                                  net_iv_real (radius_term.hi, radius_term.hi), q);
      endif
    endfor
    radii(i) = radius.hi;
  endfor
  fprintf (2, "NEIGT14: certificate disks %.3fs\n", toc (stage));
  stage = tic ();
  parent = 1:n;
  for i = 1:n
    for j = i+1:n
      center_difference = net_iv_complex_sub ...
        (net_iv_complex_point (centers(i), q), ...
         net_iv_complex_point (centers(j), q), q);
      separation = net_iv_complex_abs (center_difference, q);
      radius_sum = net_iv_real_add (net_iv_real (radii(i), radii(i)), ...
                                    net_iv_real (radii(j), radii(j)), q);
      if (! (separation.lo > radius_sum.hi))
        parent = union_sets (parent, i, j);
      endif
    endfor
  endfor
  fprintf (2, "NEIGT14: certificate overlap %.3fs\n", toc (stage));
  stage = tic ();
  roots = cell (n, 1);
  for i = 1:n
    root = find_root (parent, i);
    roots{root}(end + 1) = i;
  endfor
  component_count = 0;
  singleton_count = 0;
  component_sizes = [];
  for i = 1:n
    if (! isempty (roots{i}))
      component_count += 1;
      component_sizes(end + 1) = numel (roots{i});
      singleton_count += (numel (roots{i}) == 1);
    endif
  endfor
  stage = tic ();
  norm_upper = net_iv_cmatrix_fro_upper (A_box, q);
  if (norm_upper < mp (1))
    norm_upper = mp (1);
  endif
  radius_upper = mp (0);
  for i = 1:n
    if (radii(i) > radius_upper)
      radius_upper = radii(i);
    endif
  endfor
  fprintf (2, "NEIGT14: certificate Frobenius %.3fs\n", toc (stage));
  usefulness_target = net_pow2 (usefulness_exponent, q);
  useful = radius_upper / norm_upper <= usefulness_target;
  coverage = (component_count > 0 && sum (component_sizes) == n);
  result = struct ("method", "neigt_similarity_gershgorin_v1", ...
    "paper_algorithm_reproduction", false, "status", "CERTIFIED_ALL", ...
    "all_roots", coverage, ...
    "counted_roots", sum (component_sizes), "n", n, ...
    "component_count", component_count, "component_sizes", component_sizes, ...
    "singleton_count", singleton_count, "require_singletons", true, ...
    "singleton_useful", singleton_count == n, "centers", centers, ...
    "radii", radii, "max_radius", radius_upper, ...
    "verified_frobenius_upper", norm_upper, "usefulness_target", usefulness_target, ...
    "useful", useful, "e", e, "c", c, "eta", eta, ...
    "inverse_residual_pass", e < mp (1), "coverage", coverage, "parent", parent);
  if (! result.coverage || ! result.inverse_residual_pass)
    result.status = "INCONCLUSIVE";
  elseif (! result.singleton_useful || ! result.useful)
    result.status = "CERTIFIED_ALL_NOT_USEFUL";
  endif
endfunction

function result = failed_result (status, n, e, c)
  result = struct ("method", "neigt_similarity_gershgorin_v1", ...
    "paper_algorithm_reproduction", false, "status", status, ...
    "all_roots", false, "counted_roots", 0, "n", n, ...
    "component_count", 0, "component_sizes", [], "singleton_count", 0, ...
    "require_singletons", true, "singleton_useful", false, "centers", [], ...
    "radii", [], "max_radius", mp ("NaN"), ...
    "verified_frobenius_upper", mp ("NaN"), "usefulness_target", mp ("NaN"), ...
    "useful", false, "e", e, "c", c, "eta", mp ("NaN"), ...
    "inverse_residual_pass", false, "coverage", false, "parent", []);
endfunction

function root = find_root (parent, index)
  root = index;
  while (parent(root) != root)
    root = parent(root);
  endwhile
endfunction

function parent = union_sets (parent, left, right)
  left_root = find_root (parent, left);
  right_root = find_root (parent, right);
  if (left_root != right_root)
    parent(right_root) = left_root;
  endif
endfunction
