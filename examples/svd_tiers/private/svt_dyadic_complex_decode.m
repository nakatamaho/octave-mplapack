## SPDX-License-Identifier: BSD-2-Clause

function value = svt_dyadic_complex_decode (encoded, target_bits)
  if (! isstruct (encoded) || ! isfield (encoded, "real") ...
      || ! isfield (encoded, "imag"))
    error ("mplapack:svt:DyadicRecord", "incomplete complex dyadic record");
  endif
  real_part = svt_dyadic_decode (encoded.real, target_bits);
  imag_part = svt_dyadic_decode (encoded.imag, target_bits);
  value = real_part + imag_part * mp ('0', '1');
endfunction
