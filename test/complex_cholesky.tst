## SPDX-License-Identifier: BSD-2-Clause

%!function assert_complex_matrix_close (value, expected)
%!  info = __mplapack_core__ ("matrix_test_info", value);
%!  assert (info.rows, uint64 (rows (expected)));
%!  assert (info.columns, uint64 (columns (expected)));
%!  assert (info.is_complex && info.all_elements_same_precision);
%!  assert (double (value), expected, 1e-12);
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   upper_input = mp ([4 + 9i, 2 + 1i; 777 + 888i, 10 - 7i]);
%!   upper_before = double (upper_input);
%!   [R, p] = chol (upper_input, "upper");
%!   assert (p, 0);
%!   assert_complex_matrix_close (R, [2, 1 + 0.5i; 0, 2.958039891549808]);
%!   assert (double (upper_input), upper_before);
%!   lower_input = mp ([4 + 9i, 777 + 888i; 2 - 1i, 10 - 7i]);
%!   [L, p_lower] = chol (lower_input, "lower");
%!   assert (p_lower, 0);
%!   assert_complex_matrix_close (L, [2, 0; 1 - 0.5i, 2.958039891549808]);
%!   assert (! isreal (R) && ! isreal (L));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   diagonal_imaginary = mp ([4 + 123i, 0 + 0i; 0 + 0i, 9 - 77i]);
%!   [R, p] = chol (diagonal_imaginary);
%!   assert (p, 0);
%!   assert_complex_matrix_close (R, [2, 0; 0, 3]);
%!   assert (! __mplapack_core__ ("matrix_test_element_equal_double", ...
%!                               R, 1, 1, 2 + 1i));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!                              R, 1, 1, 2 + 0i));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   semidefinite = mp ([1 + 7i, 1 + 0i; 1 + 0i, 1 - 8i]);
%!   [R, p] = chol (semidefinite);
%!   assert (p, 2);
%!   assert (size (R), [1, 1]);
%!   assert (__mplapack_core__ ("scalar_test_info", R).is_complex);
%!   assert (double (R), 1);
%!   fail ("chol (semidefinite)", "not positive definite");
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for setting = {[1024, 700], [2048, 1500]}
%!     precision = setting{1}(1);
%!     exponent = setting{1}(2);
%!     mpbits (precision);
%!     delta = mp ("1", "0");
%!     for k = 1:exponent
%!       delta = delta ./ mp ("2", "0");
%!     endfor
%!     A = mp (complex (ones (2, 2), zeros (2, 2)));
%!     A(2, 2) = mp ("1", "0") + delta;
%!     mpbits (128);
%!     [R, p] = chol (A);
%!     assert (p, 0);
%!     assert (__mplapack_core__ ("matrix_test_info", R).precision_bits, ...
%!             uint64 (precision));
%!     assert (__mplapack_core__ ("matrix_test_element_double", R, 2, 2) > 0);
%!     assert (__mplapack_core__ ("precision_get_bits"), uint64 (128));
%!     assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!             uint64 (128));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp (complex (ones (2, 1), zeros (2, 1)));
%! fail ("chol (A)", "requires a square");
