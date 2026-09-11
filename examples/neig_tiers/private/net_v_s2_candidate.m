% Candidate-only preparation for the V-S2 graph checker.
% The contour projector and QR are numerical suggestions only.  No candidate
% status is used as proof; net_v_s2_graph rechecks the supplied basis.
function result = net_v_s2_candidate (A, center, radius, k, bits)
  if (nargin != 5 || ! isa (A, "mp") || rows (A) != columns (A) ...
      || ! isa (center, "mp") || ! isscalar (center) || ! isa (radius, "mp") ...
      || ! isscalar (radius) || radius <= mp (0) || k != fix (k) ...
      || k < 1 || k >= rows (A) || bits != fix (bits) || bits < 64)
    error ("mplapack:neigt:VS2", "invalid candidate preparation arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    n = rows (A);
    I = mp (eye (n));
    node_counts = [16, 32, 64];
    projectors = cell (numel (node_counts), 1);
    q_bases = cell (numel (node_counts), 1);
    selected_bases = cell (numel (node_counts), 1);
    records = struct ([]);
    for count_index = 1:numel (node_counts)
      node_count = node_counts(count_index);
      P_hat = mp (zeros (n, n));
      solve_count = 0;
      failed_nodes = 0;
      for node = 0:(node_count - 1)
        theta = (mp (2) * pi ()) * (mp (node) + mp ("0.5")) / mp (node_count);
        unit = net_mp_complex (cos (theta), sin (theta));
        z = center + radius * unit;
        zI = mp (zeros (n, n));
        for diagonal = 1:n
          zI(diagonal, diagonal) = z;
        endfor
        shifted = zI - A;
        try
          resolvent = shifted \ I;
          solve_count += 1;
          P_hat += ((z - center) / mp (node_count)) * resolvent;
        catch
          failed_nodes += 1;
        end_try_catch
      endfor
      projectors{count_index} = P_hat;
      if (failed_nodes == 0)
        [Q, R] = qr (P_hat);
        q_bases{count_index} = Q;
        rank_indicator = abs (R(k,k));
      else
        q_bases{count_index} = [];
        rank_indicator = mp (0);
      endif
      if (failed_nodes == 0)
        [selected, selected_indices] = select_columns (P_hat, k, bits);
        selected_bases{count_index} = selected;
      else
        selected_indices = [];
      endif
      record = struct ("node_count", node_count, "solve_count", solve_count, ...
                       "failed_nodes", failed_nodes, "rank_indicator", rank_indicator, ...
                       "selected_indices", selected_indices, ...
                       "candidate_source", "contour_projector_then_public_qr", ...
                       "candidate_bits", bits);
      if (isempty (records))
        records = record;
      else
        records(end + 1) = record;
      endif
    endfor
    final_Q = q_bases{end};
    if (isempty (final_Q) || ! isequal (size (final_Q), [n, n]))
      error ("mplapack:neigt:VS2", "contour candidate did not produce a square QR basis");
    endif
    final_Q1 = selected_bases{end};
    if (isempty (final_Q1) || ! isequal (size (final_Q1), [n, k]))
      error ("mplapack:neigt:VS2", "contour candidate did not produce selected columns");
    endif
    % The first candidate is the full computed QR basis, retained for the
    % simple/repeated fixtures where its leading columns are already suitable.
    % The second replaces its selected block by deterministic norm-pivoted
    % projector columns while retaining the computed QR complement.  Both are
    % bounded computed alternatives and neither uses generator columns.
    X_normalized_qr = [final_Q1, final_Q(:, (k + 1):n)];
    result = struct ("method", "neigt_candidate_contour_qr_v1", ...
      "paper_algorithm_reproduction", false, "candidate_source", ...
      "computed_subspace_bounded_schedule", "node_counts", node_counts, ...
      "records", records, "projectors", {projectors}, "q_bases", {q_bases}, ...
      "selected_bases", {selected_bases}, "candidates", {{final_Q, X_normalized_qr}}, ...
      "completion_strategies", 2, ...
      "selected_node_count", node_counts(end), "candidate_bits", bits, ...
      "cluster_dimension", k);
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function [result, selected_indices] = select_columns (P_hat, k, bits)
  n = rows (P_hat);
  result = mp (zeros (n, k));
  selected_indices = zeros (1, k);
  residuals = P_hat;
  selected = false (1, n);
  threshold = net_pow2 (-floor (bits / 4), bits);
  for target = 1:k
    best = 0;
    best_norm = mp (0);
    for column = 1:n
      if (! selected(column))
        candidate_norm = norm (residuals(:, column));
        if (candidate_norm > best_norm)
          best = column;
          best_norm = candidate_norm;
        endif
      endif
    endfor
    if (best == 0 || best_norm <= threshold)
      error ("mplapack:neigt:VS2", "contour projector candidate is rank deficient");
    endif
    selected(best) = true;
    selected_indices(target) = best;
    vector = residuals(:, best) / best_norm;
    result(:, target) = vector;
    for column = 1:n
      if (! selected(column))
        coefficient = ctranspose (vector) * residuals(:, column);
        residuals(:, column) = residuals(:, column) - vector * coefficient;
      endif
    endfor
  endfor
endfunction

function result = coordinate_completion (Q1, Q, k, bits)
  n = rows (Q1);
  result = mp (zeros (n, n));
  result(:, 1:k) = Q1;
  used = k;
  threshold = net_pow2 (-floor (bits / 4), bits);
  for coordinate = 1:n
    if (used == n)
      break;
    endif
    e = mp (zeros (n, 1));
    e(coordinate) = mp (1);
    coefficient = ctranspose (result(:,1:used)) * e;
    residual = e - result(:,1:used) * coefficient;
    if (norm (residual) > threshold)
      used += 1;
      result(:, used) = e;
    endif
  endfor
  if (used < n)
    for column = (k + 1):columns (Q)
      if (used == n)
        break;
      endif
      used += 1;
      result(:, used) = Q(:, column);
    endfor
  endif
  if (used != n)
    error ("mplapack:neigt:VS2", "coordinate completion did not reach full dimension");
  endif
endfunction
