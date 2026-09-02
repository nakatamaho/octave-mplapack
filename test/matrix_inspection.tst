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
%! A = mp ({"11", "12", "13"; "21", "22", "23"; ...
%!          "31", "32", "33"; "41", "42", "43"});
%! assert (char (A(3, 2)), "3.2e+1");
%! assert_matrix_text (A(:, 3), {"13"; "23"; "33"; "43"});
%! assert_matrix_text (A(4, :), {"41", "42", "43"});
%! assert_matrix_text (A(1:2, 2:3), {"12", "13"; "22", "23"});
%! assert_matrix_text (A([4, 1], [3, 1]), ...
%!                      {"43", "41"; "13", "11"});
%! assert_matrix_text (A([2, 2, 1], [3, 3]), ...
%!                      {"23", "23"; "23", "23"; "13", "13"});
%! assert_matrix_text (A([], :), cell (0, 3));
%! assert_matrix_text (A(:, []), cell (4, 0));

%!test
%! A = mp ({"11", "12", "13"; "21", "22", "23"; ...
%!          "31", "32", "33"; "41", "42", "43"});
%! assert (char (A(6)), "2.2e+1");
%! assert_matrix_text (A(:), {"11"; "21"; "31"; "41"; ...
%!                            "12"; "22"; "32"; "42"; ...
%!                            "13"; "23"; "33"; "43"});
%! assert (char (A(end)), "4.3e+1");
%! assert (char (A(end, 1)), "4.1e+1");
%! assert (char (A(1, end)), "1.3e+1");
%! assert_matrix_text (A(:, end), {"13"; "23"; "33"; "43"});
%! assert_matrix_text (A(end, :), {"41", "42", "43"});
%! assert_matrix_text (A(end-1:end, 1:end), ...
%!                      {"31", "32", "33"; "41", "42", "43"});
%! assert (char (A(:, 2)(1)), "1.2e+1");

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! invalid = {@() A(0, 1), @() A(-1, 1), @() A(1.5, 1), ...
%!            @() A(NaN, 1), @() A(Inf, 1), @() A(3, 1), ...
%!            @() A(1, 3), @() A(1, 1, 1), @() A([1, 2])};
%! for i = 1:numel (invalid)
%!   try
%!     invalid{i} ();
%!     error ("invalid indexing unexpectedly succeeded");
%!   catch exception
%!     assert (! strcmp (exception.message, ...
%!                       "invalid indexing unexpectedly succeeded"));
%!   end_try_catch
%! endfor
%! try
%!   A(1, 1) = mp (5);
%!   error ("indexed assignment unexpectedly succeeded");
%! catch exception
%!   assert (strcmp (exception.identifier, "mplapack:mp:Immutable"));
%! end_try_catch

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   tail = strcat ("1.", repmat ("0", 1, 210), "1");
%!   A = mp ({"1", "2"; "3", tail});
%!   mpbits (128);
%!   x = A(2, 2);
%!   column = A(:, 2);
%!   assert (__mplapack_core__ ("scalar_test_info", x).precision_bits, ...
%!           int64 (1024));
%!   assert (__mplapack_core__ ("matrix_test_info", column).precision_bits, ...
%!           uint64 (1024));
%!   assert (__mplapack_core__ ("scalar_test_equal_string", x, tail));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_text", ...
%!     column, 2, 1, tail));
%!   assert (mpbits (), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (2048);
%!   tail = strcat ("1.", repmat ("0", 1, 450), "1");
%!   A = mp ({tail, "0"});
%!   mpbits (128);
%!   x = A(1, 1);
%!   assert (__mplapack_core__ ("scalar_test_info", x).precision_bits, ...
%!           int64 (2048));
%!   assert (__mplapack_core__ ("scalar_test_equal_string", x, tail));
%!   assert (mpbits (), uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"0.1", "0.125"; "-0", "Inf"});
%!   mpbits (4096);
%!   D = double (A);
%!   assert (isa (D, "double"));
%!   assert (size (D), [2, 2]);
%!   assert (typecast (D(2, 1), "uint64"), typecast (-0.0, "uint64"));
%!   assert (D(1, 2), 0.125);
%!   assert (isinf (D(2, 2)) && D(2, 2) > 0);
%!   assert (D(1, 1), 0.1);
%!   assert (mpbits (), uint64 (4096));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (4096));
%!   special = mp ([-Inf, NaN]);
%!   special_double = double (special);
%!   assert (isinf (special_double (1, 1)) && special_double (1, 1) < 0);
%!   assert (isnan (special_double (1, 2)));
%!   empty = mp (zeros (0, 3));
%!   assert (size (double (empty)), [0, 3]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   A = mp ({"11", "12"; "21", "22"});
%!   expected = "[1.1e+1 1.2e+1\n 2.1e+1 2.2e+1]";
%!   mpbits (128);
%!   format short;
%!   short_output = strtrim (evalc ("disp (A)"));
%!   format long;
%!   long_output = strtrim (evalc ("disp (A)"));
%!   assert (short_output, expected);
%!   assert (long_output, expected);
%!   assert (isempty (strfind (short_output, "payload_")));
%!   assert (mpbits (), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%!   empty_output = strtrim (evalc ("disp (mp (zeros (0, 3)))"));
%!   assert (empty_output, "mp 0x3 matrix []");
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp ({"1", "2"; "3", "4"});
%! B = A(:, 1);
%! clear A;
%! assert (char (B(2)), "3e+0");
%! x = B * mp ("2");
%! assert (char (x(1)), "2e+0");
%! S = mp ({"3", "1"; "1", "2"});
%! rhs = mp ({"9"; "8"});
%! solution = S \ rhs;
%! assert (char (solution(2)), "3e+0");

%!error <char conversion for dense mp matrices> char (mp ([1, 2]))
