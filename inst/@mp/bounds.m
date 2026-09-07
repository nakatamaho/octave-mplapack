## SPDX-License-Identifier: BSD-2-Clause

function varargout = bounds (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "bounds expects an mp value");
  endif
  if (nargout > 2)
    error ("mplapack:mp:InvalidOutput", "bounds returns at most two outputs");
  endif
  [lower_payload, upper_payload] = __mplapack_core__ ("script_statistics", value, "bounds", varargin{:});
  varargout{1} = mp_statistic_result (lower_payload);
  if (nargout > 1)
    varargout{2} = mp_statistic_result (upper_payload);
  endif
endfunction
