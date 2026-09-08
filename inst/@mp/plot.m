## SPDX-License-Identifier: BSD-2-Clause

function varargout = plot (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("plot", args{:});
  else
    [varargout{1:nargout}] = builtin ("plot", args{:});
  endif
endfunction
