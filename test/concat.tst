## SPDX-License-Identifier: BSD-2-Clause

%!function info = concat_info (value)
%!  info = __mplapack_core__ ("value_shape_info", value);
%!endfunction

%!function assert_matrix_text (value, expected)
%!  info = concat_info (value);
%!  assert (info.rows, uint64 (rows (expected)));
%!  assert (info.columns, uint64 (columns (expected)));
%!  for column = 1:columns (expected)
%!    for row = 1:rows (expected)
%!      assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!        value, row, column, expected{row, column}));
%!    endfor
%!  endfor
%!endfunction

%!function ok = expect_horzcat_error (lhs, rhs)
%!  ok = false;
%!  try
%!    unused = horzcat (lhs, rhs);
%!  catch
%!    ok = true;
%!  end_try_catch
%!endfunction

%!function ok = expect_vertcat_error (lhs, rhs)
%!  ok = false;
%!  try
%!    unused = vertcat (lhs, rhs);
%!  catch
%!    ok = true;
%!  end_try_catch
%!endfunction

%!function ok = expect_native_concat_error ()
%!  ok = false;
%!  try
%!    unused = __mplapack_core__ ("matrix_horzcat", 1.0, 2.0);
%!  catch
%!    ok = true;
%!  end_try_catch
%!endfunction

%!test
%! A = mp ({"11", "12"; "21", "22"});
%! B = mp ({"31", "32", "33"; "41", "42", "43"});
%! H = [A, B];
%! V = [A; A];
%! assert (isa (H, "mp"));
%! assert_matrix_text (H, {"11", "12", "31", "32", "33"; ...
%!                         "21", "22", "41", "42", "43"});
%! assert_matrix_text (V, {"11", "12"; "21", "22"; ...
%!                         "11", "12"; "21", "22"});
%! assert_matrix_text (horzcat (A, B, A), ...
%!                      {"11", "12", "31", "32", "33", "11", "12"; ...
%!                       "21", "22", "41", "42", "43", "21", "22"});
%! assert_matrix_text (vertcat (A, A, A), ...
%!                      {"11", "12"; "21", "22"; "11", "12"; ...
%!                       "21", "22"; "11", "12"; "21", "22"});
%! assert_matrix_text (horzcat (A), {"11", "12"; "21", "22"});
%! assert_matrix_text (vertcat (A), {"11", "12"; "21", "22"});

