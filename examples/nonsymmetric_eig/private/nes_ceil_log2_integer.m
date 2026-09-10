% Exact integer ceil(log2(n)) for positive native dimensions.
function exponent = nes_ceil_log2_integer (n)
  if (! (isnumeric (n) && isscalar (n) && isreal (n) && isfinite (n)
         && n == fix (n) && n >= 1))
    error ("NEIG:IntegerLog", "argument must be a positive integer");
  endif
  power = 1;
  exponent = 0;
  while power < n
    power = power * 2;
    exponent += 1;
  endwhile
endfunction
