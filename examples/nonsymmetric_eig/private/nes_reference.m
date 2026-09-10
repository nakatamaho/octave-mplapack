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
    result = struct ("family", family, "reference_status", "analytic_exact", ...
                     "reference_bits", reference_bits, "eigenvalues", values);
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
