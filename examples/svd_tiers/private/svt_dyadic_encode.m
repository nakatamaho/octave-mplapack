## SPDX-License-Identifier: BSD-2-Clause

function encoded = svt_dyadic_encode (value, q)
  ## Encode a finite represented MPFR scalar without inspecting its payload.
  require_encoding_precision (q);
  if (! isa (value, "mp") || ! isscalar (value) || ! isreal (value))
    error ("mplapack:svt:DyadicType", "dyadic encoder expects a real mp scalar");
  endif
  source_signbit = logical (signbit (value));
  value = svt_widen (value, q);
  if (! isfinite (value))
    error ("mplapack:svt:DyadicNonfinite", "cannot encode a nonfinite value");
  endif
  if (value == mp (0))
    encoded = struct ("sign", 0, "mantissa_hex", "0", "exponent2", 0, ...
                      "zero_signbit", source_signbit);
    return;
  endif
  sign = 1;
  if (value < mp (0))
    sign = -1;
  endif
  magnitude = abs (value);
  lower = -32769;
  upper = 32769;
  while (upper - lower > 1)
    midpoint = fix ((lower + upper) / 2);
    if (magnitude >= svt_pow2 (midpoint))
      lower = midpoint;
    else
      upper = midpoint;
    endif
  endwhile
  if (lower < -32768 || lower > 32768)
    error ("mplapack:svt:DyadicRange", "dyadic exponent exceeds audited range");
  endif
  exponent = lower;
  scaled = magnitude / svt_pow2 (exponent);
  bits = repmat ('0', 1, q);
  for index = 1:q
    if (scaled >= mp (1))
      bits(index) = '1';
      scaled = scaled - mp (1);
    endif
    scaled = scaled * mp (2);
  endfor
  if (scaled != mp (0))
    error ("mplapack:svt:DyadicExtraction", ...
           "represented MP value did not terminate within its precision");
  endif
  last_one = find (bits == '1', 1, "last");
  if (isempty (last_one))
    error ("mplapack:svt:DyadicExtraction", "nonzero value has no extracted bit");
  endif
  trailing_zeroes = q - last_one;
  bits = bits(1:last_one);
  while (mod (numel (bits), 4) != 0)
    bits = ['0', bits];
  endwhile
  digits = '0123456789abcdef';
  mantissa_hex = repmat ('0', 1, numel (bits) / 4);
  for group = 1:numel (mantissa_hex)
    nibble = 0;
    for bit = 1:4
      nibble = 2 * nibble + (bits(4 * (group - 1) + bit) == '1');
    endfor
    mantissa_hex(group) = digits(nibble + 1);
  endfor
  exponent2 = exponent - (q - 1) + trailing_zeroes;
  encoded = struct ("sign", sign, "mantissa_hex", mantissa_hex, ...
                    "exponent2", exponent2, "zero_signbit", false);
endfunction

function require_encoding_precision(q)
  if (! isnumeric (q) || ! isscalar (q) || ! isfinite (q) || q != fix (q) ...
      || q < 64 || q > 4096 || mpbits () != q)
    error ("mplapack:svt:DyadicPrecision", ...
           "encoder requires ambient precision q in [64,4096]");
  endif
endfunction
