function result = net_iv_real_neg (a)
  if (! isstruct (a) || ! strcmp (a.kind, "real")
      || ! isfinite (a.lo) || ! isfinite (a.hi))
    error ("mplapack:neigt:Interval", "invalid real interval");
  endif
  result = net_iv_real (-a.hi, -a.lo);
endfunction