%!test
%! A = mp ({"11", "12"; "21", "22"});
%! B = mp ({"31", "32"; "41", "42"});
%! assert_matrix_text ([A, B], {"11", "12", "31", "32"; ...
%!                              "21", "22", "41", "42"});
%! assert_matrix_text ([B, A], {"31", "32", "11", "12"; ...
%!                              "41", "42", "21", "22"});
%! assert_matrix_text ([A; B], {"11", "12"; "21", "22"; ...
%!                         "31", "32"; "41", "42"});
%! nested_h = [A, [B, A]];
%! nested_v = [A; [B; A]];
%! assert_matrix_text (nested_h, {"11", "12", "31", "32", "11", "12"; ...
%!                                "21", "22", "41", "42", "21", "22"});
%! assert_matrix_text (nested_v, {"11", "12"; "21", "22"; ...
%!                                "31", "32"; "41", "42"; ...
%!                                "11", "12"; "21", "22"});

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "2"; "3", "4"});
%!   mpbits (1024);
%!   B = mp ({"5", "6"; "7", "8"});
%!   mpbits (128);
%!   H = [A, B];
%!   V = [A; B];
%!   assert (concat_info (H).precision_bits, uint64 (1024));
%!   assert (concat_info (V).precision_bits, uint64 (1024));
%!   assert (concat_info (A).precision_bits, uint64 (256));
%!   assert (concat_info (B).precision_bits, uint64 (1024));
%!   assert (mpbits (), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   tail = strcat ("1.", repmat ("0", 1, 210), "1");
%!   A = mp ({tail; "0"});
%!   mpbits (128);
%!   H_rhs = mp ({"2"; "3"});
%!   V_rhs = mp ({"4"; "5"});
%!   H = [A, H_rhs];
%!   V = [A; V_rhs];
%!   assert (concat_info (H).precision_bits, uint64 (1024));
%!   assert (concat_info (V).precision_bits, uint64 (1024));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                              H, 1, 1, tail));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                              V, 1, 1, tail));
%!   mpbits (4096);
%!   assert (concat_info ([A, A]).precision_bits, uint64 (1024));
%!   assert (mpbits (), uint64 (4096));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (2048);
%!   tail = strcat ("1.", repmat ("0", 1, 450), "1");
%!   A = mp ({tail; "0"});
%!   mpbits (128);
%!   H_rhs = mp ({"2"; "3"});
%!   V_rhs = mp ({"4"; "5"});
%!   H = [A, H_rhs];
%!   V = [A; V_rhs];
%!   assert (concat_info (H).precision_bits, uint64 (2048));
%!   assert (concat_info (V).precision_bits, uint64 (2048));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                              H, 1, 1, tail));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                              V, 1, 1, tail));
%!   assert (mpbits (), uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp ({"0", "-0", "Inf", "NaN"});
%! B = [A, A];
%! zero_positive = __mplapack_core__ ("scalar_test_info", B(1, 1));
%! zero_negative = __mplapack_core__ ("scalar_test_info", B(1, 2));
%! inf_info = __mplapack_core__ ("scalar_test_info", B(1, 3));
%! nan_info = __mplapack_core__ ("scalar_test_info", B(1, 4));
%! assert (! zero_positive.signbit && zero_positive.is_zero);
%! assert (zero_negative.signbit && zero_negative.is_zero);
%! assert (inf_info.is_infinite && ! inf_info.signbit);
%! assert (nan_info.is_nan);

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! builtin_empty = [];
%! assert_matrix_text ([A, builtin_empty], {"1", "2"; "3", "4"});
%! assert_matrix_text ([builtin_empty, A], {"1", "2"; "3", "4"});
%! assert_matrix_text ([A; builtin_empty], {"1", "2"; "3", "4"});
%! assert_matrix_text ([builtin_empty; A], {"1", "2"; "3", "4"});
%! assert (expect_horzcat_error (A, 1 + 2i));
%! assert (expect_vertcat_error (A, ones (2, 2, 2)));

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "2"; "3", "4"});
%!   D = [A, [5.0, 0.1; 6.0, 0.125]];
%!   E = [[5.0, 0.1; 6.0, 0.125], A];
%!   F = [A; [5.0, 0.1]];
%!   G = [[5.0, 0.1]; A];
%!   assert (isa (D, "mp") && isa (E, "mp"));
%!   assert (concat_info (D).precision_bits, uint64 (256));
%!   assert (concat_info (E).precision_bits, uint64 (256));
%!   assert (concat_info (F).precision_bits, uint64 (256));
%!   assert (concat_info (G).precision_bits, uint64 (256));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!                              D, 1, 3, 5.0));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!                              D, 2, 4, 0.125));
%!   assert (__mplapack_core__ ("scalar_test_equal", D (1, 4), mp (0.1)));
%!   assert (mpbits (), uint64 (256));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp ({"11", "12"; "21", "22"});
%! H_rhs = [2.0; 4.0];
%! V_rhs = [5.0, 6.0];
%! H = [A, H_rhs];
%! V = [A; V_rhs];
%! assert_matrix_text (H, {"11", "12", "2"; "21", "22", "4"});
%! assert_matrix_text (V, {"11", "12"; "21", "22"; "5", "6"});
%! assert (size (double (H)), [2, 3]);
%! assert (size (double (V)), [3, 2]);

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ({"1", "2"; "3", "4"});
%!   empty = mp (zeros (0, 0));
%!   empty_row = mp (zeros (0, 1));
%!   empty_cols = mp (zeros (2, 0));
%!   empty_one_row = mp (zeros (1, 0));
%!   assert (size ([A, empty]), [2, 2]);
%!   assert (size ([A, empty_row]), [2, 2]);
%!   assert (size ([empty, A]), [2, 2]);
%!   assert (size ([A; empty]), [2, 2]);
%!   assert (size ([A; empty_one_row]), [2, 2]);
%!   assert (size ([empty_cols, A]), [2, 2]);
%!   empty_h_left = mp (zeros (0, 2));
%!   empty_h_right = mp (zeros (0, 3));
%!   empty_v_top = mp (zeros (2, 0));
%!   empty_v_bottom = mp (zeros (3, 0));
%!   zeros_h = [empty_h_left, empty_h_right];
%!   zeros_v = [empty_v_top; empty_v_bottom];
%!   assert (size (zeros_h), [0, 5]);
%!   assert (size (zeros_v), [5, 0]);
%!   assert (concat_info (zeros_h).precision_bits, uint64 (512));
%!   assert (concat_info (zeros_v).precision_bits, uint64 (512));
%!   try
%!     invalid_h = mp (zeros (0, 2));
%!     [A, invalid_h];
%!     error ("horizontal empty mismatch unexpectedly succeeded");
%!   catch exception
%!     assert (! strcmp (exception.message, ...
%!                       "horizontal empty mismatch unexpectedly succeeded"));
%!   end_try_catch
%!   try
%!     invalid_v = mp (zeros (2, 0));
%!     [A; invalid_v];
%!     error ("vertical empty mismatch unexpectedly succeeded");
%!   catch exception
%!     assert (! strcmp (exception.message, ...
%!                       "vertical empty mismatch unexpectedly succeeded"));
%!   end_try_catch
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (2048);
%!   high_empty = mp (zeros (0, 1));
%!   mpbits (128);
%!   empty_double = zeros (0, 2);
%!   R = [high_empty, empty_double];
%!   assert (isa (R, "mp"));
%!   assert (concat_info (R).precision_bits, uint64 (2048));
%!   assert (size (R), [0, 3]);
%!   assert (mpbits (), uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! before = concat_info (A);
%! C = [A, A];
%! clear A;
%! assert_matrix_text (C, {"1", "2", "1", "2"; "3", "4", "3", "4"});
%! assert (concat_info (C).precision_bits, before.precision_bits);
%! S_left = mp ("1");
%! S_right = mp ("2");
%! S = [S_left, S_right];
%! singleton = horzcat (S_left);
%! assert (! __mplapack_core__ ("value_is_matrix", singleton));
%! assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!                            S, 1, 1, "1"));

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! assert (expect_horzcat_error (A, ones (3, 1)));
%! assert (expect_vertcat_error (A, ones (1, 3)));
%! assert (expect_native_concat_error ());
