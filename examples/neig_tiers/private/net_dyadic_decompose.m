% Exact dyadic decomposition: value = coefficient * 2^exponent.
% coefficient is an odd integer for a nonzero value.
function result = net_dyadic_decompose (value, bits)
  if (nargin != 2 || ! isa (value, "mp") || ! isscalar (value) ...
      || ! isfinite (value) || ! isnumeric (bits) || ! isscalar (bits) ...
      || bits != fix (bits) || bits < 1)
    error ("mplapack:neigt:Dyadic", "invalid dyadic decomposition arguments");
  endif
  if (value == mp (0))
    result = struct ("coefficient", mp (0), "exponent", 0, ...
                     "zero", true, "exact", true);
    return;
  endif
  magnitude = abs (value);
  leading = net_ufp (magnitude);
  scale = net_pow2 (leading, bits);
  quotient = magnitude / scale;
  found = false;
  % A bits-bit MP dyadic has its odd coefficient within this range.
  for exponent = leading:-1:(leading - bits - 2)
    if (floor (quotient) == quotient)
      coefficient = quotient;
      if (floor (coefficient / mp (2)) * mp (2) != coefficient)
        if (value < mp (0))
          coefficient = -coefficient;
        endif
        result = struct ("coefficient", coefficient, ...
                         "exponent", exponent, "zero", false, "exact", true);
        found = true;
        break;
      endif
    endif
    quotient = quotient * mp (2);
  endfor
  if (! found)
    error ("mplapack:neigt:Dyadic", ...
           "value is not an exact dyadic at the supplied precision");
  endif
endfunction
