% Exact widening of an existing represented value without text conversion.
function value = net_widen (source, target_bits, source_bits)
  if (nargin != 3 || ! (isa (source, "mp") || isa (source, "double")) ...
      || ! isnumeric (target_bits) || ! isscalar (target_bits) ...
      || target_bits != fix (target_bits) || target_bits < 1 ...
      || ! isnumeric (source_bits) || ! isscalar (source_bits) ...
      || source_bits != fix (source_bits) || source_bits < 1 ...
      || target_bits < source_bits)
    error ("mplapack:neigt:Widen", "invalid exact-widening arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (target_bits);
    if (isa (source, "mp"))
      value = source + mp (zeros (size (source)));
    else
      value = mp (source);
    endif
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
