## SPDX-License-Identifier: BSD-2-Clause

function result = any (value, varargin)
  if (nargin < 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "any expects an mp value");
  endif
  result = __mplapack_core__ ("script_any_all", value, "any", varargin{:});
endfunction
