## SPDX-License-Identifier: BSD-2-Clause

%!function assert_complex_matrix (value, rows_expected, columns_expected, precision_expected)
%!  info = __mplapack_core__ ("matrix_test_info", value);
%!  assert (info.rows, uint64 (rows_expected));
%!  assert (info.columns, uint64 (columns_expected));
%!  assert (info.is_complex);
%!  assert (info.all_elements_same_precision);
%!  assert (info.precision_bits, uint64 (precision_expected));
%!endfunction

%!function assert_real_matrix (value, rows_expected, columns_expected, precision_expected)
%!  info = __mplapack_core__ ("matrix_test_info", value);
%!  assert (info.rows, uint64 (rows_expected));
%!  assert (info.columns, uint64 (columns_expected));
%!  assert (! info.is_complex);
%!  assert (info.all_elements_same_precision);
%!  assert (info.precision_bits, uint64 (precision_expected));
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   real_value = mp ([1, 2; 3, 4]);
%!   mpbits (1024);
%!   complex_value = mp ([1 + 2i, 5 - 1i; 7 + 0i, 11 + 3i]);
%!   mpbits (128);
%!   sum_value = real_value + complex_value;
%!   difference = complex_value - real_value;
%!   product = real_value .* complex_value;
%!   quotient = complex_value ./ real_value;
%!   assert_complex_matrix (sum_value, 2, 2, 1024);
%!   assert_complex_matrix (difference, 2, 2, 1024);
%!   assert_complex_matrix (product, 2, 2, 1024);
%!   assert_complex_matrix (quotient, 2, 2, 1024);
%!   assert (double (sum_value), double (real_value) + double (complex_value), 1e-12);
%!   assert (double (difference), double (complex_value) - double (real_value), 1e-12);
%!   assert (double (product), double (real_value) .* double (complex_value), 1e-12);
%!   assert (double (quotient), double (complex_value) ./ double (real_value), 1e-12);
%!   real_only = real_value + mp ([5, 6; 7, 8]);
%!   assert_real_matrix (real_only, 2, 2, 256);
%!   no_demotion = mp ("1", "0") + mp ("2");
%!   assert (__mplapack_core__ ("scalar_test_info", no_demotion).is_complex);
%!   assert (__mplapack_core__ ("scalar_test_info", -no_demotion).is_complex);
%!   assert (__mplapack_core__ ("scalar_test_info", +no_demotion).is_complex);
%!   builtin_mixed = real_value + [10 + 1i, 20 - 2i; 30 + 3i, 40 - 4i];
%!   assert_complex_matrix (builtin_mixed, 2, 2, 256);
%!   assert (double (builtin_mixed), double (real_value) + ...
%!           [10 + 1i, 20 - 2i; 30 + 3i, 40 - 4i], 1e-12);
%!   assert (__mplapack_core__ ("precision_get_bits"), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   real_matrix = mp ([1, 2; 3, 4]);
%!   complex_matrix = mp ([2 + 1i, 0 - 1i; 1 + 2i, 3 + 0i]);
%!   left_product = real_matrix * complex_matrix;
%!   right_product = complex_matrix * real_matrix;
%!   builtin_right = real_matrix * [2 + 1i, 0 - 1i; 1 + 2i, 3 + 0i];
%!   assert_complex_matrix (left_product, 2, 2, 512);
%!   assert_complex_matrix (right_product, 2, 2, 512);
%!   assert_complex_matrix (builtin_right, 2, 2, 512);
%!   assert (double (left_product), double (real_matrix) * double (complex_matrix), 1e-12);
%!   assert (double (right_product), double (complex_matrix) * double (real_matrix), 1e-12);
%!   assert (double (builtin_right), double (real_matrix) * ...
%!           [2 + 1i, 0 - 1i; 1 + 2i, 3 + 0i], 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   coefficient = mp ([3, 1; 1, 2]);
%!   real_rhs = mp ([7; 4]);
%!   complex_rhs = mp ([7 + 1i; 4 - 2i]);
%!   mixed_rhs = coefficient \ complex_rhs;
%!   mixed_lhs = mp ([3 + 1i, 1 - 2i; 1 + 0i, 2 + 3i]) \ real_rhs;
%!   builtin_rhs = coefficient \ [7 + 1i; 4 - 2i];
%!   assert_complex_matrix (mixed_rhs, 2, 1, 512);
%!   assert_complex_matrix (mixed_lhs, 2, 1, 512);
%!   assert_complex_matrix (builtin_rhs, 2, 1, 512);
%!   expected_rhs = [2 + 0.8i; 1 - 1.4i];
%!   expected_lhs = [397 / 173 - (72 / 173) * i; ...
%!                   62 / 173 - (57 / 173) * i];
%!   assert (double (mixed_rhs), expected_rhs, 1e-10);
%!   assert (double (mixed_lhs), expected_lhs, 1e-10);
%!   assert (double (builtin_rhs), expected_rhs, 1e-10);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   real_left = mp ([1, 2; 3, 4]);
%!   complex_right = mp ([5 + 1i, 6 - 2i; 7 + 3i, 8 + 4i]);
%!   horizontal = [real_left, complex_right];
%!   horizontal_reversed = [complex_right, real_left];
%!   vertical = [real_left; complex_right];
%!   vertical_reversed = [complex_right; real_left];
%!   assert_complex_matrix (horizontal, 2, 4, 256);
%!   assert_complex_matrix (horizontal_reversed, 2, 4, 256);
%!   assert_complex_matrix (vertical, 4, 2, 256);
%!   assert_complex_matrix (vertical_reversed, 4, 2, 256);
%!   assert (double (horizontal), [double(real_left), double(complex_right)], 1e-12);
%!   assert (double (horizontal_reversed), [double(complex_right), double(real_left)], 1e-12);
%!   assert (double (vertical), [double(real_left); double(complex_right)], 1e-12);
%!   assert (double (vertical_reversed), [double(complex_right); double(real_left)], 1e-12);
%!   mpbits (1024);
%!   high_complex = mp ([1 + 1i; 2 - 3i]);
%!   mpbits (128);
%!   widened = [real_left, high_complex];
%!   assert_complex_matrix (widened, 2, 3, 1024);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   real_lhs = mp ([1, 2; 3, 4]);
%!   real_before = double (real_lhs);
%!   complex_rhs = mp ([9 + 1i, 8 - 2i; 7 + 3i, 6 + 4i]);
%!   complex_result = real_lhs;
%!   complex_result(1, 2) = complex_rhs(1, 2);
%!   assert_complex_matrix (complex_result, 2, 2, 256);
%!   assert (double (real_lhs), real_before);
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!                              complex_result, 1, 2, 8 - 2i));
%!   complex_result(2, 1) = 17;
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!                              complex_result, 2, 1, 17 + 0i));
%!   high_rhs = mpbits (1024);
%!   high_rhs = mp ("1", "2");
%!   mpbits (128);
%!   widened = real_lhs;
%!   widened(1, 1) = high_rhs;
%!   assert_complex_matrix (widened, 2, 2, 1024);
%!   linear = real_lhs;
%!   linear(:) = mp (complex (ones (2, 2), 2 * ones (2, 2)));
%!   assert_complex_matrix (linear, 2, 2, 256);
%!   assert (double (linear), complex (ones (2, 2), 2 * ones (2, 2)));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ([1 + 2i, 3 - 4i; 5 + 6i, 7 - 8i]);
%!   B = reshape (A, [1, 4]);
%!   assert_complex_matrix (B, 1, 4, 512);
%!   assert (double (B), reshape (double (A), [1, 4]));
%!   assert (double (A.'), double (A).');
%!   assert (double (A'), double (A)');
%!   assert (double (real (A)), real (double (A)));
%!   assert (double (imag (A)), imag (double (A)));
%!   assert (double (conj (A)), conj (double (A)));
%!   assert (strcmp (class (double (A(1, 2))), "double"));
%!   assert (__mplapack_core__ ("scalar_test_info", A(1, 2)).is_complex);
%!   assert (! isempty (char (A(1, 2))));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
