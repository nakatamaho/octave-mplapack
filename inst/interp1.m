## SPDX-License-Identifier: BSD-2-Clause

function result = interp1 (x, y, query, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{yi} =} interp1 (@var{x}, @var{y}, @var{xi})
  ## @deftypefnx {} {@var{yi} =} interp1 (@dots{}, @var{method})
  ## @deftypefnx {} {@var{yi} =} interp1 (@dots{}, @var{method}, @var{extrap})
  ## Interpolate one-dimensional MP data without converting the grid or query
  ## points to binary64.  Supported methods are nearest, previous, next,
  ## linear, pchip, and spline.
  ## @end deftypefn
  if (nargin < 3 || nargin > 5)
    error ("mplapack:interp:InvalidArguments", ...
           "interp1 expects x, y, query, and optional method/extrapolation");
  endif
  [x, y, template] = mp_interp_normalize (x, y, "interp1");
  method = "linear";
  extrapolate = false;
  extrapolation = [];
  pp_request = false;
  if (ischar (query))
    if (nargin != 4 || ! ischar (varargin{1})
        || ! strcmp (lower (varargin{1}), "pp"))
      error ("mplapack:interp:InvalidArguments", ...
             "interp1 pp form is interp1(x,y,method,\"pp\")");
    endif
    method = lower (query);
    pp_request = true;
  endif
  if (pp_request)
    supported_pp = {"linear", "pchip", "spline"};
    if (! any (strcmp (method, supported_pp)))
      error ("mplapack:interp:InvalidMethod", ...
             "this interp1 method has no pp form");
    endif
    if (strcmp (method, "linear"))
      result = mp_interp_make_linear_pp (x, y);
    else
      result = mp_interp_make_pp (x, y, method);
    endif
    return;
  endif
  if (nargin >= 4)
    option = varargin{1};
    if (! ischar (option))
      extrapolation = option;
      extrapolate = true;
    else
      method = lower (option);
      if (strcmp (method, "extrap"))
        method = "linear";
        extrapolate = true;
      endif
    endif
  endif
  if (nargin == 5)
    extrapolation = varargin{2};
    if (ischar (extrapolation) && strcmp (lower (extrapolation), "extrap"))
      extrapolation = [];
    endif
    extrapolate = true;
  endif
  if (strcmp (method, "pp"))
    if (nargin != 4)
      error ("mplapack:interp:InvalidArguments", ...
             "interp1 pp form accepts the method without extrapolation");
    endif
    if (nargout != 1)
      error ("mplapack:interp:InvalidOutput", "interp1 pp form returns one pp output");
    endif
    result = mp_interp_make_pp (x, y, "spline");
    return;
  endif
  supported = {"nearest", "previous", "next", "linear", "pchip", "spline"};
  if (! any (strcmp (method, supported)))
    error ("mplapack:interp:InvalidMethod", "unsupported interp1 method");
  endif
  if (strcmp (method, "pchip") || strcmp (method, "spline"))
    pp = mp_interp_make_pp (x, y, method);
  endif
  if (! isa (query, "mp"))
    query = template * 0 + query;
  endif
  output_zero = mp_interp_element (y, 1) * 0;
  result = repmat (output_zero, rows (query), columns (query));
  last_piece = rows (x) - 1;
  for column = 1:columns (query)
    for row = 1:rows (query)
      point = mp_interp_element (query, row, column);
      outside = point < mp_interp_element (x, 1) ...
                || point > mp_interp_element (x, rows (x));
      if (outside && ! extrapolate)
        value = output_zero + NaN;
      elseif (outside && extrapolate && ! isempty (extrapolation))
        if (isa (extrapolation, "mp"))
          value = extrapolation;
        else
          value = output_zero + extrapolation;
        endif
      elseif (strcmp (method, "pchip") || strcmp (method, "spline"))
        value = ppval (pp, point);
      else
        piece = mp_interp_piece_for_interp (x, point);
        left = mp_interp_element (x, piece);
        right = mp_interp_element (x, piece + 1);
        left_value = mp_interp_element (y, piece);
        right_value = mp_interp_element (y, piece + 1);
        if (strcmp (method, "linear"))
          value = left_value + (point - left) ...
                  * (right_value - left_value) / (right - left);
        elseif (strcmp (method, "nearest"))
          if (abs (point - left) < abs (right - point))
            value = left_value;
          else
            value = right_value;
          endif
        elseif (strcmp (method, "previous"))
          value = left_value;
        else
          value = right_value;
        endif
      endif
      result = mp_interp_put (result, row, column, value);
    endfor
  endfor
endfunction

function piece = mp_interp_piece_for_interp (grid, point)
  piece = rows (grid) - 1;
  if (point <= mp_interp_element (grid, 1))
    piece = 1;
    return;
  endif
  for index = 1:(rows (grid) - 1)
    if (point <= mp_interp_element (grid, index + 1))
      piece = index;
      return;
    endif
  endfor
endfunction
