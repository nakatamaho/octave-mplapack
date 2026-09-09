## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} ppder (@dots{})
## Differentiate or integrate a supported arbitrary-precision piecewise-polynomial form.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits, mpdigits}
## @end deftypefn

function result = ppder (pp)
  if (! isstruct (pp) || ! isscalar (pp) || ! isfield (pp, "form")
      || ! strcmp (pp.form, "pp") || pp.order < 1)
    error ("mplapack:interp:InvalidPP", "ppder expects an pp struct");
  endif
  old_order = pp.order;
  new_order = max (1, old_order - 1);
  zero = mp_interp_element (pp.coefs, 1, 1) * 0;
  coefficients = repmat (zero, pp.pieces, new_order);
  if (old_order > 1)
    for piece = 1:pp.pieces
      for column = 1:(old_order - 1)
        factor = old_order - column;
        coefficients = mp_interp_put (coefficients, piece, column, ...
                                      mp_interp_element (pp.coefs, piece, column) * factor);
      endfor
    endfor
  endif
  result = pp;
  result.coefs = coefficients;
  result.order = new_order;
endfunction
