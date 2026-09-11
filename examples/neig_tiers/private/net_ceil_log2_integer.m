% Exact ceil(log2(n)) for a bounded positive integer dimension.
function answer = net_ceil_log2_integer (n)
  if (! isnumeric (n) || ! isscalar (n) || ! isreal (n) ...
      || ! isfinite (n) || n != fix (n) || n < 1)
    error ("mplapack:neigt:Integer", "expected a positive integer");
  endif
  answer = 0;
  power = 1;
  while (power < n)
    power *= 2;
    answer += 1;
  endwhile
endfunction
