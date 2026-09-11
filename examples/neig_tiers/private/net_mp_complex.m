% Construct one complex MP scalar from MP real and imaginary components.
function value = net_mp_complex (real_part, imaginary_part)
  if (nargin != 2 || ! isa (real_part, "mp") || ! isa (imaginary_part, "mp") ...
      || ! isscalar (real_part) || ! isscalar (imaginary_part))
    error ("mplapack:neigt:Complex", "expected two MP scalar components");
  endif
  value = real_part + imaginary_part * mp ("(0,1)");
endfunction
