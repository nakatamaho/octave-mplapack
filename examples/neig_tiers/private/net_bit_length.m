% Exact significand-bit length for a nonzero nonnegative integer MP value.
function answer = net_bit_length (value, bits)
  if (nargin != 2 || ! isa (value, "mp") || ! isscalar (value))
    error ("mplapack:neigt:BitLength", "expected an MP scalar");
  endif
  if (value == mp (0))
    answer = 0;
    return;
  endif
  if (value < mp (0))
    value = -value;
  endif
  answer = 0;
  lower = mp (1);
  while (value >= lower)
    answer += 1;
    lower = lower * mp (2);
  endwhile
endfunction
