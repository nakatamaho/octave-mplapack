% A1 closed-form eigenvalue conditions for the bidiagonal model.
function result = net_hadamard_reference (n, s, bits)
  if (nargin != 3 || n != fix (n) || n < 2 || s != fix (s) || s < 1)
    error ("mplapack:neigt:Hadamard", "invalid Hadamard reference arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    eigenvalues = mp (transpose (1:n));
    condition_numbers = mp (zeros (n, 1));
    for k = 1:n
      left_sum = mp (1);
      term = mp (1);
      for j = 1:(k - 1)
        term = term * mp (s) / mp (j);
        left_sum = left_sum + term * term;
      endfor
      right_sum = mp (1);
      term = mp (1);
      for j = 1:(n - k)
        term = term * mp (s) / mp (j);
        right_sum = right_sum + term * term;
      endfor
      condition_numbers(k) = sqrt (left_sum) * sqrt (right_sum);
    endfor
    result = struct ("reference_status", "analytic_exact", ...
      "reference_bits", bits, "eigenvalues", eigenvalues, ...
      "condition_numbers", condition_numbers, "source", "A1_CLOSED_FORM");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
