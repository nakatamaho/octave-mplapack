## SPDX-License-Identifier: BSD-2-Clause

function result = svt_mix (value)
  ## Apply the fixed two-sided orthogonal equivalence H*B*G'/n.
  [h, g] = svt_hadamard (rows (value));
  if (rows (value) != columns (value) || rows (value) != rows (h))
    error ("mplapack:svt:InvalidMixShape", ...
           "Hadamard mixing requires a square matrix of matching order");
  endif
  result = (h * value * g') * (mp (1) / mp (rows (value)));
endfunction
