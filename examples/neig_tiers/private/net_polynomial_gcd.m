% Exact rational polynomial gcd for dyadic MP coefficients.
% Coefficients are scaled to bounded integers before pseudo-division, so a
% theoretically zero remainder cannot become a tiny MP residue and loop.
function result = net_polynomial_gcd (p, q, bits)
  if (nargin != 3 || ! isa (p, "mp") || ! isa (q, "mp") ...
      || rows (p) != 1 || rows (q) != 1 || bits != fix (bits) || bits < 64)
    error ("mplapack:neigt:Polynomial", "invalid polynomial gcd arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    [p_integer, p_scale] = dyadic_integer_polynomial (p, bits);
    [q_integer, q_scale] = dyadic_integer_polynomial (q, bits);
    first = trim_integer (p_integer);
    second = trim_integer (q_integer);
    while (!is_zero_integer_poly (second))
      remainder = pseudo_remainder (first, second);
      first = second;
      second = trim_integer (remainder);
    endwhile
    first = primitive_integer (trim_integer (first));
    gcd_mp = mp (zeros (1, numel (first)));
    for index = 1:numel (first)
      gcd_mp(index) = integer_to_mp (first(index));
    endfor
    % A rational gcd is defined only up to a nonzero scalar. The integer
    % primitive representative is the replayable exact witness.
    result = struct ("gcd", gcd_mp, "degree", numel (first) - 1, ...
      "square_free", numel (first) == 1, ...
      "method", "dyadic_integer_pseudo_remainder_v1", ...
      "p_scale_exponent2", p_scale, "q_scale_exponent2", q_scale, ...
      "exact", true);
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function [integer_poly, common_exponent] = dyadic_integer_polynomial (poly, bits)
  nonzero_exponents = [];
  for index = 1:numel (poly)
    if (poly(index) != mp (0))
      decomposition = net_dyadic_decompose (poly(index), bits);
      nonzero_exponents(end + 1) = decomposition.exponent;
    endif
  endfor
  if (isempty (nonzero_exponents))
    integer_poly = int64 (zeros (1, numel (poly)));
    common_exponent = 0;
    return;
  endif
  common_exponent = min (nonzero_exponents);
  scale = net_pow2 (common_exponent, bits);
  integer_poly = int64 (zeros (1, numel (poly)));
  for index = 1:numel (poly)
    scaled = poly(index) / scale;
    if (scaled != mp (0))
      rounded = floor (abs (scaled));
      if (rounded != abs (scaled))
        error ("mplapack:neigt:Polynomial", ...
               "non-dyadic coefficient in exact gcd input");
      endif
      integer_poly(index) = mp_integer (scaled);
    endif
  endfor
endfunction

function value = mp_integer (input)
  negative = (input < 0);
  if (isa (input, "mp"))
    magnitude = floor (abs (input));
  else
    magnitude = abs (input);
  endif
  value = int64 (0);
  two = int64 (2);
  while (magnitude != 0)
    if (isa (magnitude, "mp"))
      half = floor (magnitude / mp (2));
      remainder_bit = magnitude - mp (2) * half;
      bit = int64 (0);
      if (remainder_bit == mp (1))
        bit = int64 (1);
      elseif (remainder_bit != mp (0))
        error ("mplapack:neigt:Polynomial", "non-integer MP coefficient");
      endif
      magnitude = half;
    else
      bit = mod (magnitude, two);
      magnitude = idivide (magnitude, two, "floor");
    endif
    value = value * two + bit;
  endwhile
  if (negative)
    value = -value;
  endif
endfunction

function value = integer_to_mp (input)
  negative = (input < int64 (0));
  magnitude = abs (input);
  value = mp (0);
  power = mp (1);
  two = int64 (2);
  while (magnitude != int64 (0))
    if (mod (magnitude, two) != int64 (0))
      value = value + power;
    endif
    magnitude = idivide (magnitude, two, "floor");
    power = power * mp (2);
  endwhile
  if (negative)
    value = -value;
  endif
endfunction

function value = trim_integer (value)
  while (numel (value) > 1 && value(1) == int64 (0))
    value = value(2:end);
  endwhile
endfunction

function result = is_zero_integer_poly (value)
  result = (numel (value) == 1 && value == int64 (0));
endfunction

function remainder = pseudo_remainder (dividend, divisor)
  dividend = trim_integer (dividend);
  divisor = trim_integer (divisor);
  if (is_zero_integer_poly (divisor))
    error ("mplapack:neigt:Polynomial", "division by zero polynomial");
  endif
  remainder = dividend;
  divisor_degree = numel (divisor) - 1;
  while (!is_zero_integer_poly (remainder) ...
         && numel (remainder) - 1 >= divisor_degree)
    leading = remainder(1);
    shifted = int64 (zeros (1, numel (remainder)));
    shifted(1:numel (divisor)) = leading * divisor;
    remainder = int64 (divisor(1) * remainder - shifted);
    remainder = trim_integer (remainder);
  endwhile
endfunction

function value = primitive_integer (value)
  value = trim_integer (value);
  if (is_zero_integer_poly (value))
    return;
  endif
  common = abs (value(1));
  for index = 2:numel (value)
    common = integer_gcd (common, abs (value(index)));
  endfor
  if (common > int64 (1))
    value = idivide (value, common, "floor");
  endif
  if (value(1) < int64 (0))
    value = -value;
  endif
endfunction

function result = integer_gcd (a, b)
  a = abs (a);
  b = abs (b);
  while (b != int64 (0))
    remainder = mod (a, b);
    a = b;
    b = remainder;
  endwhile
  result = a;
endfunction
