## SPDX-License-Identifier: BSD-2-Clause

function varargout = unmkpp (pp)
  if (! isstruct (pp) || ! isscalar (pp) || ! isfield (pp, "form")
      || ! strcmp (pp.form, "pp"))
    error ("mplapack:interp:InvalidPP", "unmkpp expects an pp struct");
  endif
  if (nargout > 5)
    error ("mplapack:interp:InvalidOutput", "unmkpp returns at most five outputs");
  endif
  values = {pp.breaks, pp.coefs, pp.pieces, pp.order, pp.dim};
  for index = 1:nargout
    varargout{index} = values{index};
  endfor
endfunction
