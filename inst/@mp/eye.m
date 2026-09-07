## SPDX-License-Identifier: BSD-2-Clause

function result = eye (varargin)
  if (nargin < 2)
    error ("mplapack:mp:InvalidArguments", ...
           "eye requires dimensions, \"like\", and an mp template");
  endif
  [template, dimensions] = mp_parse_like_constructor (varargin, "eye");
  payload = __mplapack_core__ ("script_structure", "like", "eye", ...
                               template, dimensions{:});
  result = template;
  result.payload_ = payload;
endfunction
