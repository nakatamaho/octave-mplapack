% Explicit scalar-by-scalar RN_g matrix product.
function product = net_rounded_product (left, right, bits)
  if (nargin != 3 || ! isa (left, "mp") || ! isa (right, "mp") ...
      || columns (left) != rows (right))
    error ("mplapack:neigt:RoundedProduct", "invalid rounded product arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    product = mp (zeros (rows (left), columns (right)));
    for i = 1:rows (left)
      for j = 1:columns (right)
        accumulator = mp (0);
        for k = 1:columns (left)
          term = left(i, k) * right(k, j);
          accumulator = accumulator + term;
        endfor
        product(i, j) = accumulator + mp (0);
      endfor
    endfor
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
