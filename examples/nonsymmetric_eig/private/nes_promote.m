% Promote a represented value for diagnostics without recomputing it.
function value = nes_promote (source, bits, source_bits)
  if (nargin != 3)
    error ("NEIG:PromotionArguments", ...
           "nes_promote expects source, destination bits, and source bits");
  endif
  if (! (isnumeric (bits) && isscalar (bits) && isreal (bits)
         && isfinite (bits) && bits == fix (bits) && bits >= 1))
    error ("NEIG:PromotionPrecision", "destination precision must be a positive integer");
  endif
  if (! (isnumeric (source_bits) && isscalar (source_bits) && isreal (source_bits)
         && isfinite (source_bits) && source_bits == fix (source_bits)
         && source_bits >= 1 && bits >= source_bits))
    error ("NEIG:PromotionPrecision", ...
           "destination precision must not be below the recorded source precision");
  endif
  if (! (isa (source, "mp") || isa (source, "double")))
    error ("NEIG:PromotionType", "source must be an mp value or a native double value");
  endif

  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    if (isa (source, "mp"))
      value = source + mp (zeros (size (source)));
    else
      value = mp (source);
    endif
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
