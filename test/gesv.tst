## SPDX-License-Identifier: BSD-2-Clause

%!function assert_matrix_text (value, expected)
%!  info = __mplapack_core__ ("matrix_test_info", value);
%!  assert (info.rows, uint64 (rows (expected)));
%!  assert (info.columns, uint64 (columns (expected)));
%!  for column = 1:columns (expected)
%!    for row = 1:rows (expected)
%!      assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!        value, row, column, expected{row, column}));
%!    endfor
%!  endfor
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"3", "1"; "1", "2"});
%!   B = mp ({"9"; "8"});
%!   X = mldivide (A, B);
%!   assert_matrix_text (X, {"2"; "3"});
%!   assert (__mplapack_core__ ("matrix_test_info", X).precision_bits, ...
%!           uint64 (256));
%!   assert_matrix_text (A, {"3", "1"; "1", "2"});
%!   assert_matrix_text (B, {"9"; "8"});
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"3", "1"; "1", "2"});
%!   B = mp ({"9", "7"; "8", "9"});
%!   X = A \ B;
%!   assert_matrix_text (X, {"2", "1"; "3", "4"});
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"0", "1"; "1", "1"});
%!   B = mp ({"2"; "3"});
%!   X = A \ B;
%!   assert_matrix_text (X, {"1"; "2"});
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   tail = strcat ("1.", repmat ("0", 1, 210), "1");
%!   rhs_tail = strcat ("2.", repmat ("0", 1, 210), "1");
%!   A = mp ({"1", "1"; "1", tail});
%!   B = mp ({"2"; rhs_tail});
%!   mpbits (128);
%!   X = A \ B;
%!   assert (__mplapack_core__ ("matrix_test_element_double", X, 1, 1), 1);
%!   assert (__mplapack_core__ ("matrix_test_element_double", X, 2, 1), 1);
%!   assert (__mplapack_core__ ("matrix_test_info", X).precision_bits, ...
%!           uint64 (1024));
%!   assert (__mplapack_core__ ("precision_get_bits"), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%!   mpbits (4096);
%!   Y = A \ B;
%!   assert (__mplapack_core__ ("matrix_test_element_double", Y, 1, 1), 1);
%!   assert (__mplapack_core__ ("matrix_test_element_double", Y, 2, 1), 1);
%!   assert (__mplapack_core__ ("matrix_test_info", Y).precision_bits, ...
%!           uint64 (1024));
%!   assert (__mplapack_core__ ("precision_get_bits"), uint64 (4096));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (2048);
%!   tail = strcat ("1.", repmat ("0", 1, 450), "1");
%!   rhs_tail = strcat ("2.", repmat ("0", 1, 450), "1");
%!   A = mp ({"1", "1"; "1", tail});
%!   B = mp ({"2"; rhs_tail});
%!   mpbits (128);
%!   X = A \ B;
%!   assert (__mplapack_core__ ("matrix_test_element_double", X, 1, 1), 1);
%!   assert (__mplapack_core__ ("matrix_test_element_double", X, 2, 1), 1);
%!   assert (__mplapack_core__ ("matrix_test_info", X).precision_bits, ...
%!           uint64 (2048));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"3", "1"; "1", "2"});
%!   B = mp ({"9"; "8"});
%!   mpbits (128);
%!   X = A \ B;
%!   assert (__mplapack_core__ ("matrix_test_info", X).precision_bits, ...
%!           uint64 (256));
%!   assert_matrix_text (X, {"2"; "3"});
%!   mpbits (1024);
%!   B_high = mp ({"9"; "8"});
%!   mpbits (128);
%!   X_mixed = A \ B_high;
%!   assert (__mplapack_core__ ("matrix_test_info", X_mixed).precision_bits, ...
%!           uint64 (1024));
%!   mpbits (1024);
%!   A_high = mp ({"3", "1"; "1", "2"});
%!   mpbits (256);
%!   B_low = mp ({"9"; "8"});
%!   mpbits (128);
%!   X_reverse = A_high \ B_low;
%!   assert (__mplapack_core__ ("matrix_test_info", X_reverse).precision_bits, ...
%!           uint64 (1024));
%!   assert_matrix_text (X_reverse, {"2"; "3"});
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"3", "1"; "1", "2"});
%!   X_expected = mp ({"2", "1"; "3", "4"});
%!   B = A * X_expected;
%!   X = A \ B;
%!   assert_matrix_text (X, {"2", "1"; "3", "4"});
%!   X_double = A \ [9, 7; 8, 9];
%!   assert_matrix_text (X_double, {"2", "1"; "3", "4"});
%!   X_reverse = [3, 1; 1, 2] \ B;
%!   assert_matrix_text (X_reverse, {"2", "1"; "3", "4"});
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp (zeros (0, 0));
%!   B = mp (zeros (0, 3));
%!   X = A \ B;
%!   info = __mplapack_core__ ("matrix_test_info", X);
%!   assert (info.rows, uint64 (0));
%!   assert (info.columns, uint64 (3));
%!   assert (info.precision_bits, uint64 (256));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp ({"1", "2"; "2", "4"});
%! B = mp ({"1"; "2"});
%! try
%!   A \ B;
%!   error ("singular solve unexpectedly succeeded");
%! catch exception
%!   assert (! strcmp (exception.message, "singular solve unexpectedly succeeded"));
%!   assert (strcmp (exception.identifier, "mplapack:mp:SingularMatrix"));
%! end_try_catch

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! B = mp ({"1"; "2"; "3"});
%! try
%!   A \ B;
%!   error ("dimension mismatch unexpectedly succeeded");
%! catch exception
%!   assert (! strcmp (exception.message, "dimension mismatch unexpectedly succeeded"));
%!   assert (strcmp (exception.identifier, "mplapack:mp:DimensionMismatch"));
%! end_try_catch

%!test
%! A = mp ({"1", "2"; "3", "4"; "5", "6"});
%! B = mp ({"1"; "2"; "3"});
%! try
%!   A \ B;
%!   error ("non-square solve unexpectedly succeeded");
%! catch exception
%!   assert (! strcmp (exception.message, "non-square solve unexpectedly succeeded"));
%!   assert (strcmp (exception.identifier, "mplapack:mp:NonSquareMatrix"));
%! end_try_catch

%!error <complex matrix left division is not supported> mldivide (mp ([1, 0; 0, 1]), [1 + 2i; 3])

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   s = mp ("2");
%!   X = s \ mp ({"4", "6"; "8", "10"});
%!   assert_matrix_text (X, {"2", "3"; "4", "5"});
%!   X_double_rhs = s \ [4, 6; 8, 10];
%!   assert_matrix_text (X_double_rhs, {"2", "3"; "4", "5"});
%!   y = s \ mp ("8");
%!   assert (__mplapack_core__ ("scalar_test_equal_string", y, "4"));
%!   z = 2 \ mp ({"4"; "8"});
%!   assert_matrix_text (z, {"2"; "4"});
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
