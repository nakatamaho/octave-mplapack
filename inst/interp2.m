## SPDX-License-Identifier: BSD-2-Clause

function result = interp2 (varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{zi} =} interp2 (@var{x}, @var{y}, @var{z}, @var{xi}, @var{yi})
  ## @deftypefnx {} {@var{zi} =} interp2 (@dots{}, @var{method})
  ## @deftypefnx {} {@var{zi} =} interp2 (@dots{}, @var{method}, @var{extrap})
  ## Evaluate a two-dimensional MP grid without converting coordinates or
  ## queries to binary64.  nearest, linear, pchip, and spline are supported.
  ## @end deftypefn
  if (nargin != 3 && (nargin < 5 || nargin > 7))
    error ("mplapack:interp:InvalidArguments", ...
           "interp2 expects z,xi,yi or x,y,z,xi,yi and options");
  endif

  if (nargin == 3)
    z = varargin{1};
    xi = varargin{2};
    yi = varargin{3};
    if (isa (z, "mp"))
      template = mp_interp_element (z, 1, 1);
    elseif (isa (xi, "mp"))
      template = mp_interp_element (xi, 1);
    elseif (isa (yi, "mp"))
      template = mp_interp_element (yi, 1);
    else
      error ("mplapack:interp:RequiresMp", "interp2 requires an mp input");
    endif
    z = mp_interp2_promote (z, template);
    coordinate_template = real (template);
    x = coordinate_template * 0 + (1:columns (z));
    y = transpose (coordinate_template * 0 + (1:rows (z)));
    options = {};
  else
    x = varargin{1};
    y = varargin{2};
    z = varargin{3};
    xi = varargin{4};
    yi = varargin{5};
    template = mp_interp2_find_template ({x, y, z, xi, yi});
    coordinate_template = real (template);
    x = mp_interp2_promote (x, coordinate_template);
    y = mp_interp2_promote (y, coordinate_template);
    z = mp_interp2_promote (z, template);
    options = varargin(6:end);
  endif

  if (nargin == 3)
    template = mp_interp_element (z, 1, 1);
    xi = mp_interp2_promote (xi, template);
    yi = mp_interp2_promote (yi, template);
  endif
  if (! isa (xi, "mp")), xi = template * 0 + xi; endif
  if (! isa (yi, "mp")), yi = template * 0 + yi; endif
  if (rows (z) == 0 || columns (z) == 0)
    error ("mplapack:interp:InvalidInput", "interp2 data must be nonempty");
  endif

  [x, y, z] = mp_interp2_axes (x, y, z, coordinate_template);
  method = "linear";
  extrapolate = false;
  extrapolation = [];
  if (numel (options) >= 1)
    if (! ischar (options{1}))
      extrapolation = options{1};
      extrapolate = true;
    else
      method = lower (options{1});
    endif
  endif
  if (numel (options) == 2)
    extrapolation = options{2};
    if (ischar (extrapolation) && strcmp (lower (extrapolation), "extrap"))
      extrapolation = [];
    endif
    extrapolate = true;
  endif
  if (! any (strcmp (method, {"nearest", "linear", "pchip", "spline"})))
    error ("mplapack:interp:InvalidMethod", "unsupported interp2 method");
  endif
  if (numel (xi) != numel (yi) && numel (xi) != 1 && numel (yi) != 1)
    error ("mplapack:interp:DimensionMismatch", ...
           "interp2 query grids must have matching shapes");
  endif
  output_rows = max (rows (xi), rows (yi));
  output_columns = max (columns (xi), columns (yi));
  if (numel (xi) == 1 && numel (yi) > 1)
    output_rows = rows (yi);
    output_columns = columns (yi);
  elseif (numel (yi) == 1 && numel (xi) > 1)
    output_rows = rows (xi);
    output_columns = columns (xi);
  endif

  zero = mp_interp_element (z, 1, 1) * 0;
  result = repmat (zero, output_rows, output_columns);
  for column = 1:output_columns
    for row = 1:output_rows
      qx = mp_interp2_query (xi, row, column);
      qy = mp_interp2_query (yi, row, column);
      outside = qx < mp_interp_element (x, 1) ...
                || qx > mp_interp_element (x, rows (x)) ...
                || qy < mp_interp_element (y, 1) ...
                || qy > mp_interp_element (y, rows (y));
      if (outside && ! extrapolate)
        value = zero + NaN;
      elseif (outside && extrapolate && ! isempty (extrapolation))
        if (isa (extrapolation, "mp"))
          value = extrapolation;
        else
          value = zero + extrapolation;
        endif
      elseif (strcmp (method, "nearest"))
        ix = mp_interp2_nearest_axis (x, qx);
        iy = mp_interp2_nearest_axis (y, qy);
        value = mp_interp_element (z, iy, ix);
      elseif (strcmp (method, "linear"))
        value = mp_interp2_linear_value (x, y, z, qx, qy);
      else
        value = mp_interp2_tensor_value (x, y, z, qx, qy, method);
      endif
      result = mp_interp_put (result, row, column, value);
    endfor
  endfor
endfunction

