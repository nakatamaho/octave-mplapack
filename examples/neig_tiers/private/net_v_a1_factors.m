% Compatible simultaneous eigenfactor boxes from k=1 graph certificates.
% This proves one E/Lambda factorization; it does not normalize columns
% independently and it does not claim a Schur factor (NEIGT19).
function result = net_v_a1_factors (A, V, D, q, useful_exponent)
  if (nargin != 5 || ! isa (A, "mp") || ! isa (V, "mp") || ! isa (D, "mp") ...
      || rows (A) != columns (A) || ! isequal (size (A), size (V)) ...
      || ! isequal (size (D), size (A)) || q != fix (q) || q < 64 ...
      || useful_exponent != fix (useful_exponent))
    error ("mplapack:neigt:VA1", "invalid eigenfactor arguments");
  endif
  n = rows (A);
  result = failure_template (n, useful_exponent);
  graphs = cell (n, 1);
  E_box = zero_matrix (n, n, q);
  lambda_boxes = cell (n, 1);
  lambda_values = diag (D);
  for index = 1:n
    order = [index, 1:(index - 1), (index + 1):n];
    X = V(:, order);
    graph = net_v_s2_graph (A, X, 1, q);
    graphs{index} = graph;
    if (! graph.pass || ! graph.nontrivial)
      result.status = "INCONCLUSIVE_GRAPH";
      result.claim_status = "INCONCLUSIVE";
      result.graphs = graphs;
      return;
    endif
    root = entry_box (graph.M_box, 1, 1);
    lambda_boxes{index} = root;
    E_box = put_column (E_box, graph.Y1_box, index);
  endfor

  roots_disjoint = true;
  for i = 1:n
    for j = (i + 1):n
      difference = net_iv_complex_sub (lambda_boxes{i}, lambda_boxes{j}, q);
      if (net_iv_complex_abs (difference, q).lo <= mp (0))
        roots_disjoint = false;
      endif
    endfor
  endfor

  E_mid = midpoint_matrix (E_box, q);
  if (! all (isfinite (real (E_mid))) || ! all (isfinite (imag (E_mid))))
    result.status = "INCONCLUSIVE_FACTOR_MIDPOINT";
    result.claim_status = "INCONCLUSIVE";
    result.graphs = graphs;
    result.E_box = E_box;
    result.lambda_boxes = lambda_boxes;
    return;
  endif
  R0 = E_mid \ mp (eye (n));
  inverse_witness = interval_inverse_residual (E_box, R0, q);
  if (! inverse_witness.nonsingular)
    result.status = "INCONCLUSIVE_FACTOR_INVERSE";
    result.claim_status = "INCONCLUSIVE";
    result.graphs = graphs;
    result.E_box = E_box;
    result.lambda_boxes = lambda_boxes;
    result.inverse_witness = inverse_witness;
    return;
  endif
  R_box = inverse_box_from_residual (R0, inverse_witness, q);
  W_box = net_iv_cmatrix_conjtrans (R_box);
  Lambda_box = diagonal_from_boxes (lambda_boxes, n, q);
  compatibility = net_v_a1_validate_assembly (A, E_box, Lambda_box, q);
  if (! compatibility.encloses_zero)
    result.status = "INCONCLUSIVE_COMPATIBILITY";
    result.claim_status = "INCONCLUSIVE";
    result.graphs = graphs;
    result.E_box = E_box;
    result.Lambda_box = Lambda_box;
    result.W_box = W_box;
    result.inverse_witness = inverse_witness;
    result.compatibility = compatibility;
    return;
  endif

  component_radius = maximum_component_radius (E_box, E_mid, q);
  scale = max (mp (1), max_entry_modulus (E_mid, q));
  width_ratio = component_radius / scale;
  useful_target = net_pow2 (useful_exponent, q);
  result.status = "CERTIFIED_EIGENFACTORS";
  result.claim_status = "CERTIFIED_EIGENFACTORS";
  result.claim_quality = "simultaneous_existence";
  result.pass = roots_disjoint && inverse_witness.nonsingular ...
                && compatibility.encloses_zero && width_ratio <= useful_target;
  if (! roots_disjoint)
    result.status = "INCONCLUSIVE_NONISOLATED_ROOTS";
    result.claim_status = "INCONCLUSIVE";
    result.pass = false;
  elseif (! result.pass)
    result.status = "INCONCLUSIVE_USEFUL_WIDTH";
    result.claim_status = "INCONCLUSIVE";
  endif
  result.milestone_pass = result.pass;
  result.graphs = graphs;
  result.E_box = E_box;
  result.E_mid = E_mid;
  result.Lambda_box = Lambda_box;
  result.W_box = W_box;
  result.R0 = R0;
  result.inverse_witness = inverse_witness;
  result.compatibility = compatibility;
  result.roots_disjoint = roots_disjoint;
  result.component_radius = component_radius;
  result.scale = scale;
  result.width_ratio = width_ratio;
  result.useful_target = useful_target;
  result.raw_V_hash = net_raw_hash (V, "VA1_raw_V");
  result.raw_D_hash = net_raw_hash (D, "VA1_raw_D");
  result.raw_lambda_hash = net_raw_hash (lambda_values, "VA1_raw_lambda");
