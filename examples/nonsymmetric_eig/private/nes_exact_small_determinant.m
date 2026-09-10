% Exact small determinant for independent Frank polynomial checks.
function determinant = nes_exact_small_determinant (matrix)
  n = rows (matrix);
  if (n > 5 || n != columns (matrix))
    error ("NEIG:FrankDeterminant", "exact determinant helper is limited to square n<=5");
  endif
  determinant = mp ("0");
  permutations = perms (1:n);
  for row = 1:rows (permutations)
    product = mp ("1");
    inversions = 0;
    for i = 1:n
      product = product * matrix(i, permutations(row, i));
      if (i < n)
        for j = (i + 1):n
          inversions += permutations(row, i) > permutations(row, j);
        endfor
      endif
    endfor
    if (mod (inversions, 2) == 1)
      determinant = determinant - product;
    else
      determinant = determinant + product;
    endif
  endfor
endfunction
