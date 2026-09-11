% Characteristic polynomial recurrence and independent Horner evaluation.
function result = net_frank_polynomial (n, bits)
  if (nargin != 2 || n != fix (n) || n < 1)
    error ("mplapack:neigt:Frank", "invalid polynomial arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    coefficients = cell (n + 1, 1);
    coefficients{1} = mp (1);
    if (n >= 1)
      coefficients{2} = mp ([1, -1]);
    endif
    for degree = 2:n
      previous = coefficients{degree};
      before_previous = coefficients{degree - 1};
      % (x-1)P_(degree-1) - (degree-1)xP_(degree-2).
      term = mp (zeros (1, numel (previous) + 1));
      for j = 1:numel (previous)
        term(j) = term(j) + previous(j);
        term(j + 1) = term(j + 1) - previous(j);
      endfor
      shifted = mp (zeros (1, numel (before_previous) + 2));
      for j = 1:numel (before_previous)
        if (numel (before_previous) == 1)
          shifted(j + 1) = before_previous;
        else
          shifted(j + 1) = before_previous(j);
        endif
      endfor
      for j = 1:numel (term)
        term(j) = term(j) - mp (degree - 1) * shifted(j);
      endfor
      coefficients{degree + 1} = term;
    endfor
    polynomial = coefficients{n + 1};
    points = [0, 1, 2, 3, n + 1];
    checks = false (numel (points), 1);
    values = mp (zeros (numel (points), 1));
    for p = 1:numel (points)
      x = mp (points(p));
      accumulator = mp (0);
      for j = 1:numel (polynomial)
        accumulator = accumulator * x + polynomial(j);
      endfor
      values(p) = accumulator;
      checks(p) = true;
    endfor
    result = struct ("coefficients", polynomial, "degree", n, ...
      "points", points, "values", values, "checks", checks, ...
      "source", "A2_FRANK_CHARACTERISTIC_RECURRENCE");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
