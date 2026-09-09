## SPDX-License-Identifier: BSD-2-Clause
## -*- texinfo -*-
## @deftypefn {} {@var{result} =} unmkpp (@dots{})
## Decompose a supported arbitrary-precision piecewise-polynomial form into its components.
## The operation follows the stored-precision and @code{mpbits} contract;
## it does not silently fall back to builtin binary64 arithmetic. See the
## user manual for supported forms, real/complex behavior, and limitations.
## @seealso{mp, mpbits, mpdigits}
## @end deftypefn

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
