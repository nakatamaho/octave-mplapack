% Forward circle and zero-limit audit for S4.
function result = net_forsythe_audit (fixture, reference_bits)
  if (nargin != 2 || ! isstruct (fixture) || ! isfield (fixture, "A"))
    error ("mplapack:neigt:Forsythe", "invalid Forsythe audit fixture");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (max (saved_bits, fixture.bits));
    if (strcmp (fixture.representation, "zero_limit"))
      nilpotent = fixture.A - mp (eye (fixture.n));
      powers = cell (fixture.n, 1);
      current = mp (eye (fixture.n));
      for order = 1:fixture.n
        [current, metadata] = net_exact_product_dyadic (current, nilpotent, fixture.bits);
        powers{order} = struct ("value", current, "metadata", metadata);
      endfor
      result = struct (...
        "status", "MEASURED", "zero_limit", true, ...
        "first_n_minus_one_nonzero", norm (powers{fixture.n - 1}.value, "fro") ...
                                      != mp (0), ...
        "nth_power_zero", all (all (powers{fixture.n}.value ...
                                     == mp (zeros (fixture.n)))), ...
        "powers", {powers}, "unique_eigenvector_target", "NOT_APPLICABLE", ...
        "nontrivial_cluster_target", "DEFERRED_TO_SIM_JORDAN");
    else
      reference = net_forsythe_reference (fixture.n, fixture.a, reference_bits);
      [V, D, W] = eig (fixture.A, "nobalance");
      values = diag (D);
      [Vb, Db, Wb] = eig (fixture.A, "balance");
      circle = net_match (values, reference.unit_roots, "circle", ...
                          mp (1), fixture.radius);
      metrics = net_metrics (fixture.A, V, D, W, reference.eigenvalues);
      balance_metrics = net_metrics (fixture.A, Vb, Db, Wb, ...
                                     reference.eigenvalues);
      result = struct (...
        "status", "MEASURED", "zero_limit", false, "reference", reference, ...
        "circle_match", circle, "metrics", metrics, ...
        "balance_metrics", balance_metrics, "original_coordinate_label", ...
        fixture.representation);
    endif
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
