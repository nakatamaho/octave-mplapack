## SPDX-License-Identifier: BSD-2-Clause

function encoded = svt_dyadic_complex_encode (value, q)
  if (! isa (value, "mp") || ! isscalar (value) || isreal (value))
    error ("mplapack:svt:DyadicType", "complex encoder expects a complex mp scalar");
  endif
  value = svt_widen (value, q);
  encoded = struct ("schema", "svt-dyadic-complex-v1", ...
                    "real", svt_dyadic_encode (real (value), q), ...
                    "imag", svt_dyadic_encode (imag (value), q));
endfunction
