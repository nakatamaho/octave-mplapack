% Enlarge a complex rectangle by a verified entrywise modulus radius.
function result = net_v_a2_expand_modulus (matrix, eta, q)
  net_iv_q (q);
  if (! isstruct (matrix) || ! isfield (matrix, "kind") ...
      || ! strcmp (matrix.kind, "complex_matrix") || ! isscalar (eta) ...
      || ! isfinite (eta) || eta < mp (0))
    error ("mplapack:neigt:VA2", "invalid enclosure expansion");
  endif
  result = matrix;
  for index = 1:numel (matrix.rl)
    result.rl(index) = net_iv_primitive ("sub", matrix.rl(index), eta, q).lo;
    result.rh(index) = net_iv_primitive ("add", matrix.rh(index), eta, q).hi;
    result.il(index) = net_iv_primitive ("sub", matrix.il(index), eta, q).lo;
    result.ih(index) = net_iv_primitive ("add", matrix.ih(index), eta, q).hi;
  endfor
endfunction
