% Explicit interval matrix multiplication; each scalar endpoint operation is
% still rounded and widened independently.  The row-vector batching only
% reduces Octave interpreter overhead; it is not a replacement by GEMM.
function result = net_iv_cmatrix_mul (left, right, q)
  net_iv_q (q);
  require_matrix (left, right);
  if (columns (left.rl) != rows (right.rl))
    error ("mplapack:neigt:MatrixInterval", "incompatible interval matrices");
  endif
  m = rows (left.rl);
  n = columns (right.rl);
  inner = columns (left.rl);
  result = zero_matrix (m, n);
  for i = 1:m
    sum_rl = mp (zeros (1, n));
    sum_rh = mp (zeros (1, n));
    sum_il = mp (zeros (1, n));
    sum_ih = mp (zeros (1, n));
    for k = 1:inner
      [real_product_lo, real_product_hi] = complex_product_real_row ...
        (component (left.rl, i, k), component (left.rh, i, k), ...
         component (left.il, i, k), component (left.ih, i, k), ...
         row_component (right.rl, k), row_component (right.rh, k), ...
         row_component (right.il, k), row_component (right.ih, k), q);
      [imag_product_lo, imag_product_hi] = complex_product_imag_row ...
        (component (left.rl, i, k), component (left.rh, i, k), ...
         component (left.il, i, k), component (left.ih, i, k), ...
         row_component (right.rl, k), row_component (right.rh, k), ...
         row_component (right.il, k), row_component (right.ih, k), q);
      [sum_rl, sum_rh] = interval_add_row ...
        (sum_rl, sum_rh, real_product_lo, real_product_hi, q);
      [sum_il, sum_ih] = interval_add_row ...
        (sum_il, sum_ih, imag_product_lo, imag_product_hi, q);
    endfor
    if (m == 1 && n == 1)
      result.rl = sum_rl;
      result.rh = sum_rh;
      result.il = sum_il;
      result.ih = sum_ih;
    else
      result.rl(i,:) = sum_rl;
      result.rh(i,:) = sum_rh;
      result.il(i,:) = sum_il;
      result.ih(i,:) = sum_ih;
    endif
  endfor
endfunction

function result = component (value, i, j)
  if (isscalar (value))
    result = value;
  else
    result = value(i,j);
  endif
endfunction

function result = row_component (value, i)
  if (isscalar (value))
    result = value;
  else
    result = value(i,:);
  endif
endfunction

function [lo, hi] = complex_product_real_row (arl, arh, ail, aih, ...
                                               brl, brh, bil, bih, q)
  [p1l, p1h] = interval_mul_row (arl, arh, brl, brh, q);
  [p2l, p2h] = interval_mul_row (ail, aih, bil, bih, q);
  [lo, hi] = interval_sub_row (p1l, p1h, p2l, p2h, q);
endfunction

function [lo, hi] = complex_product_imag_row (arl, arh, ail, aih, ...
                                               brl, brh, bil, bih, q)
  [p1l, p1h] = interval_mul_row (arl, arh, bil, bih, q);
  [p2l, p2h] = interval_mul_row (ail, aih, brl, brh, q);
  [lo, hi] = interval_add_row (p1l, p1h, p2l, p2h, q);
endfunction

function [lo, hi] = interval_mul_row (al, ah, bl, bh, q)
  [p11l, p11h] = array_primitive ("mul", al, bl, q);
  [p12l, p12h] = array_primitive ("mul", al, bh, q);
  [p21l, p21h] = array_primitive ("mul", ah, bl, q);
  [p22l, p22h] = array_primitive ("mul", ah, bh, q);
  lo = elementwise_min (elementwise_min (p11l, p12l), ...
                        elementwise_min (p21l, p22l));
  hi = elementwise_max (elementwise_max (p11h, p12h), ...
                        elementwise_max (p21h, p22h));
endfunction

function [lo, hi] = interval_add_row (al, ah, bl, bh, q)
  [lo, unused] = array_primitive ("add", al, bl, q);
  [unused, hi] = array_primitive ("add", ah, bh, q);
endfunction

function [lo, hi] = interval_sub_row (al, ah, bl, bh, q)
  [lo, unused] = array_primitive ("sub", al, bh, q);
  [unused, hi] = array_primitive ("sub", ah, bl, q);
endfunction

