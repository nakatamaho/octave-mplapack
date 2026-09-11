% Exact roots and guarded Horner checks for the Wilkinson polynomial.
function result = net_wilkinson_reference (n, bits)
  if (nargin != 2 || n != fix (n) || n < 1 || bits != fix (bits) || bits < 64)
    error ("mplapack:neigt:Wilkinson", "invalid Wilkinson reference arguments");
  endif
  model = net_wilkinson_model (n, bits);
  horner_bits = max (bits, 2 * n * net_ceil_log2_integer (n + 1) + 32);
  saved_bits = mpbits ();
  unwind_protect
    mpbits (horner_bits);
    coefficients = mp (zeros (1, numel (model.coefficients)));
    coefficients = coefficients + model.coefficients;
    roots = mp (transpose (1:n));
    values = mp (zeros (n, 1));
    checks = false (n, 1);
    for root_index = 1:n
      accumulator = mp (0);
      for coefficient_index = 1:numel (coefficients)
        accumulator = accumulator * roots(root_index) + coefficients(coefficient_index);
      endfor
      values(root_index) = accumulator;
      checks(root_index) = (accumulator == mp (0));
    endfor
    result = struct ("reference_status", "exact_integer_roots", ...
      "reference_bits", horner_bits, "roots", roots, ...
      "coefficients", coefficients, "horner_values", values, ...
      "horner_exact_zero", checks, ...
      "source", "A3_WILKINSON_ROOTS_AND_GUARDED_HORNER");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
