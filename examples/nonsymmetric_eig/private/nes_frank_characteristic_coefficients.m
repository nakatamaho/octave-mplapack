% Return Frank characteristic coefficients by its independent recurrence.
function coefficients = nes_frank_characteristic_coefficients (n, bits)
  if (nargin != 2 || ! (isnumeric (n) && isscalar (n) && n == fix (n)
                         && n >= 0))
    error ("NEIG:FrankPolynomial", "Frank polynomial degree must be nonnegative");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    p0 = mp (1);
    p1 = mp ([1, -1]);
    if (n == 0)
      coefficients = p0;
    elseif (n == 1)
      coefficients = p1;
    else
      for degree = 2:n
        zero = mp ("0");
        p = [p1, zero] - [zero, p1] ...
            - (degree - 1) * [zero, p0, zero];
        p0 = p1;
        p1 = p;
      endfor
      coefficients = p1;
    endif
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
