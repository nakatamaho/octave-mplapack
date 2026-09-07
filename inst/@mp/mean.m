## SPDX-License-Identifier: BSD-2-Clause

function result = mean (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "mean expects an mp value");
  endif
  if (nargout > 1)
    error ("mplapack:mp:InvalidOutput", "mean returns one output");
  endif
  payload = __mplapack_core__ ("script_statistics", value, "mean", varargin{:});
  result = mp_statistic_result (payload);
endfunction
