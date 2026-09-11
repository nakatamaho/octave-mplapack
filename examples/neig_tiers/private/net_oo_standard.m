% Ozaki--Ogita requested standard forms at their fixed generation precision.
function S = net_oo_standard (kind, n, bits)
  if (nargin != 3 || ! ischar (kind) || ! isnumeric (n) ...
      || ! isscalar (n) || n != fix (n) || n < 2)
    error ("mplapack:neigt:OO", "invalid standard-form arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    S = mp (zeros (n, n));
    if (strcmp (kind, "OO53_REAL"))
      delta = net_pow2 (-45, bits);
      for i = 1:n
        S(i, i) = mp (i) + delta;
        if (i < n)
          S(i, i + 1) = mp (32);
        endif
      endfor
    elseif (strcmp (kind, "OO53_PAIR"))
      if (mod (n, 2) != 0)
        error ("mplapack:neigt:OO", "OO53_PAIR requires even n");
      endif
      delta = net_pow2 (-45, bits);
      for block = 0:(n / 2 - 1)
        first = 2 * block + 1;
        a = mp (2 * block + 1) + delta;
        b = mp (2 * block + 1) / mp (8) + delta;
        S(first, first) = a;
        S(first + 1, first + 1) = a;
        S(first, first + 1) = b;
        S(first + 1, first) = -b;
        if (first + 2 <= n)
          S(first, first + 2) = mp (8);
          S(first + 1, first + 3) = mp (8);
        endif
      endfor
    elseif (strcmp (kind, "OO128_CLOSE"))
      if (bits != 128)
        error ("mplapack:neigt:OO", "OO128_CLOSE has fixed generation precision 128");
      endif
      delta = net_pow2 (-80, bits);
      tiny = net_pow2 (-120, bits);
      for i = 1:n
        if (i == 1)
          S(i, i) = mp (1);
        elseif (i == 2)
          S(i, i) = mp (1) + delta + tiny;
        else
          S(i, i) = mp (i);
        endif
        if (i < n)
          S(i, i + 1) = mp (1);
        endif
      endfor
    else
      error ("mplapack:neigt:OO", "unknown Ozaki--Ogita standard form");
    endif
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
