% Independent references for the nonsymmetric eigensystem suite.
function result = nes_reference (family, parameters, reference_bits)
  if (nargin != 3 || ! ischar (family) || ! isstruct (parameters))
    error ("NEIG:ReferenceArguments", ...
           "nes_reference expects a family, parameter struct, and precision");
  endif
  if (! strcmp (family, "hadamard"))
    error ("NEIG:ReferenceFamily", "only the Hadamard reference is implemented in NEIG01");
  endif
  n = parameters.n;
  if (! (isnumeric (reference_bits) && isscalar (reference_bits)
         && isreal (reference_bits) && isfinite (reference_bits)
         && reference_bits == fix (reference_bits) && reference_bits >= 1))
    error ("NEIG:ReferencePrecision", "reference precision must be a positive integer");
  endif

  saved_bits = mpbits ();
  unwind_protect
    mpbits (reference_bits);
    values = mp (transpose (1:n));
    condition_numbers = mp (zeros (n, 1));
    for root = 1:n
      left_sum = mp ("1");
      term = mp ("1");
      for j = 1:(root - 1)
        term = term * mp (parameters.s) / mp (j);
        left_sum = left_sum + term * term;
      endfor
      right_sum = mp ("1");
      term = mp ("1");
      for j = 1:(n - root)
        term = term * mp (parameters.s) / mp (j);
        right_sum = right_sum + term * term;
      endfor
      condition_numbers(root) = sqrt (left_sum) * sqrt (right_sum);
    endfor
    result = struct ("family", family, "reference_status", "analytic_exact", ...
                     "reference_bits", reference_bits, "eigenvalues", values, ...
                     "condition_numbers", condition_numbers);
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
