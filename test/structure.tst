## SPDX-License-Identifier: BSD-2-Clause

%!function info = structure_info (value)
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

%!test
%! x = mp ("1.25");
%! assert_scalar_text = @(value, text) ...
%!   __mplapack_core__ ("scalar_test_equal_string", value, text);
%! assert (assert_scalar_text (transpose (x), "1.25"));
%! assert (assert_scalar_text (ctranspose (x), "1.25"));
%! assert (structure_info (transpose (x)).precision_bits, int64 (512));
%! assert (! __mplapack_core__ ("value_is_matrix", transpose (x)));

%!test
%! saved = mpbits ();
%! unwind_protect
%! mpbits (256);
%! A = mp ({"11", "12", "13"; "21", "22", "23"});
%! T = A.';
%! H = A';
%! assert_matrix_text (T, {"11", "21"; "12", "22"; "13", "23"});
%! assert_matrix_text (H, {"11", "21"; "12", "22"; "13", "23"});
%! assert (size (T), [3, 2]);
%! assert (structure_info (T).precision_bits, uint64 (256));
%! assert_matrix_text (T.', {"11", "12", "13"; "21", "22", "23"});
%! assert_matrix_text (H', {"11", "12", "13"; "21", "22", "23"});
%! row = mp ({"1", "2", "3"});
%! column = row.';
%! assert (size (column), [3, 1]);
%! assert_matrix_text (column, {"1"; "2"; "3"});
%! assert_matrix_text (column.', {"1", "2", "3"});
%! unwind_protect_cleanup
%! mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%! mpbits (256);
%! A = mp ({"11", "12", "13"; "21", "22", "23"});
%! R = reshape (A, 3, 2);
%! V = reshape (A, [3, 2]);
%! row = reshape (A, 1, 6);
%! column = reshape (A, 6, 1);
%! inferred_rows = reshape (A, [], 2);
%! inferred_columns = reshape (A, 2, []);
%! expected_linear = {"11"; "21"; "12"; "22"; "13"; "23"};
%! assert_matrix_text (R, {"11", "22"; "21", "13"; "12", "23"});
%! assert_matrix_text (V, {"11", "22"; "21", "13"; "12", "23"});
%! assert_matrix_text (row, {"11", "21", "12", "22", "13", "23"});
%! assert_matrix_text (column, expected_linear);
%! assert_matrix_text (inferred_rows, {"11", "22"; "21", "13"; "12", "23"});
%! assert_matrix_text (inferred_columns, {"11", "12", "13"; "21", "22", "23"});
%! assert_matrix_text (reshape (row, 2, 3), {"11", "12", "13"; ...
%!                                          "21", "22", "23"});
%! assert (structure_info (R).precision_bits, uint64 (256));
%! unwind_protect_cleanup
%! mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%! mpbits (256);
%! scalar = mp ("7");
%! assert_scalar = reshape (scalar, 1, 1);
%! assert (! __mplapack_core__ ("value_is_matrix", assert_scalar));
%! assert (__mplapack_core__ ("scalar_test_equal_string", assert_scalar, "7"));
%! try
%!   reshape (scalar, 1, 2);
%!   error ("scalar reshape unexpectedly succeeded");
%! catch exception
%!   assert (strcmp (exception.identifier, "mplapack:mp:InvalidDimension"));
%! end_try_catch
%! unwind_protect_cleanup
%! mpbits (saved);
%! end_unwind_protect

%!test
%! empty = mp (zeros (0, 3));
%! assert (size (empty.'), [3, 0]);
%! assert (size (empty'), [3, 0]);
%! assert (size (reshape (empty, 0, 3)), [0, 3]);
%! assert (size (reshape (empty, 3, 0)), [3, 0]);
%! assert (size (reshape (empty, [], 3)), [0, 3]);
%! assert (size (reshape (empty, 3, [])), [3, 0]);
%! empty_square = mp (zeros (0, 0));
%! assert (size (reshape (empty_square, 0, 0)), [0, 0]);

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! try
%!   reshape (A, 3, 3);
%!   error ("reshape element mismatch unexpectedly succeeded");
%! catch exception
%!   assert (strcmp (exception.identifier, "mplapack:mp:InvalidDimension"));
%! end_try_catch
%! for bad = {[1, 2, 3], [-1, 4], [1.5, 4], [Inf, 4], [NaN, 4]}
%!   try
%!     reshape (A, bad{1});
%!     error ("invalid reshape dimensions unexpectedly succeeded");
%!   catch exception
%!     assert (! strcmp (exception.message, ...
%!                       "invalid reshape dimensions unexpectedly succeeded"));
%!     assert (strcmp (exception.identifier, "mplapack:mp:InvalidDimension"));
%!   end_try_catch
%! endfor
%! try
%!   reshape (A, [], []);
%!   error ("two inferred dimensions unexpectedly succeeded");
%! catch exception
%!   assert (strcmp (exception.identifier, "mplapack:mp:InvalidDimension"));
%! end_try_catch
%! try
%!   reshape (A, 2, 2, 1);
%!   error ("N-D reshape unexpectedly succeeded");
%! catch exception
%!   assert (! strcmp (exception.message, "N-D reshape unexpectedly succeeded"));
%! end_try_catch

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   tail = strcat ("1.", repmat ("0", 1, 210), "1");
%!   A = mp ({tail, "0"; "0", "1"});
%!   mpbits (128);
%!   T = A.';
%!   H = A';
%!   R = reshape (A, 1, 4);
%!   assert (structure_info (T).precision_bits, uint64 (1024));
%!   assert (structure_info (H).precision_bits, uint64 (1024));
%!   assert (structure_info (R).precision_bits, uint64 (1024));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", T, 1, 1, ...
%!                              A, 1, 1));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", H, 1, 1, ...
%!                              A, 1, 1));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", R, 1, 1, ...
%!                              A, 1, 1));
%!   assert (mpbits (), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%!   mpbits (4096);
%!   assert (structure_info (A.').precision_bits, uint64 (1024));
%!   assert (structure_info (reshape (A, 2, 2)).precision_bits, uint64 (1024));
%!   assert (mpbits (), uint64 (4096));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (2048);
%!   tail = strcat ("1.", repmat ("0", 1, 450), "1");
%!   A = mp ({tail, "0"; "0", "1"});
%!   mpbits (128);
%!   T = A.';
%!   R = reshape (A, 1, 4);
%!   assert (structure_info (T).precision_bits, uint64 (2048));
%!   assert (structure_info (R).precision_bits, uint64 (2048));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", T, 1, 1, ...
%!                              A, 1, 1));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", R, 1, 1, ...
%!                              A, 1, 1));
%!   assert (mpbits (), uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! values = [11, 12, 13; 21, 22, 23];
%! A = mp (values);
%! assert (size (double (A.')), [3, 2]);
%! assert (double (reshape (A, 1, 6)), [11, 21, 12, 22, 13, 23]);
%! transposed = A.';
%! assert (char (transposed (1, 1)), "1.1e+1");
%! assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                            A + mp ("1"), 1, 1, "12"));
%! P = A.' * mp ({"1"; "1"});
%! assert (__mplapack_core__ ("matrix_test_element_equal_text", P, 1, 1, "32"));
%! S = reshape (mp ({"2", "0"; "0", "2"}), 2, 2);
%! solved = S \ mp ({"4"; "6"});
%! assert (__mplapack_core__ ("matrix_test_element_equal_text", solved, 1, 1, "2"));

%!test
%! plus_zero = mp (0.0);
%! minus_zero = mp (-0.0);
%! special = mp ({"0", "-0"; "Inf", "NaN"});
%! special_transposed = special.';
%! assert (__mplapack_core__ ("scalar_test_info", special_transposed (1, 1)).is_zero);
%! assert (! __mplapack_core__ ("scalar_test_info", ...
%!                              special_transposed (1, 1)).signbit);
%! assert (__mplapack_core__ ("scalar_test_info", ...
%!                            special_transposed (2, 1)).signbit);
%! assert (__mplapack_core__ ("scalar_test_info", ...
%!                            special_transposed (1, 2)).is_infinite);
%! assert (__mplapack_core__ ("scalar_test_info", ...
%!                            special_transposed (2, 2)).is_nan);
%! assert (__mplapack_core__ ("scalar_test_info", plus_zero).is_zero);
%! assert (__mplapack_core__ ("scalar_test_info", minus_zero).signbit);
