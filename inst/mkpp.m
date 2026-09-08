## SPDX-License-Identifier: BSD-2-Clause

function pp = mkpp (breaks, coefs, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{pp} =} mkpp (@var{breaks}, @var{coefs})
  ## Construct a scalar-output MP piecewise polynomial from MP breaks and
  ## coefficient rows in descending powers of the local coordinate.
  ## @end deftypefn
  if (nargin < 2 || nargin > 3 || ! isa (breaks, "mp")
      || ! isa (coefs, "mp") || rows (breaks) != 1 && columns (breaks) != 1)
    error ("mplapack:interp:InvalidPP", ...
           "mkpp expects mp break and coefficient arrays");
  endif
  if (rows (breaks) == 1)
    breaks = transpose (breaks);
  endif
  if (rows (breaks) < 2 || rows (coefs) != rows (breaks) - 1)
    error ("mplapack:interp:InvalidPP", ...
           "mkpp coefficient rows must equal the number of pieces");
  endif
  for index = 1:(rows (breaks) - 1)
    if (mp_interp_element (breaks, index + 1) <= mp_interp_element (breaks, index))
      error ("mplapack:interp:InvalidPP", "mkpp breaks must increase");
    endif
  endfor
  if (nargin == 3)
    dimension = varargin{1};
    if (! isnumeric (dimension) || ! isscalar (dimension) || dimension != 1)
      error ("mplapack:interp:InvalidPP", ...
             "only scalar-output pp values are currently supported");
    endif
  endif
  pp = struct ("form", "pp", "breaks", breaks, "coefs", coefs, ...
               "pieces", rows (coefs), "order", columns (coefs), ...
               "dim", 1, "method", "custom");
endfunction
