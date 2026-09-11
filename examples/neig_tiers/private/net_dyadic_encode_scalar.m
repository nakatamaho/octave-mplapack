% Encode one represented MP real or complex scalar without decimal conversion.
function result = net_dyadic_encode_scalar (value, stored_bits)
  if (nargin != 2 || ! isa (value, "mp") || ! isscalar (value) ...
      || ! isnumeric (stored_bits) || ! isscalar (stored_bits) ...
      || stored_bits != fix (stored_bits) || stored_bits < 1 ...
      || ! isfinite (real (value)) || ! isfinite (imag (value)))
    error ("mplapack:neigt:Serialize", "invalid scalar serialization input");
  endif
  if (isreal (value))
    result = encode_real (value, stored_bits);
    result.kind = "real";
  else
    result = struct ("kind", "complex", "real", ...
      encode_real (real (value), stored_bits), "imag", ...
      encode_real (imag (value), stored_bits));
  endif
endfunction

function result = encode_real (value, stored_bits)
  if (value == mp (0))
    result = struct ("sign", 0, "mantissa_hex", "0", "exponent2", 0);
    return;
  endif
  decomposition = net_dyadic_decompose (value, stored_bits);
  coefficient = abs (decomposition.coefficient);
  hexadecimal = net_mp_integer_hex (coefficient);
  if (hexadecimal(end) == "0" || hexadecimal(1) == "0")
    error ("mplapack:neigt:Serialize", "mantissa was not normalized");
  endif
  result = struct ("sign", ternary_sign (value), ...
                   "mantissa_hex", hexadecimal, ...
                   "exponent2", decomposition.exponent);
endfunction

function value = ternary_sign (x)
  if (x < mp (0))
    value = -1;
  else
    value = 1;
  endif
endfunction
