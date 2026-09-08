## SPDX-License-Identifier: BSD-2-Clause

function pp = pchip (x, y)
  if (nargin != 2)
    error ("mplapack:interp:InvalidArguments", "pchip expects x and y");
  endif
  [x, y, template] = mp_interp_normalize (x, y, "pchip");
  pp = mp_interp_make_pp (x, y, "pchip");
endfunction
