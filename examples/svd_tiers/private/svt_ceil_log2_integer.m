## SPDX-License-Identifier: BSD-2-Clause

function result = svt_ceil_log2_integer (value)
  ## Exact ceil(log2(value)) for a positive small integer.  The loop uses only
  ## integer comparisons and therefore has no power-of-two boundary rounding.
  if (! isnumeric (value) || ! isreal (value) || ! isscalar (value) ...
      || ! isfinite (value) || value != fix (value) || value < 1)
    error ("mplapack:svt:InvalidInteger", ...
           "ceil-log2 input must be a positive integer");
  endif
  result = 0;
  power = 1;
  while (power < value)
    power = power * 2;
    result = result + 1;
  endwhile
endfunction
