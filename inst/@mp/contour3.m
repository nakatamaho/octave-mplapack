## SPDX-License-Identifier: BSD-2-Clause

function varargout = contour3 (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("contour3", args{:});
  else
    [varargout{1:nargout}] = builtin ("contour3", args{:});
  endif
endfunction
