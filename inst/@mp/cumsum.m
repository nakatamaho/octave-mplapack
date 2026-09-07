## SPDX-License-Identifier: BSD-2-Clause

function varargout = cumsum (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "cumsum expects an mp value");
  endif
  if (nargout > 1)
    error ("mplapack:mp:InvalidOutput", "cumsum returns one output");
  endif
  payload = __mplapack_core__ ("script_reduce", value, "cumsum", varargin{:});
  if (! isnumeric (payload))
    result = mp (0);
    result.payload_ = payload;
  else
    result = payload;
  endif
  varargout{1} = result;
endfunction
