% MKS reference: solve only the reduced companion and append exact zeros.
function result = net_mks_reference (model, bits1, bits2)
  if (nargin != 3 || ! isstruct (model) || ! isfield (model, "q_companion") ...
      || bits1 != fix (bits1) || bits2 != fix (bits2) || bits1 < 64 || bits2 < bits1)
    error ("mplapack:neigt:MKS", "invalid MKS reference arguments");
  endif
  ell = model.ell;
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits1);
    C1 = mp (zeros (size (model.q_companion))) + model.q_companion;
    [unused1, D1] = eig (C1, "nobalance");
    nonzero1 = diag (D1);
    mpbits (bits2);
    C2 = mp (zeros (size (model.q_companion))) + model.q_companion;
    [unused2, D2] = eig (C2, "nobalance");
    nonzero2 = diag (D2);
    values1 = mp (zeros (model.n, 1));
    values2 = mp (zeros (model.n, 1));
    values1(1:ell) = nonzero1;
    values2(1:ell) = nonzero2;
    comparison = net_match (nonzero2, nonzero1, "absolute");
    derivative = mp (zeros (1, numel (model.q_coefficients) - 1));
    for j = 1:numel (derivative)
      derivative(j) = mp (numel (model.q_coefficients) - j) ...
                      * model.q_coefficients(j);
    endfor
    gcd_result = net_polynomial_gcd (model.q_coefficients, derivative, bits2);
    result = struct ("reference_status", "reduced_companion_plus_exact_zeros", ...
      "bits1", bits1, "bits2", bits2, "nonzero1", nonzero1, ...
      "nonzero2", nonzero2, "values1", values1, "values2", values2, ...
      "nonzero_agreement", comparison, "derivative", derivative, ...
      "gcd", gcd_result, "source", "A5_MKS_REDUCED_COMPANION_REFERENCE");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
