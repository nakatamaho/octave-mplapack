## SPDX-License-Identifier: BSD-2-Clause

%!function info = elementwise_info (value)
%!  if (__mplapack_core__ ("value_is_matrix", value))
%!    info = __mplapack_core__ ("matrix_test_info", value);
%!  else
%!    info = __mplapack_core__ ("scalar_test_info", value);
%!  endif
%!endfunction

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

%!function assert_scalar_text (value, expected)
%!  assert (__mplapack_core__ ("scalar_test_equal_string", value, expected));
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "2", "3"; "4", "5", "6"});
%!   B = mp ({"10", "20", "30"; "40", "50", "60"});
%!   assert_matrix_text (A + B, {"11", "22", "33"; "44", "55", "66"});
%!   assert_matrix_text (A - B, {"-9", "-18", "-27"; "-36", "-45", "-54"});
%!   assert_matrix_text (A .* B, {"10", "40", "90"; "160", "250", "360"});
%!   assert_matrix_text (B ./ A, {"10", "10", "10"; "10", "10", "10"});
%!   assert_matrix_text (+A, {"1", "2", "3"; "4", "5", "6"});
%!   assert_matrix_text (-A, {"-1", "-2", "-3"; "-4", "-5", "-6"});
%!   assert (elementwise_info (A + B).precision_bits, uint64 (256));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (128);
%!   A = mp ({"1", "2", "3"; "4", "5", "6"});
%!   row = mp ({"10", "20", "30"});
%!   column = mp ({"100"; "200"});
%!   assert_matrix_text (A + row, {"11", "22", "33"; "14", "25", "36"});
%!   assert_matrix_text (A + column, {"101", "102", "103"; ...
%!                                    "204", "205", "206"});
%!   assert_matrix_text (column + row, {"110", "120", "130"; ...
%!                                     "210", "220", "230"});
%!   assert_matrix_text (column - row, {"90", "80", "70"; ...
%!                                     "190", "180", "170"});
%!   assert_matrix_text (row - column, {"-90", "-80", "-70"; ...
%!                                     "-190", "-180", "-170"});
%!   quotient_row = mp ({"10", "20", "50"});
%!   assert_matrix_text (column ./ quotient_row, {"10", "5", "2"; ...
%!                                               "20", "10", "4"});
%!   assert (size (A + row), [2, 3]);
%!   assert (size (row + column), [2, 3]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "2"; "3", "4"});
%!   assert_matrix_text (A + [10, 20; 30, 40], ...
%!                       {"11", "22"; "33", "44"});
%!   assert_matrix_text ([10, 20; 30, 40] - A, ...
%!                       {"9", "18"; "27", "36"});
%!   assert_matrix_text (A .* [10, 20; 30, 40], ...
%!                       {"10", "40"; "90", "160"});
%!   assert_matrix_text ([10, 20; 30, 40] ./ A, ...
%!                       {"10", "10"; "10", "10"});
%!   assert_matrix_text (A + [10, 20], {"11", "22"; "13", "24"});
%!   assert_matrix_text ([10; 20] + A, {"11", "12"; "23", "24"});
%!   assert_matrix_text (A + 0.125, {"1.125", "2.125"; "3.125", "4.125"});
%!   assert_matrix_text (0.125 + A, {"1.125", "2.125"; "3.125", "4.125"});
%!   decimal = mp ({"0.1", "0.125"});
%!   binary = [0.1, 0.125];
%!   decimal_sum = decimal + 0.1;
%!   exact_sum = decimal + mp ("0.1");
%!   assert (! __mplapack_core__ ("matrix_test_element_equal", ...
%!                                decimal_sum, 1, 1, exact_sum, 1, 1));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", ...
%!                              decimal + binary, 1, 2, ...
%!                              decimal + mp ("0.125"), 1, 2));
%!   assert (elementwise_info (A + 0.1).precision_bits, uint64 (256));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "2"; "3", "4"});
%!   B = mp ({"5", "6"; "7", "8"});
%!   mpbits (128);
%!   results = {A + B, A - B, A .* B, A ./ B, -A};
%!   for i = 1:numel (results)
%!     assert (elementwise_info (results{i}).precision_bits, uint64 (256));
%!   endfor
%!   assert (mpbits (), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%!   mpbits (4096);
%!   high_default = A + B;
%!   assert (elementwise_info (high_default).precision_bits, uint64 (256));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", high_default, ...
%!                              1, 1, results{1}, 1, 1));
%!   assert (mpbits (), uint64 (4096));
%!   tail = strcat ("1.", repmat ("0", 1, 210), "1");
%!   mpbits (1024);
%!   sensitive = mp ({tail, "0"; "0", "1"});
%!   mpbits (128);
%!   preserved = sensitive + mp ("0");
%!   assert (elementwise_info (preserved).precision_bits, uint64 (1024));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", preserved, ...
%!                              1, 1, sensitive, 1, 1));
%!   deep_tail = strcat ("1.", repmat ("0", 1, 450), "1");
%!   mpbits (2048);
%!   deep = mp ({deep_tail, "0"; "0", "1"});
%!   mpbits (128);
%!   deep_result = deep - mp ("0");
%!   assert (elementwise_info (deep_result).precision_bits, uint64 (2048));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", deep_result, ...
%!                              1, 1, deep, 1, 1));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! positive_zero = mp (0.0);
%! negative_zero = mp (-0.0);
%! positive_one = mp ("1");
%! negative_one = mp ("-1");
%! assert (__mplapack_core__ ("scalar_test_info", -positive_zero).signbit);
%! assert (! __mplapack_core__ ("scalar_test_info", -negative_zero).signbit);
%! assert (__mplapack_core__ ("scalar_test_info", ...
%!                            (positive_one ./ positive_zero)).is_infinite);
%! assert (__mplapack_core__ ("scalar_test_info", ...
%!                            (negative_one ./ positive_zero)).signbit);
%! assert (__mplapack_core__ ("scalar_test_info", ...
%!                            (positive_zero ./ positive_zero)).is_nan);
%! A = mp ({"1", "-1"; "0", "0"});
%! Z = mp ({"0", "-0"; "0", "0"});
%! assert (__mplapack_core__ ("scalar_test_info", (A ./ Z)(1, 1)).is_infinite);
%! assert (__mplapack_core__ ("scalar_test_info", (A ./ Z)(1, 2)).is_infinite);
%! assert (__mplapack_core__ ("scalar_test_info", (A ./ Z)(2, 1)).is_nan);

%!test
%! A = mp (zeros (0, 3));
%! B = mp (ones (1, 3));
%! C = A + B;
%! assert (size (C), [0, 3]);
%! D = mp (zeros (2, 0));
%! E = mp (ones (1, 0));
%! F = D .* E;
%! assert (size (F), [2, 0]);
%! try
%!   mp (zeros (2, 3)) + mp (zeros (4, 3));
%!   error ("incompatible element-wise shape unexpectedly succeeded");
%! catch exception
%!   assert (! strcmp (exception.message, ...
%!                     "incompatible element-wise shape unexpectedly succeeded"));
%!   assert (strcmp (exception.identifier, "mplapack:mp:DimensionMismatch"));
%! end_try_catch

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! B = mp ({"5", "6"; "7", "8"});
%! S = A + B;
%! assert (char (S(1, 1)), "6e+0");
%! assert (size (double (S)), [2, 2]);
%! P = S * mp ({"1"; "1"});
%! assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                            P, 1, 1, "14"));
%! Q = (A + mp ("1")) \ mp ({"5"; "9"});
%! assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!                            Q, 1, 1, 1));
