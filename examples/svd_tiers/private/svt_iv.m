## SPDX-License-Identifier: BSD-2-Clause

function result = svt_iv (operation, varargin)
  ## Private real-interval/complex-rectangle arithmetic for Tier V.
  ## Every nonzero real primitive is enclosed before it is propagated.
  switch (operation)
    case "point"
      result = iv_point (varargin{1}, varargin{2});
    case "primitive"
      result = iv_primitive (varargin{1}, varargin{2}, varargin{3});
    case "add"
      result = iv_add (varargin{1}, varargin{2});
    case "sub"
      result = iv_sub (varargin{1}, varargin{2});
    case "mul"
      result = iv_mul (varargin{1}, varargin{2});
    case "div"
      result = iv_div (varargin{1}, varargin{2});
    case "square"
      result = iv_square (varargin{1});
    case "sqrt"
      result = iv_sqrt (varargin{1});
    case "neg"
      result = iv_neg (varargin{1});
    case "conj"
      result = iv_conj (varargin{1});
    case "matrix_point"
      result = matrix_point (varargin{1}, varargin{2});
    case "matrix_get"
      result = matrix_get (varargin{1}, varargin{2}, varargin{3});
    case "matrix_set"
      result = matrix_set (varargin{1}, varargin{2}, varargin{3}, varargin{4});
    case "matrix_add"
      result = matrix_binary (varargin{1}, varargin{2}, "add");
    case "matrix_sub"
      result = matrix_binary (varargin{1}, varargin{2}, "sub");
    case "matrix_mul"
      result = matrix_mul (varargin{1}, varargin{2});
    case "matrix_transpose"
      result = matrix_transpose (varargin{1});
    case "matrix_ctranspose"
      result = matrix_ctranspose (varargin{1});
    case "matrix_fro_upper"
      result = matrix_fro_upper (varargin{1});
    case "matrix_column_lower"
      result = matrix_column_lower (varargin{1});
    otherwise
      error ("mplapack:svt:IntervalOperation", "unknown interval operation: %s", operation);
  endswitch
endfunction

function result = iv_point (value, q)
  require_q (q);
  if (! isa (value, "mp") || ! isscalar (value))
    error ("mplapack:svt:IntervalPoint", "interval points require mp scalars");
  endif
  value = svt_widen (value, q);
  if (isreal (value))
    result = real_interval (value, value, q);
  else
    result = complex_interval (real_interval (real (value), real (value), q), ...
                               real_interval (imag (value), imag (value), q));
  endif
endfunction

function result = iv_primitive (value, exact_zero, q)
  require_q (q);
  if (! isa (value, "mp") || ! isscalar (value) || ! isreal (value) ...
      || ! islogical (exact_zero) || ! isscalar (exact_zero))
    error ("mplapack:svt:IntervalPrimitive", "invalid audited real primitive");
  endif
  if (! isfinite (value))
    error ("mplapack:svt:ContractNonfinite", "audited primitive produced nonfinite data");
  endif
  zero = mp (0);
  if (value == zero)
    if (! exact_zero)
      error ("mplapack:svt:ContractUnexpectedZero", ...
             "nonzero exact primitive rounded to an unexplained zero");
    endif
    result = real_interval (zero, zero, q);
    return;
  endif
  magnitude = abs (value);
  if (magnitude < svt_pow2 (-8192) || magnitude > svt_pow2 (8192))
    error ("mplapack:svt:ContractPrimitiveRange", ...
           "audited primitive is outside the declared range");
  endif
  ## 8*2^-q is one exact power-of-two scaling of the stored MPFR result.
  padding = magnitude * svt_pow2 (3 - q);
  if (padding == zero)
    error ("mplapack:svt:ContractZeroPadding", "outward padding became zero");
  endif
  lower = value - padding;
  upper = value + padding;
  if (lower > upper || ! isfinite (lower) || ! isfinite (upper))
    error ("mplapack:svt:ContractEndpoint", "invalid outward primitive endpoints");
  endif
  result = real_interval (lower, upper, q);
endfunction

