## SPDX-License-Identifier: BSD-2-Clause

function result = NaN (varargin)
  if (nargin < 2)
    error ("mplapack:mp:InvalidArguments", ...
           "NaN requires dimensions, \"like\", and an mp template");
  endif
  [template, dimensions] = mp_parse_like_constructor (varargin, "NaN");
  payload = __mplapack_core__ ("script_structure", "like", "nan", ...
                               template, dimensions{:});
  result = template;
  result.payload_ = payload;
endfunction
