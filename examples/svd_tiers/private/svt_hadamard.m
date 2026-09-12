## SPDX-License-Identifier: BSD-2-Clause

function [h, g] = svt_hadamard (n)
  ## Build the Sylvester H and its one-row cyclic downward shift G as dense mp
  ## matrices.  Integer +/-1 entries are exact in every supported precision.
  if (! isnumeric (n) || ! isreal (n) || ! isscalar (n) ...
      || ! isfinite (n) || n != fix (n) || n < 1 ...
      || 2 ^ svt_ceil_log2_integer (n) != n)
    error ("mplapack:svt:InvalidHadamardSize", ...
           "Hadamard size must be a positive power of two");
  endif
  h = mp (1);
  while rows (h) < n
    h = [h, h; h, -h];
  endwhile
  if (n == 1)
    g = h;
  else
    g = [h(n, :); h(1:n-1, :)];
  endif
endfunction
