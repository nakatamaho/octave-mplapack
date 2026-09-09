## SPDX-License-Identifier: BSD-2-Clause

function [template, dimensions] = mp_parse_like_constructor (arguments, kind)
  marker = 0;
  for k = 1:numel (arguments)
    if (ischar (arguments{k}) && strcmp (arguments{k}, "like"))
      marker = k;
      break;
    endif
  endfor
  if (marker == 0 || marker != numel (arguments) - 1
      || marker == 1 || ! isa (arguments{marker + 1}, "mp"))
    error ("mplapack:mp:InvalidArguments", ...
           "%s requires dimensions followed by \"like\" and an mp template", kind);
  endif
  template = arguments{marker + 1};
  dimensions = arguments(1:marker - 1);
endfunction
