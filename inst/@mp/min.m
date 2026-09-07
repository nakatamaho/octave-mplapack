## SPDX-License-Identifier: BSD-2-Clause

function varargout = min (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "min expects an mp value as the first operand");
  endif
  if (nargout > 2)
    error ("mplapack:mp:InvalidOutput", "min returns at most two outputs");
  endif
  if (nargout > 1)
    [payload, indices] = __mplapack_core__ ("script_extremum", value, "min", "value_index", varargin{:});
  else
    payload = __mplapack_core__ ("script_extremum", value, "min", "value", varargin{:});
  endif
  if (! isnumeric (payload))
    result = mp (0);
    result.payload_ = payload;
  else
    result = payload;
  endif
  varargout{1} = result;
  if (nargout > 1)
    varargout{2} = indices;
  endif
endfunction
