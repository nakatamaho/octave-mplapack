## SPDX-License-Identifier: BSD-2-Clause

function result = balance (value, varargin)
  ## @deftypefn {} {@var{AA} =} balance (@var{A})
  ## Balance a square arbitrary-precision matrix through MPLAPACK GEBAL.
  ## The optional "noperm"/"noscal" choices select scale-only or
  ## permutation-only balancing.  The public one-output form is provided;
  ## generalized pair balancing remains deliberately unsupported until a
  ## joint Ward-style MPFR/MPC path is available.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "balance expects one mp value and an optional option");
  endif
  if (nargout > 1)
    error ("mplapack:mp:OutputCount", ...
           "mp balance currently returns the balanced matrix only");
  endif
  option = "";
  if (nargin == 2)
    if (! ischar (varargin{1}) && ! isstring (varargin{1}))
      error ("mplapack:mp:InvalidOption", "balance option must be text");
    endif
    option = char (varargin{1});
  endif
  payload = __mplapack_core__ ("balance", value, option);
  result = mp (0);
  result.payload_ = payload;
endfunction
