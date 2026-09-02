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

%!function assert_matrix_close (value, expected)
%!  info = __mplapack_core__ ("matrix_test_info", value);
%!  assert (info.rows, uint64 (rows (expected)));
%!  assert (info.columns, uint64 (columns (expected)));
%!  for column = 1:columns (expected)
%!    for row = 1:rows (expected)
%!      got = __mplapack_core__ ("matrix_test_element_double", ...
%!        value, row, column);
%!      assert (got, expected(row, column), 1e-12);
%!    endfor
%!  endfor
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1"; "2"; "3"});
%!   B = mp ({"1"; "2"; "3"});
%!   X = A \ B;
%!   assert (double (X), 1, 1e-12);
%!   A_row = mp ({"1", "2", "3"});
%!   B_row = mp ({"14"});
%!   X_row = A_row \ B_row;
%!   assert_matrix_close (X_row, [1; 2; 3]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "0"; "0", "1"; "1", "1"});
%!   B = mp ({"0"; "1"; "4"});
%!   X = A \ B;
%!   assert_matrix_close (X, [1; 2]);
%!   assert (__mplapack_core__ ("matrix_test_info", X).precision_bits, ...
%!           uint64 (256));
%!   assert_matrix_text (A, {"1", "0"; "0", "1"; "1", "1"});
%!   assert_matrix_text (B, {"0"; "1"; "4"});
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "0", "1"; "0", "1", "1"});
%!   B = mp ({"3"; "3"});
%!   X = A \ B;
%!   assert_matrix_close (X, [1; 1; 2]);
%!   assert (__mplapack_core__ ("matrix_test_info", X).precision_bits, ...
%!           uint64 (256));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   t = strcat ("0.", repmat ("0", 1, 210), "1");
%!   A = mp ({"1", "0"; "0", "1"; "1", "1"});
%!   B = mp ({"0"; "1"; "4"});
%!   B(1) = mp (t);
%!   B(2) = mp ("1") - mp (t);
%!   mpbits (128);
%!   X = A \ B;
%!   assert (__mplapack_core__ ("matrix_test_info", X).precision_bits, ...
%!           uint64 (1024));
%!   assert (! __mplapack_core__ ("matrix_test_element_equal_double", ...
%!     X, 1, 1, 1));
%!   assert (! __mplapack_core__ ("matrix_test_element_equal_double", ...
%!     X, 2, 1, 2));
%!   assert (__mplapack_core__ ("precision_get_bits"), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "0"; "0", "1"; "1", "1"});
%!   B = [0; 1; 4];
%!   X = A \ B;
%!   assert_matrix_close (X, [1; 2]);
%!   X2 = [1, 0; 0, 1; 1, 1] \ mp ({"0"; "1"; "4"});
%!   assert_matrix_close (X2, [1; 2]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "0"; "0", "1"; "1", "1"});
%!   X_expected = mp ({"1", "2"; "2", "1"});
%!   B = A * X_expected + mp ({"-1", "-1"; "-1", "-1"; "1", "1"});
%!   X = A \ B;
%!   assert_matrix_close (X, [1, 2; 2, 1]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "0", "1"; "0", "1", "1"});
%!   B = mp ({"3", "6"; "3", "3"});
%!   X = A \ B;
%!   assert_matrix_close (X, [1, 3; 1, 0; 2, 3]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "0", "1"; "0", "1", "1"});
%!   B = mp ({"3"; "3"});
%!   X = A \ B;
%!   assert_matrix_close (A * X, [3; 3]);
%!   assert_matrix_close (X, [1; 1; 2]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "0"; "0", "1"; "1", "1"});
%!   B = mp ({"0"; "1"; "4"});
%!   mpbits (4096);
%!   X = A \ B;
%!   assert (__mplapack_core__ ("matrix_test_info", X).precision_bits, ...
%!           uint64 (256));
%!   assert (__mplapack_core__ ("precision_get_bits"), uint64 (4096));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (4096));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp (zeros (2, 0));
%!   B = mp (zeros (2, 3));
%!   X = A \ B;
%!   info = __mplapack_core__ ("matrix_test_info", X);
%!   assert (info.rows, uint64 (0));
%!   assert (info.columns, uint64 (3));
%!   assert (info.precision_bits, uint64 (256));
%!   A0 = mp (zeros (0, 2));
%!   B0 = mp (zeros (0, 1));
%!   X0 = A0 \ B0;
%!   info0 = __mplapack_core__ ("matrix_test_info", X0);
%!   assert (info0.rows, uint64 (2));
%!   assert (info0.columns, uint64 (1));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!     X0, 1, 1, 0));
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
%! A = mp ({"1", "2"; "3", "4"; "5", "6"});
%! B = mp ({"1"; "2"});
%! try
%!   A \ B;
%!   error ("dimension mismatch unexpectedly succeeded");
%! catch exception
%!   assert (! strcmp (exception.message, "dimension mismatch unexpectedly succeeded"));
%!   assert (strcmp (exception.identifier, "mplapack:mp:DimensionMismatch"));
%! end_try_catch
