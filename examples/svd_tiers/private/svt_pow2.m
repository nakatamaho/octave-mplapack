## SPDX-License-Identifier: BSD-2-Clause

function result = svt_pow2 (exponent)
  ## Return the exact MPFR value 2^exponent at the current project precision.
  if (! isnumeric (exponent) || ! isreal (exponent) || ! isscalar (exponent) ...
      || ! isfinite (exponent) || exponent != fix (exponent))
    error ("mplapack:svt:InvalidExponent", ...
           "power-of-two exponent must be an integer scalar");
  endif
  result = mp (2) ^ exponent;
endfunction
