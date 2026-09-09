## SPDX-License-Identifier: BSD-2-Clause

function result = inv (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{B} =} inv (@var{A})
  ## Compute the dense real or complex arbitrary-precision inverse through
  ## MPLAPACK Rgetrf/Rgetri or Cgetrf/Cgetri.  Workspace is queried at the
  ## operation precision and the public input remains immutable.  Singular
  ## matrices and nonsquare matrices are reported explicitly.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "inv expects one mp value");
  endif
  if (nargout > 1)
    error ("mplapack:mp:OutputCount", ...
           "mp inv returns one output");
  endif

  payload = __mplapack_core__ ("inv", value);
  result = value;
  result.payload_ = payload;
endfunction
