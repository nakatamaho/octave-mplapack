% MKS exact characteristic, zero multiplicity, and reduced-root audit.
function result = net_mks_audit (n, m, delta, bits, reference_bits)
  model = net_mks_model (n, m, delta, bits);
  reference = net_mks_reference (model, reference_bits, reference_bits + 64);
  points = [0, 1, 2, 3];
  determinant_checks = false (numel (points), 1);
  polynomial_values = mp (zeros (numel (points), 1));
  saved_bits = mpbits ();
  unwind_protect
    mpbits (reference_bits + 64);
    for index = 1:numel (points)
      x = mp (points(index));
      accumulator = mp (0);
      for j = 1:numel (model.q_coefficients)
        accumulator = accumulator * x + model.q_coefficients(j);
      endfor
      polynomial_values(index) = accumulator;
      if (n <= 8)
        [determinant, unused] = net_exact_det_permutation ...
          (x * mp (eye (n)) - model.A_model, reference_bits);
        determinant_checks(index) = (determinant == ...
          x ^ (n - model.ell) * accumulator);
      endif
    endfor
    [V, D, W] = eig (model.A_frozen, "nobalance");
    simple_mask = false (model.n, 1);
    simple_mask((model.n - model.ell + 1):model.n) = true;
    metrics = net_metrics (model.A_frozen, V, D, W, reference.values2, ...
      struct ("simple_mask", simple_mask));
    result = struct ("status", "MEASURED", "model", model, ...
      "reference", reference, "determinant_points", points, ...
      "q_values", polynomial_values, "determinant_checks", determinant_checks, ...
      "zero_multiplicity", model.zero_algebraic_multiplicity, ...
      "nonzero_simple_guard", reference.gcd.square_free, "metrics", metrics, ...
      "source", "A5_MKS_AUDIT");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