% Vectorized independent scalar primitives.  Every element uses the same
% net_iv_round enclosure as the scalar path, with an exact zero witness.
function [lo, hi] = array_primitive (operation, x, y, q)
  net_iv_q (q);
  if (mpbits () != q || ! isa (x, "mp") || ! all (all (isfinite (x))))
    error ("mplapack:neigt:IntervalPrimitive", "invalid array primitive input");
  endif
  operation = char (operation);
  switch (operation)
    case "add"
      rounded = x + y;
      zero_witness = (x == -y);
    case "sub"
      rounded = x - y;
      zero_witness = (x == y);
    case "mul"
      rounded = x .* y;
      zero_witness = (x == 0 | y == 0);
    otherwise
      error ("mplapack:neigt:IntervalPrimitive", ...
             "unsupported batched operation %s", operation);
  endswitch
  [lo, hi] = array_round (rounded, q, zero_witness, operation);
endfunction

function [lo, hi] = array_round (rounded, q, zero_witness, operation)
  persistent cached_q cached_lower_limit cached_upper_limit cached_unit;
  if (! isa (rounded, "mp") || ! all (all (isfinite (rounded))) ...
      || ! isequal (size (rounded), size (zero_witness)))
    error ("mplapack:neigt:IntervalRange", "invalid batched primitive result");
  endif
  % The public mp type deliberately rejects indexing a scalar object.  Use
  % the audited scalar implementation for the 1-by-1 row case; larger rows
  % take the genuinely batched path below.
  if (isscalar (rounded))
    scalar_box = net_iv_round (rounded, q, zero_witness, operation);
    lo = scalar_box.lo;
    hi = scalar_box.hi;
    return;
  endif
  if (any (rounded(:) == 0 & ! zero_witness(:)))
    error ("mplapack:neigt:IntervalRange", ...
           "unwitnessed zero in batched primitive %s", operation);
  endif
  if (any (zero_witness(:) & rounded(:) != 0))
    error ("mplapack:neigt:IntervalRange", ...
           "inconsistent zero witness in batched primitive %s", operation);
  endif
  if (isempty (cached_q) || cached_q != q)
    cached_q = q;
    cached_lower_limit = net_pow2 (-8192, q);
    cached_upper_limit = net_pow2 (8192, q);
    cached_unit = net_pow2 (-q, q);
  endif
  magnitude = abs (rounded);
  nonzero = ! zero_witness;
  if (any (nonzero(:) & (magnitude(:) < cached_lower_limit ...
                         | magnitude(:) > cached_upper_limit)))
    error ("mplapack:neigt:IntervalRange", ...
           "batched primitive result is outside the verified range for %s", ...
           operation);
  endif
  lo = rounded;
  hi = rounded;
  if (any (nonzero(:)))
    margin = mp (8) .* cached_unit .* magnitude;
    lo(nonzero) = rounded(nonzero) - margin(nonzero);
    hi(nonzero) = rounded(nonzero) + margin(nonzero);
    if (any (! isfinite (lo(nonzero))) || any (! isfinite (hi(nonzero))) ...
        || any (lo(nonzero) > hi(nonzero)))
      error ("mplapack:neigt:IntervalRange", ...
             "batched endpoint construction failed for %s", operation);
    endif
  endif
endfunction

function value = elementwise_min (left, right)
  if (isscalar (left))
    if (right < left)
      value = right;
    else
      value = left;
    endif
    return;
  endif
  value = left;
  for index = 1:numel (left)
    if (right(index) < left(index))
      value(index) = right(index);
    endif
  endfor
endfunction

function value = elementwise_max (left, right)
  if (isscalar (left))
    if (right > left)
      value = right;
    else
      value = left;
    endif
    return;
  endif
  value = left;
  for index = 1:numel (left)
    if (right(index) > left(index))
      value(index) = right(index);
    endif
  endfor
endfunction

function require_matrix (left, right)
  if (! valid_matrix (left) || ! valid_matrix (right))
    error ("mplapack:neigt:MatrixInterval", "invalid interval matrices");
  endif
endfunction

function value = valid_matrix (matrix)
  value = isstruct (matrix) && isfield (matrix, "kind") ...
    && strcmp (matrix.kind, "complex_matrix") && isfield (matrix, "rl") ...
    && isfield (matrix, "rh") && isfield (matrix, "il") && isfield (matrix, "ih") ...
    && isequal (size (matrix.rl), size (matrix.rh)) ...
    && isequal (size (matrix.rl), size (matrix.il)) ...
    && isequal (size (matrix.rl), size (matrix.ih));
endfunction

function result = zero_matrix (m, n)
  result = struct ("kind", "complex_matrix", ...
    "rl", mp (zeros (m,n)), "rh", mp (zeros (m,n)), ...
    "il", mp (zeros (m,n)), "ih", mp (zeros (m,n)));
endfunction
