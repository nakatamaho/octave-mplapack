## SPDX-License-Identifier: BSD-2-Clause

function report = svt_v0_selftest ()
  ## SVT12 scalar-contract, interval, rectangle, matrix, and V4 gate.
  suite_dir = fileparts (mfilename ("fullpath"));
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), suite_dir)))
    addpath (suite_dir);
    added = true;
  endif
  cleanup_path = onCleanup (@() svt_restore_v0_path (suite_dir, added));
  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  for q = [64, 128, 256]
    contract = svt_v0_contract (q);
    assert (strcmp (contract.status, "AUDITED"));
    mpbits (q);
    one = mp (1);
    three = mp (3);
    one_third = one / three;
    encoded_third = svt_dyadic_encode (one_third, q);
    decoded_third = svt_dyadic_decode (encoded_third, q);
    assert (decoded_third == one_third);
  endfor
  mpbits (128);
  a = svt_iv ("point", mp (1), 128);
  b = svt_iv ("point", -mp (1), 128);
  cancellation = svt_iv ("add", a, b);
  assert (cancellation.lo == mp (0) && cancellation.hi == mp (0));
  addition = svt_iv ("add", a, svt_iv ("point", mp (2), 128));
  assert (addition.lo <= mp (3) && addition.hi >= mp (3));
  product = svt_iv ("mul", addition, svt_iv ("point", mp ('-2'), 128));
  assert (product.lo <= mp ('-6') && product.hi >= mp ('-6'));
  crossing = struct ("schema", "svt-interval-real-v1", "kind", "real", ...
                     "q", 128, "lo", mp ('-1'), "hi", mp ('2'));
  square = svt_iv ("square", crossing);
  assert (square.lo == mp (0) && square.hi >= mp (4));
  division_rejected = false;
  try
    svt_iv ("div", a, crossing);
  catch
    division_rejected = true;
  end_try_catch
  assert (division_rejected);
  sqrt_interval = svt_iv ("sqrt", svt_iv ("point", mp (4), 128));
  assert (sqrt_interval.lo <= mp (2) && sqrt_interval.hi >= mp (2));
  invalid_zero = false;
  try
    svt_iv ("primitive", mp (0), false, 128);
  catch
    invalid_zero = true;
  end_try_catch
  assert (invalid_zero);

  complex_a = mp ('1', '2');
  complex_b = mp ('3', '-1');
  complex_product = svt_iv ("mul", svt_iv ("point", complex_a, 128), ...
                            svt_iv ("point", complex_b, 128));
  assert (complex_product.real.lo <= mp ('5') && complex_product.real.hi >= mp ('5'));
  assert (complex_product.imag.lo <= mp ('5') && complex_product.imag.hi >= mp ('5'));
  complex_matrix = svt_iv ("matrix_point", mp ({'(1,2)', '(3,-1)'; '(0,1)', '(2,0)'}), 128);
  matrix_product = svt_iv ("matrix_mul", complex_matrix, ...
                           svt_iv ("matrix_ctranspose", complex_matrix));
  upper_norm = svt_iv ("matrix_fro_upper", matrix_product);
  assert (upper_norm.hi > mp (0));
  column_lower = svt_iv ("matrix_column_lower", complex_matrix);
  assert (all (column_lower > mp (0)));

  mpbits (256);
  values = cell (1, 5);
  values{1} = mp (1);
  values{2} = -mp (1);
  values{3} = mp (2) ^ (-600);
  values{4} = mp (2) ^ (600);
  values{5} = mp (1) / mp (3);
  for index = 1:numel (values)
    encoded = svt_dyadic_encode (values{index}, 256);
    decoded = svt_dyadic_decode (encoded, 256);
    assert (decoded == values{index});
    assert (encoded.sign == 0 || any (encoded.sign == [-1, 1]));
  endfor
  negative_zero = mp ('-0');
  encoded_zero = svt_dyadic_encode (negative_zero, 256);
  assert (encoded_zero.sign == 0 && encoded_zero.zero_signbit);
  assert (svt_dyadic_decode (encoded_zero, 256) == mp (0));
  complex_value = mp ('1', '-2');
  encoded_complex = svt_dyadic_complex_encode (complex_value, 256);
  decoded_complex = svt_dyadic_complex_decode (encoded_complex, 256);
  assert (decoded_complex == complex_value);
  insufficient = false;
  try
    svt_dyadic_decode (svt_dyadic_encode (mp (1) / mp (3), 256), 64);
  catch
    insufficient = true;
  end_try_catch
  assert (insufficient);
  assert (mpbits () == 256);
  report = struct ("ok", true, "contract_q64_256", true, ...
                   "interval_cancellation", true, "range_fail_closed", true, ...
                   "complex_rectangle", true, "matrix_bounds", true, ...
                   "dyadic_roundtrip", true, "signed_zero", true, ...
                   "status", "PASS");
  clear cleanup_precision;
  clear cleanup_path;
endfunction

function svt_restore_v0_path (suite_dir, added)
  if (added)
    rmpath (suite_dir);
  endif
endfunction
