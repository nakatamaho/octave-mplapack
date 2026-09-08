## SPDX-License-Identifier: BSD-2-Clause

function varargout = stem (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("stem", args{:});
  else
    [varargout{1:nargout}] = builtin ("stem", args{:});
  endif
endfunction
