## SPDX-License-Identifier: BSD-2-Clause

function varargout = scatter (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("scatter", args{:});
  else
    [varargout{1:nargout}] = builtin ("scatter", args{:});
  endif
endfunction
