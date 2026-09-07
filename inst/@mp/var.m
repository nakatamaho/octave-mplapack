## SPDX-License-Identifier: BSD-2-Clause

function varargout = var (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "var expects an mp value");
  endif
  if (nargout > 2)
    error ("mplapack:mp:InvalidOutput", "var returns at most two outputs");
  endif
  [payload, mean_payload] = __mplapack_core__ ("script_statistics", value, "var", varargin{:});
  varargout{1} = mp_statistic_result (payload);
  if (nargout > 1)
    varargout{2} = mp_statistic_result (mean_payload);
  endif
endfunction
