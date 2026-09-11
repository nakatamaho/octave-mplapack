% Decode one exact dyadic scalar at a destination precision.
function result = net_dyadic_decode_scalar (encoded, destination_bits)
  if (nargin != 2 || ! isstruct (encoded) || ! isfield (encoded, "kind") ...
      || ! isnumeric (destination_bits) || ! isscalar (destination_bits) ...
      || destination_bits != fix (destination_bits) || destination_bits < 1)
    error ("mplapack:neigt:Deserialize", "invalid scalar record");
  endif
  if (strcmp (encoded.kind, "real"))
    result = decode_real (encoded, destination_bits);
  elseif (strcmp (encoded.kind, "complex"))
    if (! isfield (encoded, "real") || ! isfield (encoded, "imag"))
      error ("mplapack:neigt:Deserialize", "complex record lacks components");
    endif
    result = net_mp_complex (decode_real (encoded.real, destination_bits), ...
                             decode_real (encoded.imag, destination_bits));
  else
    error ("mplapack:neigt:Deserialize", "unknown scalar kind");
  endif
endfunction

function result = decode_real (encoded, destination_bits)
  required = {"sign", "mantissa_hex", "exponent2"};
  for index = 1:numel (required)
    if (! isfield (encoded, required{index}))
      error ("mplapack:neigt:Deserialize", "incomplete real record");
    endif
  endfor
  sign = encoded.sign;
  hexadecimal = encoded.mantissa_hex;
  exponent = encoded.exponent2;
  if (sign == 0)
    if (! strcmp (hexadecimal, "0") || exponent != 0)
      error ("mplapack:neigt:Deserialize", "invalid zero encoding");
    endif
    result = mp (0);
    return;
  endif
  if (! any (sign == [-1, 1]) || ! ischar (hexadecimal) ...
      || isempty (hexadecimal) || hexadecimal(1) == "0" ...
      || hexadecimal(end) == "0" || isempty (regexp (hexadecimal, ...
      "^[0-9a-f]+$", "once")) || ! isnumeric (exponent) ...
      || ! isscalar (exponent) || exponent != fix (exponent))
    error ("mplapack:neigt:Deserialize", "invalid nonzero dyadic encoding");
  endif
  if (net_hex_bit_length (hexadecimal) > destination_bits)
    error ("mplapack:neigt:Deserialize", ...
           "destination precision cannot represent mantissa");
  endif
  coefficient = mp (0);
  for index = 1:numel (hexadecimal)
    digit = find ("0123456789abcdef" == hexadecimal(index)) - 1;
    coefficient = coefficient * mp (16) + mp (digit);
  endfor
  result = coefficient * net_pow2 (exponent, destination_bits);
  if (sign < 0)
    result = -result;
  endif
endfunction
