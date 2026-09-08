## SPDX-License-Identifier: BSD-2-Clause

function varargout = hess (value)
  ## @deftypefn {} {@var{H} =} hess (@var{A})
  ## @deftypefnx {} {[@var{P}, @var{H}] =} hess (@var{A})
  ## Compute the arbitrary-precision Hessenberg decomposition using
  ## MPLAPACK GEHRD/ORGHR or GEHRD/UNGHR.  The two-output form satisfies
  ## P*H*P' = A (with conjugate transpose for complex values).
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "hess expects one mp value");
  endif
  if (nargout > 2)
    error ("mplapack:mp:OutputCount", "mp hess returns H or P,H");
  endif

  [p_payload, h_payload] = __mplapack_core__ ("hess", value);
  p = mp (0);
  p.payload_ = p_payload;
  h = mp (0);
  h.payload_ = h_payload;
  if (nargout <= 1)
    varargout{1} = h;
  else
    varargout{1} = p;
    varargout{2} = h;
  endif
endfunction
