## SPDX-License-Identifier: BSD-2-Clause

function args = mp_graphics_args (varargin)
  ## Convert only mp data at the final graphics boundary.  Handles, strings,
  ## property values, and all other graphics arguments are kept unchanged.
  args = varargin;
  for k = 1:numel (args)
    if (isa (args{k}, "mp"))
      args{k} = double (args{k});
    endif
  endfor
endfunction
