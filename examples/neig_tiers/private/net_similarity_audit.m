% Exact-structure and ordinary subspace audit for one S2 similarity model.
function result = net_similarity_audit (fixture, characteristic_points)
  if (nargin < 1 || nargin > 2 || ! isstruct (fixture) ...
      || ! isfield (fixture, "A_frozen") || ! isfield (fixture, "J") ...
      || ! isfield (fixture, "similarity"))
    error ("mplapack:neigt:Similarity", "invalid similarity audit fixture");
  endif
  n = rows (fixture.J);
  if (nargin == 1)
    characteristic_points = [0, 1, 2, 3, 4, n + 1];
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (max (saved_bits, fixture.generation_bits));
    X = fixture.similarity.X;
    Y = fixture.similarity.Y;
    A = fixture.A_frozen;
    J = fixture.J;
    [XA, xa_metadata] = net_exact_product_dyadic (X, A, fixture.generation_bits);
    [JX, jx_metadata] = net_exact_product_dyadic (J, X, fixture.generation_bits);
    [AY, ay_metadata] = net_exact_product_dyadic (A, Y, fixture.generation_bits);
    [YJ, yj_metadata] = net_exact_product_dyadic (Y, J, fixture.generation_bits);
    exact_intertwining = (XA == JX && AY == YJ);
    if (! exact_intertwining)
      error ("mplapack:neigt:Similarity", ...
             "exact X*A=J*X or A*Y=Y*J check failed");
    endif

    [groups, diagonalizable, full_basis] = similarity_groups (fixture.regime, J);
    characteristic_checks = false (numel (characteristic_points), 1);
    for point_index = 1:numel (characteristic_points)
      point = mp (characteristic_points(point_index));
      polynomial_matrix = point * mp (eye (n)) - J;
      actual = det (polynomial_matrix);
      expected = mp (1);
      for i = 1:n
        expected = expected * (point - J(i, i));
      endfor
      characteristic_checks(point_index) = (actual == expected);
    endfor
    if (! all (characteristic_checks))
      error ("mplapack:neigt:Similarity", ...
             "independent characteristic checks failed");
    endif

    nilpotent_checks = cell (numel (groups), 1);
    subspace_checks = cell (numel (groups), 1);
    for group_index = 1:numel (groups)
      indices = groups(group_index).indices;
      block = J(indices, indices);
      root = J(indices(1), indices(1));
      nilpotent = block - root * mp (eye (numel (indices)));
      first_power = (norm (nilpotent, "fro") != mp (0));
      second_power = all (all (nilpotent * nilpotent ...
                               == mp (zeros (numel (indices)))));
      if (groups(group_index).geometric_multiplicity == 2)
        nilpotent_ok = (! first_power && second_power);
      elseif (groups(group_index).algebraic_multiplicity == 2)
        nilpotent_ok = (first_power && second_power);
      else
        nilpotent_ok = true;
      endif
      nilpotent_checks{group_index} = struct (...
        "indices", indices, "first_power_nonzero", first_power, ...
        "second_power_zero", second_power, "status", nilpotent_ok);

      basis = similarity_basis (fixture, groups(group_index));
      [Q, unused] = qr (basis);
      Q = Q(:, 1:numel (indices));
      reduced = ctranspose (Q) * A * Q;
      invariant_residual = norm (A * Q - Q * reduced, "fro");
      projector = Q * ctranspose (Q);
      subspace_checks{group_index} = struct (...
        "indices", indices, "dimension", numel (indices), ...
        "orthogonal_projector", projector, ...
        "invariant_residual", invariant_residual, ...
        "status", isfinite (invariant_residual) ...
                  && invariant_residual < mp ("1e-100"));
    endfor

    oblique = Y(:, 1:min (2, n)) * X(1:min (2, n), :);
    oblique_idempotent = oblique * oblique == oblique;
    result = struct (...
      "status", "MEASURED", "regime", fixture.regime, ...
      "groups", groups, "exact_intertwining", exact_intertwining, ...
      "intertwining_metadata", {{xa_metadata, jx_metadata, ay_metadata, ...
                                  yj_metadata}}, ...
      "characteristic_points", characteristic_points, ...
      "characteristic_checks", characteristic_checks, ...
      "nilpotent_checks", {nilpotent_checks}, ...
      "subspace_checks", {subspace_checks}, ...
      "diagonalizable", diagonalizable, ...
      "full_eigenbasis_exists", full_basis, ...
      "coordinate_columns_diagonalize", ...
        strcmp (fixture.regime, "semisimple"), ...
      "multiplicity_source", "exact_J_structure_not_disk_count", ...
      "oblique_projector_kind", "union_of_full_J_blocks", ...
      "oblique_projector_idempotent", oblique_idempotent);
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function basis = similarity_basis (fixture, group)
  indices = group.indices;
  basis = fixture.similarity.Y(:, indices);
  % The second simple eigenvector of the non-diagonal leading block is not
  % Y(:,2).  Solve that 2-by-2 triangular block exactly in MP coordinates.
  if (strcmp (fixture.regime, "simple") && numel (indices) == 1 ...
      && indices == 2)
    gap = fixture.J(2, 2) - fixture.J(1, 1);
    coordinates = mp ([1; 0]);
    coordinates(2) = gap;
    basis = fixture.similarity.Y(:, 1:2) * coordinates;
  endif
endfunction

function [groups, diagonalizable, full_basis] = similarity_groups (regime, J)
  n = rows (J);
  groups = struct ("indices", {}, "algebraic_multiplicity", {}, ...
                   "geometric_multiplicity", {}, "root", {}, "kind", {});
  if (strcmp (regime, "simple"))
    groups = append_simple_groups (groups, 1:n, J);
    diagonalizable = true;
    full_basis = true;
  elseif (strcmp (regime, "semisimple"))
    groups(1) = struct ("indices", [1, 2], "algebraic_multiplicity", 2, ...
                        "geometric_multiplicity", 2, "root", J(1, 1), ...
                        "kind", "semisimple_repeated");
    groups = append_simple_groups (groups, 3:n, J);
    diagonalizable = true;
    full_basis = true;
  elseif (strcmp (regime, "jordan"))
    groups(1) = struct ("indices", [1, 2], "algebraic_multiplicity", 2, ...
                        "geometric_multiplicity", 1, "root", J(1, 1), ...
                        "kind", "defective_jordan");
    groups = append_simple_groups (groups, 3:n, J);
    diagonalizable = false;
    full_basis = false;
  else
    groups(1) = struct ("indices", [1, 2], "algebraic_multiplicity", 2, ...
                        "geometric_multiplicity", 1, "root", J(1, 1), ...
                        "kind", "defective_jordan");
    groups(2) = struct ("indices", [3, 4], "algebraic_multiplicity", 2, ...
                        "geometric_multiplicity", 1, "root", J(3, 3), ...
                        "kind", "defective_jordan");
    groups = append_simple_groups (groups, 5:n, J);
    diagonalizable = false;
    full_basis = false;
  endif
endfunction

function groups = append_simple_groups (groups, indices, J)
  for index = indices
    groups(end + 1) = struct ("indices", index, ...
                              "algebraic_multiplicity", 1, ...
                              "geometric_multiplicity", 1, ...
                              "root", J(index, index), "kind", "simple");
  endfor
endfunction
