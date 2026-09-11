% Exact small determinant by fraction-free MP elimination.
% This is an independent checker for integer/dyadic fixture identities.
function [value, metadata] = net_exact_det_permutation (matrix, bits)
  if (nargin != 2 || ! isa (matrix, "mp") || rows (matrix) != columns (matrix) ...
      || rows (matrix) < 1 || rows (matrix) > 8)
    error ("mplapack:neigt:Determinant", ...
           "permutation determinant is restricted to 1-by-1 through 8-by-8");
  endif
  n = rows (matrix);
  check_bits = max (64, bits + net_ceil_log2_integer (factorial (n)) + 8);
  saved_bits = mpbits ();
  unwind_protect
    mpbits (check_bits);
    work = matrix;
    sign = mp (1);
    previous_pivot = mp (1);
    for k = 1:(n - 1)
      pivot_row = k;
      while (pivot_row <= n && work(pivot_row, k) == mp (0))
        pivot_row += 1;
      endwhile
      if (pivot_row > n)
        value = mp (0);
        metadata = struct ("method", "fraction_free_bareiss_v1", ...
                           "permutations", factorial (n), ...
                           "check_bits", check_bits, "exact", true, ...
                           "singular", true);
        return;
      endif
      if (pivot_row != k)
        temporary = work(k, :);
        work(k, :) = work(pivot_row, :);
        work(pivot_row, :) = temporary;
        sign = -sign;
      endif
      pivot = work(k, k);
      for i = (k + 1):n
        for j = (k + 1):n
          work(i, j) = (pivot * work(i, j) - work(i, k) * work(k, j)) ...
                       / previous_pivot;
        endfor
      endfor
      previous_pivot = pivot;
      work((k + 1):n, k) = mp (0);
    endfor
    value = sign * work(n, n);
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
  metadata = struct ("method", "fraction_free_bareiss_v1", ...
                     "permutations", factorial (n), "check_bits", check_bits, ...
                     "exact", true);
endfunction
