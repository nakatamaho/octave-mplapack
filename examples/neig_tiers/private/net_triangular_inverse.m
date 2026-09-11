% Finite nilpotent series inverse of a unit triangular matrix.
function inverse = net_triangular_inverse (matrix, bits)
  if (nargin != 2 || ! isa (matrix, "mp") ...
      || rows (matrix) != columns (matrix))
    error ("mplapack:neigt:Inverse", "expected a square MP matrix");
  endif
  n = rows (matrix);
  identity = mp (eye (n));
  nilpotent = matrix - identity;
  term = identity;
  inverse = identity;
  for index = 1:(n - 1)
    term = -term * nilpotent;
    inverse = inverse + term;
  endfor
endfunction
