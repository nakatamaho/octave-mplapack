## SPDX-License-Identifier: BSD-2-Clause

function varargout = det (value)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{d} =} det (@var{A})
  ## Compute a dense real or complex arbitrary-precision determinant through
  ## MPLAPACK Rgetrf or Cgetrf.  The determinant is formed at the stored
  ## operand precision from pivot parity and the U diagonal product; public
  ## inputs remain unchanged.  With two outputs, the second result is the
  ## MPFR/MPC 1-norm reciprocal-condition estimate.
  ## @end deftypefn
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "det expects one mp value");
  endif
  if (nargout > 2)
    error ("mplapack:mp:OutputCount", ...
           "mp det returns one or two outputs");
  endif

  if (nargout == 2)
    if (isempty (value))
      error ("mplapack:mp:OutputCount", ...
             "det of an empty matrix has one output");
    endif
    [det_payload, rcond_payload] = __mplapack_core__ ("det_rcond", value);
    det_result = mp (0);
    det_result.payload_ = det_payload;
    rcond_result = mp (0);
    rcond_result.payload_ = rcond_payload;
    varargout{1} = det_result;
    varargout{2} = rcond_result;
  else
    payload = __mplapack_core__ ("det", value);
    result = mp (0);
    result.payload_ = payload;
    varargout{1} = result;
  endif
endfunction
