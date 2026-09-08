## SPDX-License-Identifier: BSD-2-Clause

function varargout = stairs (varargin)
  args = mp_graphics_args (varargin{:});
  if (nargout == 0)
    builtin ("stairs", args{:});
  else
    [varargout{1:nargout}] = builtin ("stairs", args{:});
  endif
endfunction
