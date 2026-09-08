## SPDX-License-Identifier: BSD-2-Clause

function varargout = polyder (value, varargin)
  if (nargin < 1 || nargin > 2 || ! isa (value,"mp"))
    error ("mplapack:mp:InvalidInput", "polyder expects one or two mp coefficient vectors");
  endif
  [m,nc] = size (value);
  if (m != 1 && nc != 1)
    error ("mplapack:mp:InvalidInput", "polyder expects a coefficient vector");
  endif
  if (nargin == 2)
    other = varargin{1};
    if (! isa (other, "mp")), other = mp (other); endif
    [om,on] = size (other);
    if (om != 1 && on != 1)
      error ("mplapack:mp:InvalidInput", "polyder expects a coefficient vector");
    endif
    if (nargout <= 1)
      varargout{1} = polyder (conv (value, other));
      return;
    endif
    ## [q,d] = polyder (b,a) is the derivative of b/a.
    ## Work in columns so a row/column mix cannot trigger implicit
    ## broadcasting in the element-wise subtraction.
    value_derivative = polyder (value);
    other_derivative = polyder (other);
    value_column = mp_column (value);
    other_column = mp_column (other);
    derivative_value_column = mp_column (value_derivative);
    derivative_other_column = mp_column (other_derivative);
    left = conv (derivative_value_column, other_column);
    right = conv (value_column, derivative_other_column);
    numerator = left - right;
    denominator = conv (other_column, other_column);
    ## Match Octave's normalized quotient derivative representation.
    leading = mp_element (denominator, 1);
    result = (numerator / leading).';
    varargout{1} = result;
    varargout{2} = (denominator / leading).';
    return;
  endif
  n = numel(value);
  if (n <= 1)
    result=zeros(1,1,"like",value); result=mp_put(result,1,1,mp(0));
    varargout{1} = result;
    return;
  endif
  result=zeros(n-1,1,"like",value);
  for k=1:n-1, result=mp_put(result,k,1,mp_element (value,k)*(n-k)); endfor
  if (m==1 && nc!=1), result=result.'; endif
  varargout{1} = result;
endfunction