function result = iv_add(a, b)
  require_same_kind(a, b);
  if (isfield (a, "kind") && strcmp (a.kind, "complex"))
    result = complex_interval (svt_iv ("add", a.real, b.real), ...
                               svt_iv ("add", a.imag, b.imag));
    return;
  endif
  q = a.q;
  lower = a.lo + b.lo;
  upper = a.hi + b.hi;
  result = real_interval_bounds (svt_iv ("primitive", lower, ...
                                         a.lo == -b.lo, q), ...
                                 svt_iv ("primitive", upper, ...
                                         a.hi == -b.hi, q));
endfunction

function result = iv_sub(a, b)
  require_same_kind(a, b);
  if (strcmp (a.kind, "complex"))
    result = complex_interval (svt_iv ("sub", a.real, b.real), ...
                               svt_iv ("sub", a.imag, b.imag));
    return;
  endif
  q = a.q;
  lower = a.lo - b.hi;
  upper = a.hi - b.lo;
  result = real_interval_bounds (svt_iv ("primitive", lower, ...
                                         a.lo == b.hi, q), ...
                                 svt_iv ("primitive", upper, ...
                                         a.hi == b.lo, q));
endfunction

function result = iv_mul(a, b)
  if (strcmp (a.kind, "complex") || strcmp (b.kind, "complex"))
    a = complexify (a);
    b = complexify (b);
    rr = svt_iv ("sub", svt_iv ("mul", a.real, b.real), ...
                 svt_iv ("mul", a.imag, b.imag));
    ii = svt_iv ("add", svt_iv ("mul", a.real, b.imag), ...
                 svt_iv ("mul", a.imag, b.real));
    result = complex_interval (rr, ii);
    return;
  endif
  require_same_kind(a, b);
  q = a.q;
  values = {a.lo * b.lo, a.lo * b.hi, a.hi * b.lo, a.hi * b.hi};
  exact = {a.lo == 0 || b.lo == 0, a.lo == 0 || b.hi == 0, ...
           a.hi == 0 || b.lo == 0, a.hi == 0 || b.hi == 0};
  candidates = cell (1, 4);
  for index = 1:4
    candidates{index} = svt_iv ("primitive", values{index}, exact{index}, q);
  endfor
  lower = candidates{1}.lo;
  upper = candidates{1}.hi;
  for index = 2:4
    if (candidates{index}.lo < lower), lower = candidates{index}.lo; endif
    if (candidates{index}.hi > upper), upper = candidates{index}.hi; endif
  endfor
  result = real_interval (lower, upper, q);
endfunction

function result = iv_div(a, b)
  if (strcmp (a.kind, "complex") || strcmp (b.kind, "complex"))
    error ("mplapack:svt:IntervalComplexDivision", ...
           "complex division is outside the rectangle baseline");
  endif
  require_same_kind(a, b);
  if (! (b.lo > mp (0) || b.hi < mp (0)))
    error ("mplapack:svt:IntervalZeroDenominator", ...
           "interval denominator crosses zero");
  endif
  q = a.q;
  values = {a.lo / b.lo, a.lo / b.hi, a.hi / b.lo, a.hi / b.hi};
  exact = {a.lo == 0, a.lo == 0, a.hi == 0, a.hi == 0};
  candidates = cell (1, 4);
  for index = 1:4
    candidates{index} = svt_iv ("primitive", values{index}, exact{index}, q);
  endfor
  lower = candidates{1}.lo;
  upper = candidates{1}.hi;
  for index = 2:4
    if (candidates{index}.lo < lower), lower = candidates{index}.lo; endif
    if (candidates{index}.hi > upper), upper = candidates{index}.hi; endif
  endfor
  result = real_interval (lower, upper, q);
endfunction

function result = iv_square(a)
  if (strcmp (a.kind, "complex"))
    error ("mplapack:svt:IntervalComplexSquare", "square expects a real interval");
  endif
  q = a.q;
  if (a.lo <= mp (0) && a.hi >= mp (0))
    lower = mp (0);
  else
    left = svt_iv ("mul", a, a);
    lower = left.lo;
  endif
  left = svt_iv ("mul", a, a);
  result = real_interval (lower, left.hi, q);
endfunction

function result = iv_sqrt(a)
  if (strcmp (a.kind, "complex") || a.lo < mp (0))
    error ("mplapack:svt:IntervalSqrtDomain", "sqrt interval is not nonnegative");
  endif
  q = a.q;
  lo_value = sqrt (a.lo);
  hi_value = sqrt (a.hi);
  result = real_interval_bounds (svt_iv ("primitive", lo_value, a.lo == 0, q), ...
                                 svt_iv ("primitive", hi_value, a.hi == 0, q));
