## SPDX-License-Identifier: BSD-2-Clause

function result = ones (varargin)
  if (nargin < 2)
    error ("mplapack:mp:InvalidArguments", ...
           "ones requires dimensions, \"like\", and an mp template");
  endif
  [template, dimensions] = mp_parse_like_constructor (varargin, "ones");
  payload = __mplapack_core__ ("script_structure", "like", "ones", ...
                               template, dimensions{:});
  result = template;
  result.payload_ = payload;
endfunction
