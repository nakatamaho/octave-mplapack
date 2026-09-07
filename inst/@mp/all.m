## SPDX-License-Identifier: BSD-2-Clause

function result = all (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "all expects an mp value");
  endif
  result = __mplapack_core__ ("script_any_all", value, "all", varargin{:});
endfunction