endfunction

function result = iv_neg(a)
  if (strcmp (a.kind, "complex"))
    result = complex_interval (svt_iv ("neg", a.real), svt_iv ("neg", a.imag));
  else
    result = real_interval (-a.hi, -a.lo, a.q);
  endif
endfunction

function result = iv_conj(a)
  if (strcmp (a.kind, "complex"))
    result = complex_interval (a.real, svt_iv ("neg", a.imag));
  else
    result = a;
  endif
endfunction

function result = matrix_point(value, q)
  if (! isa (value, "mp") || ndims (value) != 2)
    error ("mplapack:svt:IntervalMatrixPoint", "matrix point requires a 2-D mp matrix");
  endif
  value = svt_widen (value, q);
  if (isreal (value))
    result = struct ("schema", "svt-interval-matrix-v1", "kind", "real", "q", q, ...
                     "lo", value, "hi", value);
  else
    result = struct ("schema", "svt-interval-matrix-v1", "kind", "complex", "q", q, ...
                     "real_lo", real (value), "real_hi", real (value), ...
                     "imag_lo", imag (value), "imag_hi", imag (value));
  endif
endfunction

function result = matrix_get(matrix, row, column)
  if (strcmp (matrix.kind, "real"))
    result = real_interval (matrix.lo(row, column), matrix.hi(row, column), matrix.q);
  else
    result = complex_interval (real_interval (matrix.real_lo(row, column), ...
                                              matrix.real_hi(row, column), matrix.q), ...
                               real_interval (matrix.imag_lo(row, column), ...
                                              matrix.imag_hi(row, column), matrix.q));
  endif
endfunction

function matrix = matrix_set(matrix, row, column, value)
  if (strcmp (matrix.kind, "real") && strcmp (value.kind, "real"))
    matrix.lo(row, column) = value.lo;
    matrix.hi(row, column) = value.hi;
  else
    if (strcmp (matrix.kind, "real"))
      matrix = promote_matrix_complex (matrix);
    endif
    value = complexify (value);
    matrix.real_lo(row, column) = value.real.lo;
    matrix.real_hi(row, column) = value.real.hi;
    matrix.imag_lo(row, column) = value.imag.lo;
    matrix.imag_hi(row, column) = value.imag.hi;
  endif
endfunction

function result = matrix_binary(a, b, operation)
  if (a.q != b.q), error ("mplapack:svt:IntervalPrecision", "matrix precisions differ"); endif
  [m, n] = matrix_shape(a);
  [mb, nb] = matrix_shape(b);
  if (m != mb || n != nb), error ("mplapack:svt:IntervalShape", "matrix shapes differ"); endif
  result = matrix_zero (a.q, m, n, strcmp (a.kind, "complex") || strcmp (b.kind, "complex"));
  for row = 1:m
    for column = 1:n
      result = matrix_set (result, row, column, svt_iv (operation, ...
                  svt_iv ("matrix_get", a, row, column), svt_iv ("matrix_get", b, row, column)));
    endfor
  endfor
endfunction

function result = matrix_mul(a, b)
  [m, k] = matrix_shape(a);
  [kb, n] = matrix_shape(b);
  if (k != kb), error ("mplapack:svt:IntervalShape", "matrix product shapes differ"); endif
  is_complex = strcmp (a.kind, "complex") || strcmp (b.kind, "complex");
  result = matrix_zero (a.q, m, n, is_complex);
  for row = 1:m
    for column = 1:n
      if (is_complex)
        sum_value = svt_iv ("point", mp ('0', '0'), a.q);
      else
        sum_value = svt_iv ("point", mp (0), a.q);
      endif
      for inner = 1:k
        sum_value = svt_iv ("add", sum_value, svt_iv ("mul", ...
                     svt_iv ("matrix_get", a, row, inner), ...
                     svt_iv ("matrix_get", b, inner, column)));
      endfor
      result = matrix_set (result, row, column, sum_value);
    endfor
  endfor
endfunction

function result = matrix_ctranspose(matrix)
  [m, n] = matrix_shape(matrix);
  result = matrix_zero (matrix.q, n, m, strcmp (matrix.kind, "complex"));
  for row = 1:m
    for column = 1:n
      result = matrix_set (result, column, row, svt_iv ("conj", ...
                     svt_iv ("matrix_get", matrix, row, column)));
    endfor
  endfor
