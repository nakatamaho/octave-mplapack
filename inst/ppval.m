## SPDX-License-Identifier: BSD-2-Clause

function result = ppval (pp, query)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{y} =} ppval (@var{pp}, @var{x})
  ## Evaluate a scalar-output MP piecewise polynomial using MPFR/MPC Horner
  ## arithmetic.  Extrapolation uses the first or last piece.
  ## @end deftypefn
  if (! isstruct (pp) || ! isscalar (pp) || ! isfield (pp, "form")
      || ! strcmp (pp.form, "pp") || ! isfield (pp, "breaks")
      || ! isfield (pp, "coefs") || ! isa (pp.breaks, "mp")
      || ! isa (pp.coefs, "mp"))
    error ("mplapack:interp:InvalidPP", ...
           "ppval expects an MPLAPACK scalar piecewise polynomial");
  endif
  if (! isnumeric (query))
    error ("mplapack:interp:InvalidQuery", "ppval query must be numeric");
  endif
  break_template = mp_interp_element (pp.breaks, 1);
  if (! isa (query, "mp"))
    query = break_template * 0 + query;
  endif
  zero = mp_interp_element (pp.coefs, 1, columns (pp.coefs)) * 0;
  result = repmat (zero, rows (query), columns (query));
  for column = 1:columns (query)
    for row = 1:rows (query)
      point = mp_interp_element (query, row, column);
      piece = mp_interp_piece (pp.breaks, point);
      origin = mp_interp_element (pp.breaks, piece);
      value = mp_interp_element (pp.coefs, piece, 1);
      for coefficient = 2:columns (pp.coefs)
        value = value * (point - origin) ...
                + mp_interp_element (pp.coefs, piece, coefficient);
      endfor
      result = mp_interp_put (result, row, column, value);
    endfor
  endfor
endfunction

function piece = mp_interp_piece (breaks, point)
  count = rows (breaks);
  piece = count - 1;
  if (point <= mp_interp_element (breaks, 1))
    piece = 1;
    return;
  endif
  for index = 1:(count - 1)
    if (point <= mp_interp_element (breaks, index + 1))
      piece = index;
      return;
    endif
  endfor
endfunction
