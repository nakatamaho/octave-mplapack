% Construct an exact power of two through public MP binary operations.
function value = net_pow2 (exponent, bits)
  if (nargin != 2 || ! isnumeric (exponent) || ! isscalar (exponent) ...
      || ! isreal (exponent) || ! isfinite (exponent) ...
      || exponent != fix (exponent) || ! isnumeric (bits) ...
      || ! isscalar (bits) || bits != fix (bits) || bits < 1)
    error ("mplapack:neigt:Power", "invalid exact power-of-two arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    value = mp (1);
    if (exponent >= 0)
      for index = 1:exponent
        value = value * mp (2);
      endfor
    else
      for index = 1:(-exponent)
        value = value * mp ("0.5");
      endfor
    endif
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