endfunction

function result = matrix_transpose(matrix)
  [m, n] = matrix_shape(matrix);
  result = matrix_zero (matrix.q, n, m, strcmp (matrix.kind, "complex"));
  for row = 1:m
    for column = 1:n
      result = matrix_set (result, column, row, ...
                           svt_iv ("matrix_get", matrix, row, column));
    endfor
  endfor
endfunction

function result = matrix_fro_upper(matrix)
  [m, n] = matrix_shape(matrix);
  sum_value = svt_iv ("point", mp (0), matrix.q);
  for row = 1:m
    for column = 1:n
      value = svt_iv ("matrix_get", matrix, row, column);
      if (strcmp (value.kind, "complex"))
        sum_value = svt_iv ("add", sum_value, svt_iv ("square", value.real));
        sum_value = svt_iv ("add", sum_value, svt_iv ("square", value.imag));
      else
        sum_value = svt_iv ("add", sum_value, svt_iv ("square", value));
      endif
    endfor
  endfor
  result = svt_iv ("sqrt", sum_value);
endfunction

function result = matrix_column_lower(matrix)
  [m, n] = matrix_shape(matrix);
  result = mp (zeros (1, n));
  for column = 1:n
    sum_value = svt_iv ("point", mp (0), matrix.q);
    for row = 1:m
      value = svt_iv ("matrix_get", matrix, row, column);
      if (strcmp (value.kind, "complex"))
        sum_value = svt_iv ("add", sum_value, svt_iv ("square", value.real));
        sum_value = svt_iv ("add", sum_value, svt_iv ("square", value.imag));
      else
        sum_value = svt_iv ("add", sum_value, svt_iv ("square", value));
      endif
    endfor
    norm_interval = svt_iv ("sqrt", sum_value);
    result(column) = norm_interval.lo;
  endfor
endfunction

function result = real_interval(lo, hi, q)
  if (lo > hi), error ("mplapack:svt:IntervalOrder", "lower endpoint exceeds upper endpoint"); endif
  result = struct ("schema", "svt-interval-real-v1", "kind", "real", ...
                   "q", q, "lo", lo, "hi", hi);
endfunction

function result = real_interval_bounds(lower, upper)
  result = real_interval (lower.lo, upper.hi, lower.q);
endfunction

function result = complex_interval(real_part, imag_part)
  result = struct ("schema", "svt-interval-complex-v1", "kind", "complex", ...
                   "q", real_part.q, "real", real_part, "imag", imag_part);
endfunction

function result = complexify(value)
  if (strcmp (value.kind, "complex"))
    result = value;
  else
    result = complex_interval (value, real_interval (mp (0), mp (0), value.q));
  endif
endfunction

function require_same_kind(a, b)
  if (a.q != b.q || ! strcmp (a.kind, b.kind))
    error ("mplapack:svt:IntervalKind", "interval kinds or precisions differ");
  endif
endfunction

function require_q(q)
  if (mpbits () != q), error ("mplapack:svt:IntervalPrecision", ...
                              "ambient precision does not match interval q"); endif
endfunction

function [m, n] = matrix_shape(matrix)
  if (strcmp (matrix.kind, "real"))
    [m, n] = size (matrix.lo);
  else
    [m, n] = size (matrix.real_lo);
  endif
endfunction

function result = matrix_zero(q, m, n, is_complex)
  if (! is_complex)
    result = struct ("schema", "svt-interval-matrix-v1", "kind", "real", "q", q, ...
                     "lo", mp (zeros (m, n)), "hi", mp (zeros (m, n)));
  else
    result = struct ("schema", "svt-interval-matrix-v1", "kind", "complex", "q", q, ...
                     "real_lo", mp (zeros (m, n)), "real_hi", mp (zeros (m, n)), ...
                     "imag_lo", mp (zeros (m, n)), "imag_hi", mp (zeros (m, n)));
  endif
endfunction

function result = promote_matrix_complex(matrix)
  result = matrix_zero (matrix.q, size (matrix.lo, 1), size (matrix.lo, 2), true);
  result.real_lo = matrix.lo;
  result.real_hi = matrix.hi;
endfunction
