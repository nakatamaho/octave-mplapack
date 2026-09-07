## SPDX-License-Identifier: BSD-2-Clause

function result = Inf (varargin)
  if (nargin < 2)
    error ("mplapack:mp:InvalidArguments", ...
           "Inf requires dimensions, \"like\", and an mp template");
  endif
  [template, dimensions] = mp_parse_like_constructor (varargin, "Inf");
  payload = __mplapack_core__ ("script_structure", "like", "inf", ...
                               template, dimensions{:});
  result = template;
  result.payload_ = payload;
endfunction
