## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} ppint (@dots{})
## Differentiate or integrate a supported arbitrary-precision piecewise-polynomial form.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits, mpdigits}
## @end deftypefn

function result = ppint (pp, varargin)
  if (! isstruct (pp) || ! isscalar (pp) || ! isfield (pp, "form")
      || ! strcmp (pp.form, "pp") || pp.order < 1 || nargin > 2)
    error ("mplapack:interp:InvalidPP", "ppint expects an pp struct and optional constant");
  endif
  zero = mp_interp_element (pp.coefs, 1, 1) * 0;
  constant = zero;
  if (nargin == 2)
    if (! isa (varargin{1}, "mp"))
      constant = zero + varargin{1};
    else
      constant = varargin{1};
    endif
  endif
  new_order = pp.order + 1;
  coefficients = repmat (zero, pp.pieces, new_order);
  for piece = 1:pp.pieces
    for column = 1:pp.order
      coefficients = mp_interp_put (coefficients, piece, column, ...
                                    mp_interp_element (pp.coefs, piece, column) ...
                                    / (pp.order - column + 1));
    endfor
    coefficients = mp_interp_put (coefficients, piece, new_order, constant);
    width = mp_interp_element (pp.breaks, piece + 1) ...
            - mp_interp_element (pp.breaks, piece);
    for column = 1:pp.order
      power = pp.order - column + 1;
      constant = constant + mp_interp_element (pp.coefs, piece, column) ...
                 / power * width ^ power;
    endfor
  endfor
  result = pp;
  result.coefs = coefficients;
  result.order = new_order;
endfunction
