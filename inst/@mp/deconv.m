## SPDX-License-Identifier: BSD-2-Clause

function varargout = deconv (a, b)
  if (nargin != 2 || ! isa (a, "mp") || ! isa (b, "mp")), error ("mplapack:mp:InvalidInput", "deconv expects two mp vectors"); endif
  aa = a(:); bb = b(:);
  if (numel(bb) == 0 || mp_element (bb, 1) == 0), error ("mplapack:mp:InvalidInput", "deconv divisor must have a nonzero leading coefficient"); endif
  if (numel(aa) < numel(bb))
    q = zeros (1,1,"like",a); q = mp_put (q,1,1,mp(0));
    r = a;
  else
    q = zeros (numel(aa)-numel(bb)+1,1,"like",a);
    work = zeros (numel(aa),1,"like",a);
    for t = 1:numel(aa), work = mp_put (work,t,1,mp_element (aa,t)); endfor
    for k = 1:numel(q)
      q = mp_put (q,k,1,mp_element (work, k) / mp_element (bb, 1));
      for j = 1:numel(bb)
        work = mp_put (work,k+j-1,1,mp_element (work, k+j-1) - mp_element (q, k)*mp_element (bb, j));
      endfor
    endfor
    r = mp_slice (work,numel(q)+1:numel(aa),1);
  endif
  [m,n] = size(a); if (m == 1 && n != 1), q=q.'; r=r.'; endif
  varargout{1}=q; if (nargout>1), varargout{2}=r; endif
endfunction