function template = mp_interp2_find_template (values)
  template = [];
  for index = 1:numel (values)
    if (isa (values{index}, "mp"))
      template = mp_interp_element (values{index}, 1);
      return;
    endif
  endfor
  error ("mplapack:interp:RequiresMp", "interp2 requires an mp grid or data value");
endfunction

function result = mp_interp2_promote (value, template)
  if (isa (value, "mp"))
    result = value;
  else
    result = template * 0 + value;
  endif
endfunction

function [x_out, y_out, z_out] = mp_interp2_axes (x, y, z, template)
  rows_z = rows (z);
  columns_z = columns (z);
  if (rows (x) == 1 || columns (x) == 1)
    if (numel (x) != columns_z)
      error ("mplapack:interp:DimensionMismatch", "x axis length does not match z");
    endif
    if (rows (x) == 1), x_out = transpose (x); else, x_out = x; endif
  elseif (rows (x) == rows_z && columns (x) == columns_z)
    x_out = repmat (template * 0, columns_z, 1);
    for column = 1:columns_z
      x_out = mp_interp_put (x_out, column, 1, mp_interp_element (x, 1, column));
    endfor
  else
    error ("mplapack:interp:DimensionMismatch", "x grid shape does not match z");
  endif

  if (rows (y) == 1 || columns (y) == 1)
    if (numel (y) != rows_z)
      error ("mplapack:interp:DimensionMismatch", "y axis length does not match z");
    endif
    if (rows (y) == 1), y_out = transpose (y); else, y_out = y; endif
  elseif (rows (y) == rows_z && columns (y) == columns_z)
    y_out = repmat (template * 0, rows_z, 1);
    for row = 1:rows_z
      y_out = mp_interp_put (y_out, row, 1, mp_interp_element (y, row, 1));
    endfor
  else
    error ("mplapack:interp:DimensionMismatch", "y grid shape does not match z");
  endif
  for index = 1:(rows (x_out) - 1)
    if (mp_interp_element (x_out, index + 1) == mp_interp_element (x_out, index))
      error ("mplapack:interp:RepeatedGrid", "x grid points must be distinct");
    endif
  endfor
  for index = 1:(rows (y_out) - 1)
    if (mp_interp_element (y_out, index + 1) == mp_interp_element (y_out, index))
      error ("mplapack:interp:RepeatedGrid", "y grid points must be distinct");
    endif
  endfor
  if (mp_interp_element (x_out, 2) < mp_interp_element (x_out, 1))
    x_out = flipud (x_out);
    z = fliplr (z);
  endif
  if (mp_interp_element (y_out, 2) < mp_interp_element (y_out, 1))
    y_out = flipud (y_out);
    z = flipud (z);
  endif
  z_out = z;
endfunction

function point = mp_interp2_query (value, row, column)
  if (numel (value) == 1)
    point = mp_interp_element (value, 1);
  else
    point = mp_interp_element (value, row, column);
  endif
endfunction

function index = mp_interp2_nearest_axis (axis, point)
  index = 1;
  best = abs (point - mp_interp_element (axis, 1));
  for candidate = 2:numel (axis)
    distance = abs (point - mp_interp_element (axis, candidate));
    if (distance < best)
      index = candidate;
      best = distance;
    endif
  endfor
endfunction

function value = mp_interp2_linear_value (x, y, z, qx, qy)
  ix = mp_interp2_piece (x, qx);
  iy = mp_interp2_piece (y, qy);
  x0 = mp_interp_element (x, ix);
  x1 = mp_interp_element (x, ix + 1);
  y0 = mp_interp_element (y, iy);
  y1 = mp_interp_element (y, iy + 1);
  tx = (qx - x0) / (x1 - x0);
  ty = (qy - y0) / (y1 - y0);
  z00 = mp_interp_element (z, iy, ix);
  z01 = mp_interp_element (z, iy, ix + 1);
  z10 = mp_interp_element (z, iy + 1, ix);
  z11 = mp_interp_element (z, iy + 1, ix + 1);
  value = (1 - ty) * ((1 - tx) * z00 + tx * z01) ...
          + ty * ((1 - tx) * z10 + tx * z11);
endfunction

function value = mp_interp2_tensor_value (x, y, z, qx, qy, method)
  intermediate = repmat (mp_interp_element (z, 1, 1) * 0, rows (y), 1);
  for row = 1:rows (y)
    row_values = repmat (mp_interp_element (z, 1, 1) * 0, rows (x), 1);
    for column = 1:rows (x)
      row_values = mp_interp_put (row_values, column, 1, ...
                                   mp_interp_element (z, row, column));
    endfor
    row_pp = mp_interp_make_pp (x, row_values, method);
    intermediate = mp_interp_put (intermediate, row, 1, ppval (row_pp, qx));
  endfor
  result_pp = mp_interp_make_pp (y, intermediate, method);
  value = ppval (result_pp, qy);
endfunction

function piece = mp_interp2_piece (axis, point)
  piece = numel (axis) - 1;
  if (point <= mp_interp_element (axis, 1)), piece = 1; return; endif
  for index = 1:(numel (axis) - 1)
    if (point <= mp_interp_element (axis, index + 1))
      piece = index;
      return;
    endif
  endfor
endfunction
