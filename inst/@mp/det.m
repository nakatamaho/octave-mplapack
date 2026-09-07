## SPDX-License-Identifier: BSD-2-Clause

function result = det (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{d} =} det (@var{A})
  ## Compute a dense real or complex arbitrary-precision determinant through
  ## MPLAPACK Rgetrf or Cgetrf.  The determinant is formed at the stored
  ## operand precision from pivot parity and the U diagonal product; public
  ## inputs remain unchanged.  The optional reciprocal-condition output is
  ## deferred until the condition-number milestone.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "det expects one mp value");
  endif
  if (nargout > 1)
    error ("mplapack:mp:OutputCount", ...
           "mp det currently returns one output");
  endif

  payload = __mplapack_core__ ("det", value);
  result = mp (0);
  result.payload_ = payload;
endfunction
