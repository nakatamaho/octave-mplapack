## SPDX-License-Identifier: BSD-2-Clause

function varargout = rref (value, varargin)
  ## @deftypefn {} {@var{R} =} rref (@var{A})
  ## @deftypefnx {} {[@var{R},@var{k}] =} rref (@var{A}, @var{tol})
  ## Arbitrary-precision Gauss-Jordan reduction with scaled pivot selection.
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "rref expects an mp matrix and optional tolerance");
  endif
  [m,n] = size (value);
  R = value;
  if (nargin == 2)
    tol = varargin{1};
    if (isa (tol, "mp"))
      if (! isreal (tol) || ! isscalar (tol) || tol < 0)
        error ("mplapack:mp:InvalidTolerance", ...
               "rref tolerance must be a nonnegative real scalar");
      endif
    elseif (! isnumeric (tol) || islogical (tol) || ! isreal (tol)
            || ! isscalar (tol) || tol < 0)
      error ("mplapack:mp:InvalidTolerance", ...
             "rref tolerance must be a nonnegative real scalar");
    else
      tol = mp (tol);
    endif
  else
    ## Use a scale-aware unit roundoff derived from the source value.  eps()
    ## is evaluated by MPFR at p_op; no host binary64 epsilon participates.
    scale = mp (0);
    for j = 1:n
      for i = 1:m
        candidate = abs (mp_element (value,i,j));
        if (candidate > scale)
          scale = candidate;
        endif
      endfor
    endfor
    if (scale == 0)
      tol = mp (0);
    else
      tol = mp (max (m,n)) * scale * eps (scale);
    endif
  endif
  pivot_columns = [];
  row = 1;
  for column = 1:n
    if (row > m)
      break;
    endif
    pivot = row;
    best = abs (mp_element (R,row,column));
    for candidate = row+1:m
      candidate_value = abs (mp_element (R,candidate,column));
      if (candidate_value > best)
        best = candidate_value;
        pivot = candidate;
      endif
    endfor
    if (best <= tol)
      continue;
    endif
    if (pivot != row)
      for j = 1:n
        temporary = mp_element (R,row,j);
        debug_value = mp_element (R,pivot,j);
        R = mp_put (R,row,j,debug_value);
        R = mp_put (R,pivot,j,temporary);
      endfor
    endif
    pivot_value = mp_element (R,row,column);
    for j = 1:n
      current_value = mp_element (R,row,j);
      R = mp_put (R,row,j,current_value / pivot_value);
    endfor
    for i = 1:m
      if (i != row)
        factor = mp_element (R,i,column);
        if (factor != 0)
          for j = 1:n
            current_value = mp_element (R,i,j);
            R = mp_put (R,i,j,current_value - factor * mp_element (R,row,j));
          endfor
        endif
      endif
    endfor
    pivot_columns(end+1) = column;
    row = row + 1;
  endfor
  varargout{1} = R;
  if (nargout > 1)
    varargout{2} = pivot_columns;
  endif
endfunction
