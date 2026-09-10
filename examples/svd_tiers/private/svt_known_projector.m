## SPDX-License-Identifier: BSD-2-Clause

function projector = svt_known_projector (basis, indices)
  ## Form a model projector from exact columns of a Hadamard factor.
  if (! isa (basis, "mp") || rows (basis) != columns (basis))
    error ("mplapack:svt:InvalidProjectorBasis", ...
           "projector basis must be a square mp matrix");
  endif
  indices = indices(:).';
  if (isempty (indices))
    projector = mp (zeros (rows (basis), rows (basis)));
    return;
  endif
  if (any (indices < 1) || any (indices > columns (basis)) ...
      || any (indices != fix (indices)))
    error ("mplapack:svt:InvalidProjectorIndices", ...
           "projector indices are outside the basis");
  endif
  projector = basis(:, indices) * basis(:, indices)' ...
              * (mp (1) / mp (rows (basis)));
endfunction
