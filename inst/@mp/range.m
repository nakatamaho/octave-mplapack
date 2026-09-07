## SPDX-License-Identifier: BSD-2-Clause

function result = range (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "range expects an mp value");
  endif
  if (nargout > 1)
    error ("mplapack:mp:InvalidOutput", "range returns one output");
  endif
  payload = __mplapack_core__ ("script_statistics", value, "range", varargin{:});
  result = mp_statistic_result (payload);
endfunction
