% Conservative sufficient precision for exact companion coefficients.
function minimum = nes_companion_min_bits (n)
  if (! (isnumeric (n) && isscalar (n) && isreal (n) && isfinite (n)
         && n == fix (n) && n >= 1))
    error ("NEIG:CompanionArguments", "companion degree must be a positive integer");
  endif
  minimum = n * nes_ceil_log2_integer (n + 1) + 2;
endfunction