endfunction

function result = net_v_a1_validate_assembly (A, E_box, Lambda_box, q)
  A_box = net_iv_cmatrix_point (A, q);
  residual = net_iv_cmatrix_sub ...
    (net_iv_cmatrix_mul (A_box, E_box, q), ...
     net_iv_cmatrix_mul (E_box, Lambda_box, q), q);
  result = struct ("residual", residual, "encloses_zero", contains_zero (residual));
endfunction

function result = inverse_box_from_residual (R0, witness, q)
  % If G=R0*E-I and ||G||inf<=e<1, then
  % E^-1=(I+G)^-1 R0 and ||E^-1-R0||inf <= e/(1-e)||R0||inf.
  e = witness.e;
  denominator = net_iv_primitive ("sub", mp (1), e, q).lo;
  ratio = net_iv_primitive ("div", e, denominator, q).hi;
  rnorm = net_iv_cmatrix_inf_upper (net_iv_cmatrix_point (R0, q), q);
  radius = net_iv_primitive ("mul", ratio, rnorm, q).hi;
  result = net_iv_cmatrix_point (R0, q);
  for index = 1:numel (R0)
    result.rl(index) = net_iv_primitive ("sub", real (R0(index)), radius, q).lo;
    result.rh(index) = net_iv_primitive ("add", real (R0(index)), radius, q).hi;
    result.il(index) = net_iv_primitive ("sub", imag (R0(index)), radius, q).lo;
    result.ih(index) = net_iv_primitive ("add", imag (R0(index)), radius, q).hi;
  endfor
  result.radius = radius;
endfunction

function result = interval_inverse_residual (E_box, R0, q)
  residual = net_iv_cmatrix_sub (net_iv_cmatrix_eye (rows (E_box.rl), q), ...
    net_iv_cmatrix_mul (net_iv_cmatrix_point (R0, q), E_box, q), q);
  e = net_iv_cmatrix_inf_upper (residual, q);
  result = struct ("residual", residual, "e", e, "nonsingular", e < mp (1), ...
                   "method", "neigt_interval_neumann_inverse_v1");
endfunction

function result = diagonal_from_boxes (boxes, n, q)
  result = zero_matrix (n, n, q);
  for index = 1:n
    box = boxes{index};
    result.rl(index,index) = box.rl;
    result.rh(index,index) = box.rh;
    result.il(index,index) = box.il;
    result.ih(index,index) = box.ih;
  endfor
endfunction

function result = zero_matrix (m, n, q)
  result = net_iv_cmatrix_point (mp (zeros (m, n)), q);
endfunction

function matrix = put_column (matrix, column, index)
  matrix.rl(:,index) = column.rl;
  matrix.rh(:,index) = column.rh;
  matrix.il(:,index) = column.il;
  matrix.ih(:,index) = column.ih;
endfunction

function result = midpoint_matrix (matrix, q)
  result = mp (zeros (size (matrix.rl)));
  for index = 1:numel (result)
    re = (matrix.rl(index) + matrix.rh(index)) * mp ("0.5");
    im = (matrix.il(index) + matrix.ih(index)) * mp ("0.5");
    result(index) = net_mp_complex (re, im);
  endfor
endfunction

function result = maximum_component_radius (box, center, q)
  result = mp (0);
  for index = 1:numel (box.rl)
    real_radius = max (abs (box.rl(index) - real (center(index))), ...
                       abs (box.rh(index) - real (center(index))));
    imag_radius = max (abs (box.il(index) - imag (center(index))), ...
                       abs (box.ih(index) - imag (center(index))));
    value = max (real_radius, imag_radius);
    if (value > result)
      result = value;
    endif
  endfor
endfunction

function result = max_entry_modulus (matrix, q)
  result = mp (0);
  for index = 1:numel (matrix)
    value = abs (matrix(index));
    if (value > result)
      result = value;
    endif
  endfor
endfunction

function result = entry_box (matrix, i, j)
  if (isscalar (matrix.rl))
    result = net_iv_complex (matrix.rl, matrix.rh, matrix.il, matrix.ih);
  else
    result = net_iv_complex (matrix.rl(i,j), matrix.rh(i,j), ...
                             matrix.il(i,j), matrix.ih(i,j));
  endif
endfunction

function result = contains_zero (matrix)
  result = all (matrix.rl(:) <= mp (0) & matrix.rh(:) >= mp (0) ...
                & matrix.il(:) <= mp (0) & matrix.ih(:) >= mp (0));
endfunction

function result = failure_template (n, useful_exponent)
  result = struct ("method", "neigt_eigenfactor_boxes_v1", ...
    "paper_algorithm_reproduction", false, "status", "INCONCLUSIVE", ...
    "claim_status", "INCONCLUSIVE", "claim_quality", "not_identified", ...
    "pass", false, "milestone_pass", false, "n", n, ...
    "useful_exponent", useful_exponent, "graphs", {{}}, ...
    "E_box", [], "Lambda_box", [], "W_box", [], "compatibility", [], ...
    "inverse_witness", [], "roots_disjoint", false, ...
    "raw_V_hash", "", "raw_D_hash", "", "raw_lambda_hash", "");
endfunction
