% Conservative exact-product guard for bounded integer matrices.
function guard = net_product_guard (left, right, bits)
  if (nargin != 3 || ! isa (left, "mp") || ! isa (right, "mp") ...
      || columns (left) != rows (right))
    error ("mplapack:neigt:Guard", "incompatible product operands");
  endif
  left_bits = net_matrix_max_bit_length (left, bits);
  right_bits = net_matrix_max_bit_length (right, bits);
  terms = columns (left);
  guard = left_bits + right_bits + net_ceil_log2_integer (max (1, terms)) + 4;
  guard = max (guard, 64);
endfunction
