% Convert a bounded nonnegative MP integer to lowercase hexadecimal.
function result = net_mp_integer_hex (value)
  if (nargin != 1 || ! isa (value, "mp") || ! isscalar (value) ...
      || ! isfinite (value) || value < mp (0) || floor (value) != value)
    error ("mplapack:neigt:DyadicHex", "expected a finite nonnegative MP integer");
  endif
  if (value == mp (0))
    result = "0";
    return;
  endif
  digits = "";
  sixteen = mp (16);
  while (value > mp (0))
    quotient = floor (value / sixteen);
    remainder = value - sixteen * quotient;
    digit = double (remainder);
    hex = "0123456789abcdef";
    digits = [hex(digit + 1), digits];
    value = quotient;
  endwhile
  result = digits;
endfunction
