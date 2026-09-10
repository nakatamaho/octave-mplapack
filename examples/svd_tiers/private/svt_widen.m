## SPDX-License-Identifier: BSD-2-Clause

function result = svt_widen (value, target_bits)
  ## Widen an existing mp value by adding an exact zero created at target_bits.
  ## This is intentionally not a text or binary64 round trip.  The existing
  ## core metadata query is used only to reject a target below source storage;
  ## no new public precision-inspection API is introduced.
  if (! isa (value, "mp") || ! isscalar (target_bits) ...
      || ! isfinite (target_bits) || target_bits != fix (target_bits) ...
      || target_bits < 64)
    error ("mplapack:svt:InvalidWidening", ...
           "svt_widen requires an mp value and an integer target of at least 64 bits");
  endif
  info = __mplapack_core__ ("value_shape_info", value);
  if (target_bits < info.precision_bits)
    error ("mplapack:svt:InsufficientWidening", ...
           "cannot narrow an mp value while widening: source=%d target=%d", ...
           info.precision_bits, target_bits);
  endif
  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (target_bits);
  if (isfield (info, "rows") && isfield (info, "columns") ...
      && (info.rows != 1 || info.columns != 1))
    zero = mp (zeros (info.rows, info.columns));
  else
    zero = mp (0);
  endif
  result = value + zero;
  clear cleanup;
endfunction
