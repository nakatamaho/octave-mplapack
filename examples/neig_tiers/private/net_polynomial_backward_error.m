% Complex coefficientwise polynomial backward-error indicator.
function result = net_polynomial_backward_error (z, coefficients, bits)
  if (nargin != 3 || ! isa (z, "mp") || ! isa (coefficients, "mp") ...
      || ! isscalar (z) || rows (coefficients) != 1 || bits != fix (bits) ...
      || bits < 64)
    error ("mplapack:neigt:Polynomial", "invalid polynomial error arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    value = mp (0);
    denominator = mp (0);
    modulus = abs (z);
    for index = 1:numel (coefficients)
      value = value * z + coefficients(index);
      denominator = denominator * modulus + abs (coefficients(index));
    endfor
    if (denominator == mp (0))
      eta = mp (0);
      status = "denominator_zero_exact_zero";
    else
      eta = abs (value) / denominator;
      status = "finite";
    endif
    result = struct ("z", z, "value", value, ...
      "denominator", denominator, "eta", eta, "status", status, ...
      "convention", "nonmonic_complex_coefficientwise_v1");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
