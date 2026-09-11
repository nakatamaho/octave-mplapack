function result = net_iv_complex_point (value, q)
  net_iv_q (q);
  if (nargin != 2 || ! isa (value, "mp") || ! isscalar (value) ...
      || ! isfinite (real (value)) || ! isfinite (imag (value)))
    error ("mplapack:neigt:Rectangle", "invalid complex point");
  endif
  result = net_iv_complex (real (value), real (value), imag (value), imag (value));
endfunction
