## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} pchip (@dots{})
## Construct a piecewise-polynomial interpolant from arbitrary-precision data.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits, mpdigits}
## @end deftypefn

function pp = pchip (x, y)
  if (nargin != 2)
    error ("mplapack:interp:InvalidArguments", "pchip expects x and y");
  endif
  [x, y, template] = mp_interp_normalize (x, y, "pchip");
  pp = mp_interp_make_pp (x, y, "pchip");
endfunction
