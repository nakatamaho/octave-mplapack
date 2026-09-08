## SPDX-License-Identifier: BSD-2-Clause

function varargout = plot3 (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("plot3", args{:});
  else
    [varargout{1:nargout}] = builtin ("plot3", args{:});
  endif
endfunction
