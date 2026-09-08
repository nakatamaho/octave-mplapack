## SPDX-License-Identifier: BSD-2-Clause

function [x_out, y_out, template] = mp_interp_normalize (x, y, name)
  if (isa (x, "mp"))
    template = mp_interp_element (x, 1);
  elseif (isa (y, "mp"))
    template = mp_interp_element (y, 1);
  else
    error ("mplapack:interp:RequiresMp", ...
           "%s requires an mp grid or data value", name);
  endif

  if (! isa (x, "mp"))
    x = template * 0 + x;
  endif
  if (! isa (y, "mp"))
    y = template * 0 + y;
  endif
  if (! isnumeric (x) || ! isnumeric (y) || ! isreal (x)
      || numel (x) < 2 || numel (y) < 2)
    error ("mplapack:interp:InvalidInput", ...
           "%s requires numeric vectors with at least two points", name);
  endif
  if (rows (x) != 1 && columns (x) != 1)
    error ("mplapack:interp:InvalidInput", "%s grid must be a vector", name);
  endif
  if (rows (x) == 1)
    x = transpose (x);
  endif
  if (rows (y) == 1 && columns (y) == numel (x))
    y = transpose (y);
  endif
  if (rows (y) != numel (x))
    error ("mplapack:interp:DimensionMismatch", ...
           "%s grid and data lengths do not match", name);
  endif
  if (columns (y) != 1)
    error ("mplapack:interp:MatrixDataUnsupported", ...
           "%s currently supports one-dimensional data vectors", name);
  endif

  if (mp_interp_element (x, 2) < mp_interp_element (x, 1))
    x = flipud (x);
    y = flipud (y);
  endif
  for index = 1:(rows (x) - 1)
    if (mp_interp_element (x, index + 1) == mp_interp_element (x, index))
      error ("mplapack:interp:RepeatedGrid", ...
             "%s grid points must be distinct", name);
    endif
  endfor
  x_out = x;
  y_out = y;
endfunction
