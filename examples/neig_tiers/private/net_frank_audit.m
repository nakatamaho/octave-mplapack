% A2 spectrum, recurrence, and reflected-orientation audit.
function result = net_frank_audit (n, bits, reference_bits)
  f0 = net_frank_model (n, 0, bits);
  f1 = net_frank_model (n, 1, bits);
  reference = net_frank_reference (n, reference_bits);
  polynomial = net_frank_polynomial (n, bits);
  saved_bits = mpbits ();
  unwind_protect
    mpbits (max (saved_bits, bits));
    [unused0, diagonal0] = eig (f0.A, "nobalance");
    [unused1, diagonal1] = eig (f1.A, "nobalance");
    values0 = diag (diagonal0);
    values1 = diag (diagonal1);
    match0 = net_match (values0, reference.eigenvalues, "relative");
    match1 = net_match (values1, reference.eigenvalues, "relative");
    reflected_exact = (f1.A == f1.reversal * ctranspose (f0.A) * f1.reversal);
    reflected_transpose_spectrum = net_match (values0, values1, "relative");
    characteristic_checks = false (numel (polynomial.points), 1);
    for j = 1:numel (polynomial.points)
      point = mp (polynomial.points(j));
      [matrix_value, unused_metadata] = ...
        net_exact_det_permutation (point * mp (eye (n)) - f0.A, bits);
      characteristic_checks(j) = (matrix_value == polynomial.values(j));
    endfor
    positive = all (reference.eigenvalues > mp (0));
    reciprocal_error = max (abs (reference.reciprocal_products - mp (1)));
    result = struct ("status", "MEASURED", "F0", f0, "F1", f1, ...
      "reference", reference, "polynomial", polynomial, ...
      "match_F0", match0, "match_F1", match1, ...
      "reflected_exact", reflected_exact, ...
      "reflected_transpose_match", reflected_transpose_spectrum, ...
      "characteristic_checks", characteristic_checks, ...
      "positive_reference", positive, "reciprocal_error", reciprocal_error);
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
