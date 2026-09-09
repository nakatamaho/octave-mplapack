## SPDX-License-Identifier: BSD-2-Clause

## -*- texinfo -*-
## @deftypefn {} {@var{result} =} kron (@var{A}, @var{B})
## Compute a two-dimensional arbitrary-precision Kronecker product. Inputs
## are promoted to one native @code{mp} precision without binary64 fallback.
## @seealso{mp, mtimes, mpbits}
## @end deftypefn

function result = kron (a, b)
  ## Compute a two-dimensional arbitrary-precision Kronecker product.
  if (nargin != 2 || ! isa (a, "mp"))
    error ("mplapack:mp:InvalidInput", "kron requires an mp first operand");
  endif
  if (! isa (b, "mp"))
    b = mp (b);
  endif
  [ma,na] = size (a);
  [mb,nb] = size (b);
  template = a;
  if (! isreal (b))
    template = b;
  endif
  result = zeros (ma*mb, na*nb, "like", template);
  for ja = 1:na
    for ia = 1:ma
      for jb = 1:nb
        for ib = 1:mb
          result = mp_put (result, (ia-1)*mb+ib, (ja-1)*nb+jb, ...
                           mp_element (a,ia,ja) * mp_element (b,ib,jb));
        endfor
      endfor
    endfor
  endfor
endfunction
