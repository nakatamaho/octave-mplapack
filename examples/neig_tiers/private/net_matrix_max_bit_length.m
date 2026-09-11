% Maximum exact bit length for a matrix of integer MP values.
function answer = net_matrix_max_bit_length (matrix, bits)
  if (nargin != 2 || ! isa (matrix, "mp"))
    error ("mplapack:neigt:BitLength", "expected an MP matrix");
  endif
  answer = 0;
  for index = 1:numel (matrix)
    answer = max (answer, net_bit_length (matrix(index), bits));
  endfor
endfunction
