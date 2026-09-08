## SPDX-License-Identifier: BSD-2-Clause

function varargout = waterfall (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("waterfall", args{:});
  else
    [varargout{1:nargout}] = builtin ("waterfall", args{:});
  endif
endfunction
