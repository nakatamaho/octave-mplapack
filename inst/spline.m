## SPDX-License-Identifier: BSD-2-Clause

function pp = spline (x, y)
  if (nargin != 2)
    error ("mplapack:interp:InvalidArguments", "spline expects x and y");
  endif
  [x, y, template] = mp_interp_normalize (x, y, "spline");
  pp = mp_interp_make_pp (x, y, "spline");
endfunction
