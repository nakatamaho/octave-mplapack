## SPDX-License-Identifier: BSD-2-Clause

function result = mp_order_less (lhs, rhs)
  ## Exact total order used by set operations.  Real values use MPFR order;
  ## complex values follow Octave's magnitude-then-phase ordering.
  lhs_nan = isnan (lhs);
  rhs_nan = isnan (rhs);
  if (lhs_nan || rhs_nan)
    result = ! lhs_nan && rhs_nan;
    return;
  endif
  if (isreal (lhs) && isreal (rhs))
    result = lhs < rhs;
    return;
  endif
  lhs_abs = abs (lhs);
  rhs_abs = abs (rhs);
  if (! isequal (lhs_abs, rhs_abs))
    result = lhs_abs < rhs_abs;
  else
    result = angle (lhs) < angle (rhs);
  endif
endfunction
