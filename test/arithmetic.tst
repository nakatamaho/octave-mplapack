## SPDX-License-Identifier: BSD-2-Clause

%!function info = m06_info (value)
%!  info = __mplapack_core__ ("scalar_test_info", value);
%!endfunction

%!function m06_expect_binary_error (operation, lhs, rhs, identifier)
%!  try
%!    switch (operation)
%!      case "plus"
%!        plus (lhs, rhs);
%!      case "minus"
%!        minus (lhs, rhs);
%!      case "times"
%!        times (lhs, rhs);
%!      case "rdivide"
%!        rdivide (lhs, rhs);
%!      otherwise
%!        error ("unknown M06 test operation");
%!    endswitch
%!    error ("M06 operation unexpectedly succeeded");
%!  catch exception
%!    assert (! strcmp (exception.message, ...
%!                      "M06 operation unexpectedly succeeded"));
%!    assert (strcmp (exception.identifier, identifier));
%!  end_try_catch
%!endfunction

%!function m06_assert_equal (lhs, rhs)
%!  assert (__mplapack_core__ ("scalar_test_equal", lhs, rhs));
%!endfunction

%!function m06_assert_equal_text (value, text)
%!  assert (__mplapack_core__ ("scalar_test_equal_string", value, text));
%!endfunction

