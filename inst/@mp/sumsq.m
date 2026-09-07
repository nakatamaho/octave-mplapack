## SPDX-License-Identifier: BSD-2-Clause

function varargout = sumsq (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "sumsq expects an mp value");
  endif
  if (nargout > 1)
    error ("mplapack:mp:InvalidOutput", "sumsq returns one output");
  endif
  payload = __mplapack_core__ ("script_reduce", value, "sumsq", varargin{:});
  if (! isnumeric (payload))
    result = mp (0);
    result.payload_ = payload;
  else
    result = payload;
  endif
  varargout{1} = result;
endfunction
