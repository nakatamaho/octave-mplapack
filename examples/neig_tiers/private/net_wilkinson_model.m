% Exact Wilkinson Frobenius companion and its once-rounded work input.
function result = net_wilkinson_model (n, bits)
  if (nargin != 2 || n != fix (n) || n < 1 || bits != fix (bits) || bits < 64)
    error ("mplapack:neigt:Wilkinson", "invalid Wilkinson arguments");
  endif
  guard = n * net_ceil_log2_integer (n + 1) + 2;
  generation_bits = max (bits, guard);
  saved_bits = mpbits ();
  unwind_protect
    mpbits (generation_bits);
    coefficients = mp (1);
    for root = 1:n
      old = coefficients;
      coefficients = mp (zeros (1, numel (old) + 1));
      if (numel (old) == 1)
        coefficients(1) = old;
      else
        coefficients(1) = old(1);
      endif
      for index = 2:numel (old)
        coefficients(index) = old(index) - mp (root) * old(index - 1);
      endfor
      if (numel (old) == 1)
        coefficients(end) = -mp (root) * old;
      else
        coefficients(end) = -mp (root) * old(end);
      endif
    endfor
    A_model = mp (zeros (n, n));
    A_model(1, :) = -coefficients(2:end);
    for index = 2:n
      A_model(index, index - 1) = mp (1);
    endfor
    if (bits < generation_bits)
      mpbits (bits);
      A_frozen = mp (zeros (n, n)) + A_model;
    else
      A_frozen = A_model;
    endif
    native_A = double (A_model);
    result = struct ("family", "wilkinson", "n", n, "bits", bits, ...
      "generation_bits", generation_bits, "guard_bits", guard, ...
      "coefficients", coefficients, "A_model", A_model, ...
      "A_frozen", A_frozen, "native_A", native_A, ...
      "input_status", ternary_local (bits >= guard, "exact_model", ...
                                      "rounded_model"), ...
      "source", "A3_WILKINSON_EXACT_COEFFICIENT_RECURRENCE");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function value = ternary_local (condition, true_value, false_value)
  if (condition)
    value = true_value;
  else
    value = false_value;
  endif
endfunction
