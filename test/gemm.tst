## SPDX-License-Identifier: BSD-2-Clause

%!function assert_matrix_text (value, expected)
%!  for column = 1:columns (value)
%!    for row = 1:rows (value)
%!      assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!        value, row, column, expected{row, column}));
%!    endfor
%!  endfor
%!endfunction

%!function assert_scalar_text (value, expected)
%!  assert (__mplapack_core__ ("scalar_test_equal_string", value, expected));
%!endfunction

%!function assert_matrix_shape (value, expected_rows, expected_columns, ...
%!                             expected_precision)
%!  info = __mplapack_core__ ("matrix_test_info", value);
%!  assert (info.rows, uint64 (expected_rows));
%!  assert (info.columns, uint64 (expected_columns));
%!  assert (info.precision_bits, uint64 (expected_precision));
%!  assert (info.all_elements_same_precision);
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "2"; "3", "4"});
%!   B = mp ({"5", "6"; "7", "8"});
%!   C = A * B;
%!   assert (strcmp (class (C), "mp"));
%!   assert_matrix_shape (C, 2, 2, 256);
%!   assert_matrix_text (C, {"19", "22"; "43", "50"});
%!   assert_matrix_text (A, {"1", "2"; "3", "4"});
%!   assert_matrix_text (B, {"5", "6"; "7", "8"});
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (128);
%!   A = mp ({"1", "2", "3"; "4", "5", "6"});
%!   B = mp ({"7", "8", "9", "10"; "11", "12", "13", "14"; ...
%!            "15", "16", "17", "18"});
%!   C = A * B;
%!   assert_matrix_shape (C, 2, 4, 128);
%!   assert_matrix_text (C, {"74", "80", "86", "92"; ...
%!                           "173", "188", "203", "218"});
%!   row = mp ({"1", "2", "3"});
%!   column = mp ({"4"; "5"; "6"});
%!   scalar_result = row * column;
%!   assert_scalar_text (scalar_result, "32");
%!   assert (! __mplapack_core__ ("value_is_matrix", scalar_result));
%!   outer = column * row;
%!   assert_matrix_shape (outer, 3, 3, 128);
%!   assert_matrix_text (outer, {"4", "8", "12"; ...
%!                              "5", "10", "15"; "6", "12", "18"});
%!   outer_wide = mp ({"1"; "2"; "3"}) * ...
%!                mp ({"4", "5", "6", "7", "8"});
%!   assert_matrix_shape (outer_wide, 3, 5, 128);
%!   assert_matrix_text (outer_wide, {"4", "5", "6", "7", "8"; ...
%!                                   "8", "10", "12", "14", "16"; ...
%!                                   "12", "15", "18", "21", "24"});
%!   dot_wide = mp ({"1", "2", "3", "4"}) * ...
%!              mp ({"5"; "6"; "7"; "8"});
%!   assert_scalar_text (dot_wide, "70");
%!   A_wide = mp ({"1", "2", "3"; "4", "5", "6"; ...
%!                 "7", "8", "9"; "10", "11", "12"});
%!   B_wide = mp ({"2", "3"; "4", "5"; "6", "7"});
%!   product_wide = A_wide * B_wide;
%!   assert_matrix_shape (product_wide, 4, 2, 128);
%!   assert_matrix_text (product_wide, {"28", "34"; "64", "79"; ...
%!                                      "100", "124"; "136", "169"});
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (333);
%!   A = mp ([1, 2; 3, 4]);
%!   B = [5, 6; 7, 8];
%!   C = A * B;
%!   assert_matrix_shape (C, 2, 2, 333);
%!   assert_matrix_text (C, {"19", "22"; "43", "50"});
%!   D = B * A;
%!   assert_matrix_text (D, {"23", "34"; "31", "46"});
%!   E = mp ("2") * B;
%!   assert_matrix_text (E, {"10", "12"; "14", "16"});
%!   F = B * mp ("2");
%!   assert_matrix_text (F, {"10", "12"; "14", "16"});
%!   G = A * 0.125;
%!   assert_matrix_text (G, {"0.125", "0.25"; "0.375", "0.5"});
%!   H = 0.125 * A;
%!   assert_matrix_text (H, {"0.125", "0.25"; "0.375", "0.5"});
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 2; 3, 4]);
%!   B = mp ([5, 6; 7, 8]);
%!   mpbits (128);
%!   C = A * B;
%!   assert_matrix_shape (C, 2, 2, 256);
%!   assert_matrix_text (C, {"19", "22"; "43", "50"});
%!   assert (__mplapack_core__ ("precision_get_bits"), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%!   mpbits (512);
%!   D = A * B;
%!   assert_matrix_text (D, {"19", "22"; "43", "50"});
%!   assert_matrix_shape (D, 2, 2, 256);
%!   assert (__mplapack_core__ ("matrix_test_element_equal", C, 1, 1, ...
%!                              D, 1, 1));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   tail = strcat ("1.", repmat ("0", 1, 210), "1");
%!   A = mp ({tail, "0"; "0", "1"});
%!   I = mp ({"1", "0"; "0", "1"});
%!   mpbits (128);
%!   C = A * I;
%!   assert_matrix_shape (C, 2, 2, 1024);
%!   assert (__mplapack_core__ ("matrix_test_element_equal", C, 1, 1, ...
%!                              A, 1, 1));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%!   mpbits (4096);
%!   D = A * I;
%!   assert_matrix_shape (D, 2, 2, 1024);
%!   assert (__mplapack_core__ ("matrix_test_element_equal", D, 1, 1, ...
%!                              A, 1, 1));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (4096));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (2048);
%!   tail = strcat ("1.", repmat ("0", 1, 450), "1");
%!   A = mp ({tail, "0"; "0", "1"});
%!   I = mp ({"1", "0"; "0", "1"});
%!   mpbits (128);
%!   C = A * I;
%!   assert_matrix_shape (C, 2, 2, 2048);
%!   assert (__mplapack_core__ ("matrix_test_element_equal", C, 1, 1, ...
%!                              A, 1, 1));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp (zeros (2, 0));
%!   B = mp (zeros (0, 3));
%!   C = A * B;
%!   assert_matrix_shape (C, 2, 3, 256);
%!   assert_matrix_text (C, {"0", "0", "0"; "0", "0", "0"});
%!   D = mp (zeros (0, 3)) * mp (ones (3, 2));
%!   assert_matrix_shape (D, 0, 2, 256);
%!   E = mp (ones (2, 3)) * mp (zeros (3, 0));
%!   assert_matrix_shape (E, 2, 0, 256);
%!   F = mp (zeros (0, 0)) * mp (zeros (0, 0));
%!   assert_matrix_shape (F, 0, 0, 256);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! B = mp ({"1", "2", "3"});
%! try
%!   A * B;
%!   error ("M08 dimension mismatch unexpectedly succeeded");
%! catch exception
%!   assert (! strcmp (exception.message, ...
%!                     "M08 dimension mismatch unexpectedly succeeded"));
%!   assert (strcmp (exception.identifier, "mplapack:mp:DimensionMismatch"));
%! end_try_catch
%! try
%!   A + A;
%!   error ("M08 matrix plus unexpectedly succeeded");
%! catch exception
%!   assert (! strcmp (exception.message, ...
%!                     "M08 matrix plus unexpectedly succeeded"));
%!   assert (strcmp (exception.identifier, "mplapack:mp:MatrixUnsupported"));
%! end_try_catch
%! try
%!   A / A;
%!   error ("M08 matrix division unexpectedly succeeded");
%! catch exception
%!   assert (! strcmp (exception.message, ...
%!                     "M08 matrix division unexpectedly succeeded"));
%!   assert (strcmp (exception.identifier, "mplapack:NotImplemented"));
%! end_try_catch

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   decimal = mp ({"0.1", "0.125"});
%!   binary = mp ([0.1, 0.125]);
%!   decimal_product = decimal * mp ("1");
%!   binary_product = binary * mp ("1");
%!   assert (! __mplapack_core__ ("matrix_test_element_equal", ...
%!                                decimal_product, 1, 1, ...
%!                                binary_product, 1, 1));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", ...
%!                              decimal_product, 1, 2, ...
%!                              binary_product, 1, 2));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
