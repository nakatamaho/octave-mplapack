## SPDX-License-Identifier: BSD-2-Clause

function varargout = scatter3 (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("scatter3", args{:});
  else
    [varargout{1:nargout}] = builtin ("scatter3", args{:});
  endif
endfunction