%!function m06_expect_error (operation, identifier)
%!  try
%!    operation ();
%!    error ("M06 operation unexpectedly succeeded");
%!  catch exception
%!    assert (! strcmp (exception.message, ...
%!                      "M06 operation unexpectedly succeeded"));
%!    if (! isempty (identifier))
%!      assert (strcmp (exception.identifier, identifier));
%!    endif
%!  end_try_catch
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (128);
%!   a = mp ("0.125");
%!   b = mp ("0.25");
%!   a_text = char (a);
%!   b_text = char (b);
%!   default_before = mpbits ();
%!   sum_value = a + b;
%!   difference = b - a;
%!   product = a .* b;
%!   quotient = b ./ a;
%!   assert (strcmp (class (sum_value), "mp"));
%!   m06_assert_equal_text (sum_value, "0.375");
%!   m06_assert_equal_text (difference, "0.125");
%!   m06_assert_equal_text (product, "0.03125");
%!   m06_assert_equal_text (quotient, "2");
%!   assert (m06_info (sum_value).precision_bits, int64 (128));
%!   assert (char (a), a_text);
%!   assert (char (b), b_text);
%!   assert (mpbits (), default_before);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (128);
%!   a128 = mp ("0.125");
%!   mpbits (256);
%!   b256 = mp ("0.25");
%!   mpbits (512);
%!   c512 = mp ("0.5");
%!   mpbits (4096);
%!   operations = {a128 + b256, b256 + a128, ...
%!                 a128 - b256, b256 - a128, ...
%!                 a128 .* c512, c512 .* a128, ...
%!                 c512 ./ b256, b256 ./ c512};
%!   expected_precision = int64 ([256, 256, 256, 256, ...
%!                                512, 512, 512, 512]);
%!   expected_text = {"0.375", "0.375", "-0.125", "0.125", ...
%!                    "0.0625", "0.0625", "2", "0.5"};
%!   for i = 1:numel (operations)
%!     assert (m06_info (operations{i}).precision_bits, ...
%!             expected_precision(i));
%!     m06_assert_equal_text (operations{i}, expected_text{i});
%!   endfor
%!   assert (m06_info (a128).precision_bits, int64 (128));
%!   assert (m06_info (b256).precision_bits, int64 (256));
%!   assert (m06_info (c512).precision_bits, int64 (512));
%!   assert (mpbits (), uint64 (4096));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (128);
%!   lhs = mp ("0.1");
%!   mpbits (256);
%!   rhs = mp ("0.2");
%!   mpbits (4096);
%!   first = {lhs + rhs, lhs - rhs, lhs .* rhs, lhs ./ rhs};
%!   mpbits (32);
%!   second = {lhs + rhs, lhs - rhs, lhs .* rhs, lhs ./ rhs};
%!   for i = 1:numel (first)
%!     assert (m06_info (first{i}).precision_bits, int64 (256));
%!     assert (m06_info (second{i}).precision_bits, int64 (256));
%!     m06_assert_equal (first{i}, second{i});
%!     text = char (first{i});
%!     mpbits (256);
%!     round_trip = mp (text);
%!     m06_assert_equal (first{i}, round_trip);
%!     mpbits (32);
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (128);
%!   value = mp ("1.25");
%!   mpbits (4096);
%!   results = {value + 0.5, 0.5 + value, ...
%!              value - 0.5, 0.5 - value, ...
%!              value .* 0.5, 0.5 .* value, ...
%!              value ./ 0.5, 0.5 ./ value};
%!   expected = {"1.75", "1.75", "0.75", "-0.75", ...
%!               "0.625", "0.625", "2.5", "0.4"};
%!   for i = 1:numel (results)
%!     assert (strcmp (class (results{i}), "mp"));
%!     assert (m06_info (results{i}).precision_bits, int64 (128));
%!     m06_assert_equal_text (results{i}, expected{i});
%!   endfor
%!   first = value + 0.1;
%!   mpbits (32);
%!   second = value + 0.1;
%!   m06_assert_equal (first, second);
%!   assert (m06_info (first).precision_bits, int64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   base = mp ("1");
%!   decimal_result = base + mp ("0.1");
%!   binary64_result = base + 0.1;
%!   assert (! __mplapack_core__ (
%!     "scalar_test_equal", decimal_result, binary64_result));
%!   dyadic_text = base + mp ("0.125");
%!   dyadic_double = base + 0.125;
%!   m06_assert_equal (dyadic_text, dyadic_double);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (2);
%!   lhs = mp ("1");
%!   rhs = mp ("0.25");
%!   tied = lhs + rhs;
%!   assert (m06_info (tied).precision_bits, int64 (2));
%!   m06_assert_equal_text (tied, "1");
%!   for bits = [2, 8, 32]
%!     mpbits (bits);
%!     a = mp ("0.1");
%!     b = mp ("0.2");
%!     values = {a + b, a - b, a .* b, a ./ b};
%!     for i = 1:numel (values)
%!       assert (m06_info (values{i}).precision_bits, int64 (bits));
%!       text = char (values{i});
%!       m06_assert_equal (values{i}, mp (text));
%!     endfor
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (333);
%!   finite = mp ("1.5");
%!   positive_zero = mp (0.0);
%!   negative_zero = mp (-0.0);
%!   positive_infinity = mp (Inf);
%!   negative_infinity = mp (-Inf);
%!   not_a_number = mp (NaN);
%!   positive = +finite;
%!   negative = -finite;
%!   m06_assert_equal (positive, finite);
%!   m06_assert_equal_text (negative, "-1.5");
%!   assert (m06_info (positive).precision_bits, int64 (333));
%!   assert (m06_info (negative).precision_bits, int64 (333));
%!   assert (m06_info (-positive_zero).is_zero);
%!   assert (m06_info (-positive_zero).signbit);
%!   assert (m06_info (-negative_zero).is_zero);
%!   assert (! m06_info (-negative_zero).signbit);
%!   assert (m06_info (-positive_infinity).is_infinite);
%!   assert (m06_info (-positive_infinity).signbit);
%!   assert (m06_info (-negative_infinity).is_infinite);
%!   assert (! m06_info (-negative_infinity).signbit);
%!   assert (m06_info (-not_a_number).is_nan);
%!   alias = +finite;
%!   clear finite;
%!   m06_assert_equal_text (alias, "1.5");
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! one = mp ("1");
%! negative_one = mp ("-1");
%! positive_zero = mp (0.0);
%! negative_zero = mp (-0.0);
%! positive_infinity = mp (Inf);
%! negative_infinity = mp (-Inf);
%! not_a_number = mp (NaN);
%! assert (m06_info (positive_infinity + one).is_infinite);
%! assert (m06_info (positive_infinity + negative_infinity).is_nan);
%! assert (m06_info (not_a_number + one).is_nan);
%! assert (m06_info (not_a_number - one).is_nan);
%! assert (m06_info (positive_infinity - positive_infinity).is_nan);
%! assert (m06_info (positive_infinity - negative_infinity).is_infinite);
%! assert (m06_info (one - positive_infinity).is_infinite);
%! assert (m06_info (one - positive_infinity).signbit);
%! assert (m06_info (one .* positive_infinity).is_infinite);
%! assert (m06_info (positive_zero .* positive_infinity).is_nan);
%! assert (m06_info (not_a_number .* one).is_nan);
%! assert (m06_info (not_a_number ./ one).is_nan);
%! result = one ./ positive_zero;
%! assert (m06_info (result).is_infinite && ! m06_info (result).signbit);
%! result = one ./ negative_zero;
%! assert (m06_info (result).is_infinite && m06_info (result).signbit);
%! result = negative_one ./ positive_zero;
%! assert (m06_info (result).is_infinite && m06_info (result).signbit);
%! result = negative_one ./ negative_zero;
%! assert (m06_info (result).is_infinite && ! m06_info (result).signbit);
%! assert (m06_info (positive_zero ./ positive_zero).is_nan);
%! result = one ./ positive_infinity;
%! assert (m06_info (result).is_zero && ! m06_info (result).signbit);
%! assert (m06_info (positive_infinity ./ positive_infinity).is_nan);
%! assert (m06_info (positive_infinity ./ one).is_infinite);
%! result = positive_zero + negative_zero;
%! assert (m06_info (result).is_zero && ! m06_info (result).signbit);
%! result = negative_zero + negative_zero;
%! assert (m06_info (result).is_zero && m06_info (result).signbit);
%! result = positive_zero - positive_zero;
%! assert (m06_info (result).is_zero && ! m06_info (result).signbit);
%! result = negative_zero - positive_zero;
%! assert (m06_info (result).is_zero && m06_info (result).signbit);
%! result = negative_zero .* one;
%! assert (m06_info (result).is_zero && m06_info (result).signbit);
%! result = negative_zero .* negative_one;
%! assert (m06_info (result).is_zero && ! m06_info (result).signbit);

%!test
%! a = mp ("1");
%! unsupported_id = "mplapack:mp:UnsupportedOperand";
%! single_value = ones (1, 1, "single");
%! int8_value = ones (1, 1, "int8");
%! uint64_value = ones (1, 1, "uint64");
%! values = {single_value, int8_value, uint64_value, true};
%! operations = {"plus", "minus", "times", "rdivide"};
%! for i = 1:numel (operations)
%!   for j = 1:numel (values)
%!     operand = values{j};
%!     m06_expect_binary_error (
%!       operations{i}, a, operand, unsupported_id);
%!     m06_expect_binary_error (
%!       operations{i}, operand, a, unsupported_id);
%!   endfor
%! endfor
%! m06_expect_binary_error ("plus", a, cell (1, 1), unsupported_id);
%! m06_expect_binary_error ("plus", cell (1, 1), a, unsupported_id);
%! m06_expect_binary_error ("plus", a, struct (), unsupported_id);
%! m06_expect_binary_error ("plus", struct (), a, unsupported_id);

%!test
%! a = mp ("1");
%! complex_id = "mplapack:mp:ComplexUnsupported";
%! m06_expect_binary_error ("plus", a, 1 + 2i, complex_id);
%! m06_expect_binary_error ("plus", 1 + 2i, a, complex_id);
%! m06_expect_binary_error ("minus", a, 1 + 2i, complex_id);
%! m06_expect_binary_error ("times", a, 1 + 2i, complex_id);
%! m06_expect_binary_error ("rdivide", a, 1 + 2i, complex_id);

%!test
%! a = mp ("1");
%! matrix_id = "mplapack:mp:MatrixUnsupported";
%! m06_expect_binary_error ("plus", a, [1, 2], matrix_id);
%! m06_expect_binary_error ("plus", [1, 2], a, matrix_id);
%! m06_expect_binary_error ("minus", a, ones (2), matrix_id);
%! m06_expect_binary_error ("times", a, [1; 2], matrix_id);
%! m06_expect_binary_error ("rdivide", a, [1, 2], matrix_id);

%!test
%! a = mp ("1");
%! b = mp ("2");
%! unsupported = {@() a / b, ...
%!                @() a ^ b, @() a .^ b, @() sin (a), ...
%!                @() exp (a), @() sqrt (a), @() a == b, ...
%!                @() a ~= b, @() a < b};
%! for i = 1:numel (unsupported)
%!   m06_expect_error (unsupported{i}, "");
%! endfor

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   a = mp ("1.25");
%!   b = mp ("0.5");
%!   result = a + b;
%!   expected_text = char (result);
%!   assert (double (result), 1.75);
%!   assert (evalc ("disp (result)"), [expected_text, "\n"]);
%!   round_trip = mp (expected_text);
%!   m06_assert_equal (result, round_trip);
%!   clear a b;
%!   m06_assert_equal_text (result, "1.75");
%!   assigned = result;
%!   clear result;
%!   m06_assert_equal_text (assigned, "1.75");
%!   assert (mpbits (), uint64 (512));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
