## SPDX-License-Identifier: BSD-2-Clause

function varargout = std (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "std expects an mp value");
  endif
  if (nargout > 2)
    error ("mplapack:mp:InvalidOutput", "std returns at most two outputs");
  endif
  [payload, mean_payload] = __mplapack_core__ ("script_statistics", value, "std", varargin{:});
  varargout{1} = mp_statistic_result (payload);
  if (nargout > 1)
    varargout{2} = mp_statistic_result (mean_payload);
  endif
endfunction
