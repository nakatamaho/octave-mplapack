% Reject an inverse pair unless both exact products equal identity.
function metadata = net_oo_validate_pair (X, Y, bits)
  if (nargin != 3 || ! isa (X, "mp") || ! isa (Y, "mp") ...
      || rows (X) != columns (X) || any (size (X) != size (Y)))
    error ("mplapack:neigt:OO", "invalid inverse-pair arguments");
  endif
  [xy, xy_metadata] = net_exact_product_dyadic (X, Y, bits);
  [yx, yx_metadata] = net_exact_product_dyadic (Y, X, bits);
  saved_bits = mpbits ();
  unwind_protect
    mpbits (max ([bits, xy_metadata.check_bits, yx_metadata.check_bits]));
    identity = mp (eye (rows (X)));
    if (! all (xy(:) == identity(:)) || ! all (yx(:) == identity(:)))
      error ("mplapack:neigt:OO", "inverse-pair exact identity check failed");
    endif
    metadata = struct ("valid", true, "xy", xy_metadata, "yx", yx_metadata, ...
                       "method", "common_dyadic_denominator_v1");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
