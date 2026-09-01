## SPDX-License-Identifier: BSD-2-Clause

function result = vertcat (varargin)
  error ("mplapack:mp:MatrixUnsupported", ...
         "arrays of scalar mp wrappers are forbidden; use the native matrix constructor");
endfunction
