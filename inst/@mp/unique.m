## SPDX-License-Identifier: BSD-2-Clause

function varargout = unique (value, varargin)
  ## Exact unique values for current two-dimensional mp semantics.
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "unique expects an mp value");
  endif
  stable = false;
  rows_mode = false;
  for k = 1:numel (varargin)
    if (ischar (varargin{k}) || isstring (varargin{k}))
      option = char (varargin{k});
      if (strcmp (option, "stable"))
        stable = true;
      elseif (strcmp (option, "rows"))
        rows_mode = true;
      elseif (! strcmp (option, "sorted"))
        error ("mplapack:mp:InvalidOption", "unsupported unique option");
      endif
    endif
  endfor
  if (rows_mode)
    [values, first, inverse] = mp_set_unique_rows (value, stable);
  else
    [values, first, inverse] = mp_set_unique (value, stable);
    [m,n] = size (value);
    if (m == 1 && n != 1)
      values = values.';
    endif
  endif
  varargout{1} = values;
  if (nargout > 1), varargout{2} = first; endif
  if (nargout > 2), varargout{3} = inverse; endif
endfunction
