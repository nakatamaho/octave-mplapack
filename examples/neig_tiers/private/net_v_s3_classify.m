% Classify a rigorously enclosed sigma_min interval against epsilon.
% This helper deliberately leaves boundary/straddling intervals inconclusive.
function result = net_v_s3_classify (lower, upper, epsilon)
  if (nargin != 3 || ! isa (lower, "mp") || ! isa (upper, "mp") ...
      || ! isa (epsilon, "mp") || ! isscalar (lower) || ! isscalar (upper) ...
      || ! isscalar (epsilon) || ! isfinite (lower) || ! isfinite (upper) ...
      || ! isfinite (epsilon) || lower < mp (0) || upper < lower ...
      || epsilon <= mp (0))
    error ("mplapack:neigt:VS3", "invalid singular-value classification interval");
  endif
  if (upper <= epsilon)
    result = "CERTIFIED_INSIDE";
  elseif (lower > epsilon)
    result = "CERTIFIED_OUTSIDE";
  else
    result = "INCONCLUSIVE";
  endif
endfunction
