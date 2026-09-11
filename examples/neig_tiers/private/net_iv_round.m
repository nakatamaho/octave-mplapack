% Enclose one MPFR round-to-nearest primitive by the ARITHMETIC.md margin.
function result = net_iv_round (rounded, q, zero_witness, operation)
  if (nargin < 3 || nargin > 4)
    error ("mplapack:neigt:IntervalPrimitive", "invalid primitive arguments");
  endif
  net_iv_q (q);
  if (mpbits () != q)
    error ("mplapack:neigt:IntervalPrecision", ...
           "primitive must execute at its declared current precision");
  endif
  if (! isa (rounded, "mp") || ! isscalar (rounded) || ! isfinite (rounded))
    error ("mplapack:neigt:IntervalRange", ...
           "primitive result is not finite");
  endif
  if (nargin < 4)
    operation = "unknown";
  endif
  if (rounded == mp (0))
    if (! islogical (zero_witness) || ! isscalar (zero_witness) ...
        || ! zero_witness)
      error ("mplapack:neigt:UnexpectedZero", ...
             "zero primitive result lacks an exact-zero witness for %s", operation);
    endif
    result = net_iv_real (mp (0), mp (0));
    return;
  endif
  persistent cached_q cached_lower_limit cached_upper_limit cached_unit;
  if (isempty (cached_q) || cached_q != q)
    cached_q = q;
    cached_lower_limit = net_pow2 (-8192, q);
    cached_upper_limit = net_pow2 (8192, q);
    cached_unit = net_pow2 (-q, q);
  endif
  lower_limit = cached_lower_limit;
  upper_limit = cached_upper_limit;
  magnitude = abs (rounded);
  if (magnitude < lower_limit || magnitude > upper_limit)
    error ("mplapack:neigt:IntervalRange", ...
           "primitive result is outside the verified range for %s", operation);
  endif
  margin = mp (8) * cached_unit * magnitude;
  lo = rounded - margin;
  hi = rounded + margin;
  if (! isfinite (lo) || ! isfinite (hi) || lo > hi)
    error ("mplapack:neigt:IntervalRange", ...
           "outward endpoint construction failed for %s", operation);
  endif
  result = net_iv_real (lo, hi);
endfunction
