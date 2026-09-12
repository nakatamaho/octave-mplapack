## SPDX-License-Identifier: BSD-2-Clause

function value = svt_dyadic_decode (encoded, target_bits)
  ## Decode a canonical exact dyadic into an MPFR value at target_bits.
  if (! isstruct (encoded) || ! isfield (encoded, "sign") ...
      || ! isfield (encoded, "mantissa_hex") || ! isfield (encoded, "exponent2"))
    error ("mplapack:svt:DyadicRecord", "incomplete dyadic record");
  endif
  sign = encoded.sign;
  mantissa_hex = encoded.mantissa_hex;
  exponent2 = encoded.exponent2;
  if (! ischar (mantissa_hex) || isempty (mantissa_hex) ...
      || any (mantissa_hex != lower (mantissa_hex)) ...
      || any (! ismember (mantissa_hex, '0123456789abcdef')) ...
      || ! isnumeric (exponent2) || ! isscalar (exponent2) ...
      || exponent2 != fix (exponent2) || ! any (sign == [-1, 0, 1]))
    error ("mplapack:svt:DyadicRecord", "invalid dyadic fields");
  endif
  if (sign == 0)
    if (! strcmp (mantissa_hex, "0") || exponent2 != 0)
      error ("mplapack:svt:DyadicRecord", "zero dyadic has noncanonical fields");
    endif
    saved_bits = mpbits ();
    cleanup = onCleanup (@() mpbits (saved_bits));
    mpbits (target_bits);
    if (isfield (encoded, "zero_signbit") && encoded.zero_signbit)
      value = mp ("-0");
    else
      value = mp (0);
    endif
    clear cleanup;
    return;
  endif
  if (mantissa_hex(1) == '0' || mod (hex_digit (mantissa_hex(end)), 2) == 0)
    error ("mplapack:svt:DyadicRecord", "nonzero mantissa is not positive odd");
  endif
  first_digit = hex_digit (mantissa_hex(1));
  leading_bits = 0;
  while first_digit > 0
    leading_bits = leading_bits + 1;
    first_digit = fix (first_digit / 2);
  endwhile
  required_bits = 4 * (numel (mantissa_hex) - 1) + leading_bits;
  if (! isnumeric (target_bits) || ! isscalar (target_bits) ...
      || target_bits != fix (target_bits) || target_bits < required_bits)
    error ("mplapack:svt:DyadicInsufficientPrecision", ...
           "target precision cannot represent dyadic mantissa");
  endif
  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (target_bits);
  accumulator = mp (0);
  for index = 1:numel (mantissa_hex)
    accumulator = accumulator * mp (16) + mp (hex_digit (mantissa_hex(index)));
  endfor
  value = accumulator * svt_pow2 (exponent2);
  if (sign < 0)
    value = -value;
  endif
  clear cleanup;
endfunction

function value = hex_digit(character)
  index = find ('0123456789abcdef' == character, 1);
  if (isempty (index))
    error ("mplapack:svt:DyadicRecord", "invalid hexadecimal digit");
  endif
  value = index - 1;
endfunction
