## SPDX-License-Identifier: BSD-2-Clause

function result = properties (value)
  ## The native payload is an implementation detail and is not a public
  ## property of an mp value.
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "properties expects one mp value");
  endif
  result = cell (0, 1);
endfunction
