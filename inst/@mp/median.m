## SPDX-License-Identifier: BSD-2-Clause

function result = median (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "median expects an mp value");
  endif
  if (nargout > 1)
    error ("mplapack:mp:InvalidOutput", "median returns one output");
  endif
  payload = __mplapack_core__ ("script_statistics", value, "median", varargin{:});
  result = mp_statistic_result (payload);
endfunction
