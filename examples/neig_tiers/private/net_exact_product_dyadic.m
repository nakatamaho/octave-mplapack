% Independent exact dyadic matrix product checker.
% Each term is placed on a common power-of-two denominator before summation.
function [product, metadata] = net_exact_product_dyadic (left, right, bits)
  if (nargin != 3 || ! isa (left, "mp") || ! isa (right, "mp") ...
      || columns (left) != rows (right) || ! isnumeric (bits) ...
      || ! isscalar (bits) || bits != fix (bits) || bits < 1)
    error ("mplapack:neigt:ExactProduct", "invalid exact product arguments");
  endif
  m = rows (left);
  n = columns (right);
  terms = columns (left);
  left_parts = cell (rows (left), columns (left));
  right_parts = cell (rows (right), columns (right));
  minimum_exponent = 0;
  have_term = false;
  for i = 1:rows (left)
    for k = 1:columns (left)
      part = net_dyadic_decompose (left(i, k), bits);
      left_parts{i, k} = part;
    endfor
  endfor
  for k = 1:rows (right)
    for j = 1:columns (right)
      part = net_dyadic_decompose (right(k, j), bits);
      right_parts{k, j} = part;
    endfor
  endfor
  for i = 1:m
    for j = 1:n
      for k = 1:terms
        lp = left_parts{i, k};
        rp = right_parts{k, j};
        if (! lp.zero && ! rp.zero)
          e = lp.exponent + rp.exponent;
          if (! have_term || e < minimum_exponent)
            minimum_exponent = e;
            have_term = true;
          endif
        endif
      endfor
    endfor
  endfor
  if (! have_term)
    check_bits = max (64, bits);
  else
    check_bits = max (64, 2 * bits + net_ceil_log2_integer (max (1, terms)) + 8);
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (check_bits);
    product = mp (zeros (m, n));
    for i = 1:m
      for j = 1:n
        accumulator = mp (0);
        for k = 1:terms
          lp = left_parts{i, k};
          rp = right_parts{k, j};
          if (! lp.zero && ! rp.zero)
            coefficient = lp.coefficient * rp.coefficient;
            shift = lp.exponent + rp.exponent - minimum_exponent;
            accumulator = accumulator + coefficient * net_pow2 (shift, check_bits);
          endif
        endfor
        product(i, j) = accumulator * net_pow2 (minimum_exponent, check_bits);
      endfor
    endfor
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
  metadata = struct ("exact", true, "minimum_exponent", minimum_exponent, ...
                     "check_bits", check_bits, "terms", terms, ...
                     "method", "common_dyadic_denominator_v1");
endfunction
