% Convert an MP matrix to a point rectangle matrix.
function result = net_iv_cmatrix_point (value, q)
  net_iv_q (q);
  if (nargin != 2 || ! isa (value, "mp") || ndims (value) > 2 ...
      || ! all (isfinite (real (value))) || ! all (isfinite (imag (value))))
    error ("mplapack:neigt:MatrixInterval", "invalid MP matrix");
  endif
  result = struct ("kind", "complex_matrix", ...
    "rl", mp (zeros (size (value))), "rh", mp (zeros (size (value))), ...
    "il", mp (zeros (size (value))), "ih", mp (zeros (size (value))));
  if (isscalar (value))
    box = net_iv_complex_point (value, q);
    result.rl = box.rl;
    result.rh = box.rh;
    result.il = box.il;
    result.ih = box.ih;
    return;
  endif
  for index = 1:numel (value)
    box = net_iv_complex_point (value(index), q);
    result.rl(index) = box.rl;
    result.rh(index) = box.rh;
    result.il(index) = box.il;
    result.ih(index) = box.ih;
  endfor
endfunction
