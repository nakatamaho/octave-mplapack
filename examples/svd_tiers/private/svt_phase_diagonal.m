## SPDX-License-Identifier: BSD-2-Clause

function diagonal = svt_phase_diagonal (n)
  ## Exact quarter-turn diagonal phases [1,i,-1,-i,...].
  if (! isnumeric (n) || ! isscalar (n) || n != fix (n) || n < 1)
    error ("mplapack:svt:InvalidPhaseSize", "phase size must be positive");
  endif
  diagonal = mp (complex (zeros (n, n), zeros (n, n)));
  phases = cell (1, 4);
  phases{1} = mp ('1', '0');
  phases{2} = mp ('0', '1');
  phases{3} = mp ('-1', '0');
  phases{4} = mp ('0', '-1');
  for index = 1:n
    diagonal(index, index) = phases{mod (index - 1, 4) + 1};
  endfor
endfunction
