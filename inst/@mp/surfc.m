## SPDX-License-Identifier: BSD-2-Clause

function varargout = surfc (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("surfc", args{:});
  else
    [varargout{1:nargout}] = builtin ("surfc", args{:});
  endif
endfunction
