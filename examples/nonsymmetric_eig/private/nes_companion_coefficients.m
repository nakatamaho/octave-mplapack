% Construct prod(x-k) coefficients with MP arithmetic at the requested bits.
function coefficients = nes_companion_coefficients (n, bits)
  if (nargin != 2 || ! (isnumeric (n) && isscalar (n) && isreal (n)
                         && isfinite (n) && n == fix (n) && n >= 1))
    error ("NEIG:CompanionArguments", "companion degree must be a positive integer");
  endif
  if (bits < nes_companion_min_bits (n))
    error ("NEIG:CompanionPrecision", ...
           "precision is below the exact-coefficient guard");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    coefficients = mp (1);
    for k = 1:n
      zero = mp ("0");
      coefficients = [coefficients, zero] ...
                     - mp (k) * [zero, coefficients];
    endfor
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
