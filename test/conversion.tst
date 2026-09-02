## SPDX-License-Identifier: BSD-2-Clause

%!function bits = m05_double_bits (value)
%!  bits = typecast (value, "uint64");
%!endfunction

%!function m05_expect_unsupported (operation)
%!  try
%!    operation ();
%!    error ("M05 unsupported operation unexpectedly succeeded");
%!  catch exception
%!    assert (! strcmp (exception.message, ...
%!                      "M05 unsupported operation unexpectedly succeeded"));
%!  end_try_catch
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   precisions = [128, 256, 333, 512, 1024];
%!   texts = {"1", "-1", "0.125", "0.1", ...
%!            "1.234567890123456789", "1e100", "1e-100"};
%!   for precision = precisions
%!     mpbits (precision);
%!     for i = 1:numel (texts)
%!       original = mp (texts{i});
%!       canonical = char (original);
%!       assert (ischar (canonical));
%!       assert (rows (canonical), 1);
%!       assert (! isempty (regexp (canonical, ...
%!         "^-?[1-9](\\.[0-9]+)?e[+-](0|[1-9][0-9]*)$", "once")));
%!       assert (isempty (strfind (canonical, "payload_")));
%!       assert (isempty (strfind (
%!         canonical, "mplapack_mpfr_scalar_internal")));
%!       reconstructed = mp (canonical);
%!       assert (__mplapack_core__ (
%!         "scalar_test_equal", original, reconstructed));
%!     endfor
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (128);
%!   old_value = mp ("0.1");
%!   before = char (old_value);
%!   before_double = m05_double_bits (double (old_value));
%!   mpbits (1024);
%!   assert (char (old_value), before);
%!   assert (m05_double_bits (double (old_value)), before_double);
%!   new_value = mp ("0.1");
%!   assert (! strcmp (char (new_value), before));
%!   mpbits (128);
%!   reconstructed = mp (before);
%!   assert (__mplapack_core__ (
%!     "scalar_test_equal", old_value, reconstructed));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! positive_zero_mp = mp (0.0);
%! negative_zero_mp = mp (-0.0);
%! positive_infinity_mp = mp (Inf);
%! negative_infinity_mp = mp (-Inf);
%! not_a_number_mp = mp (NaN);
%! values = {positive_zero_mp, negative_zero_mp, positive_infinity_mp, ...
%!           negative_infinity_mp, not_a_number_mp};
%! expected = {"0", "-0", "Inf", "-Inf", "NaN"};
%! for i = 1:numel (values)
%!   assert (char (values{i}), expected{i});
%!   assert (evalc ("disp (values{i})"), [expected{i}, "\n"]);
%!   reconstructed = mp (char (values{i}));
%!   info = __mplapack_core__ ("scalar_test_info", reconstructed);
%!   if (i == 1)
%!     assert (info.is_zero && ! info.signbit);
%!   elseif (i == 2)
%!     assert (info.is_zero && info.signbit);
%!   elseif (i == 3)
%!     assert (info.is_infinite && ! info.signbit);
%!   elseif (i == 4)
%!     assert (info.is_infinite && info.signbit);
%!   else
%!     assert (info.is_nan);
%!   endif
%! endfor

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   inputs = [0.0, -0.0, 1.0, -1.0, 0.5, 0.1, realmin, realmax, ...
%!             realmin * eps, 1 + eps];
%!   for input = inputs
%!     converted = double (mp (input));
%!     assert (m05_double_bits (converted), m05_double_bits (input));
%!   endfor
%!   assert (double (mp ("0.1")), 0.1);
%!   assert (double (mp ("0.5")), 0.5);
%!   assert (double (mp ("0.125")), 0.125);
%!   assert (double (mp ("1.234567890123456789")), ...
%!           1.2345678901234567);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! positive_zero = double (mp (0.0));
%! negative_zero = double (mp (-0.0));
%! assert (m05_double_bits (positive_zero), m05_double_bits (0.0));
%! assert (m05_double_bits (negative_zero), m05_double_bits (-0.0));
%! assert (isinf (double (mp (Inf))) && double (mp (Inf)) > 0);
%! assert (isinf (double (mp (-Inf))) && double (mp (-Inf)) < 0);
%! assert (isnan (double (mp (NaN))));

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   halfway = mp (...
%!     "1.00000000000000011102230246251565404236316680908203125");
%!   assert (m05_double_bits (double (halfway)), ...
%!           m05_double_bits (1.0));
%!   assert (isinf (double (mp ("1e10000"))));
%!   assert (isinf (double (mp ("-1e10000"))));
%!   positive_underflow = double (mp ("1e-10000"));
%!   negative_underflow = double (mp ("-1e-10000"));
%!   assert (m05_double_bits (positive_underflow), ...
%!           m05_double_bits (0.0));
%!   assert (m05_double_bits (negative_underflow), ...
%!           m05_double_bits (-0.0));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (128);
%!   value = mp ("0.1");
%!   canonical = char (value);
%!   format short;
%!   short_output = evalc ("disp (value)");
%!   format long;
%!   long_output = evalc ("disp (value)");
%!   assert (short_output, [canonical, "\n"]);
%!   assert (long_output, short_output);
%!   mpbits (512);
%!   assert (evalc ("disp (value)"), short_output);
%!   bare_output = evalc ("value");
%!   assert (! isempty (strfind (bare_output, canonical)));
%!   assert (isempty (strfind (bare_output, "payload_")));
%!   assert (isempty (strfind (
%!     bare_output, "mplapack_mpfr_scalar_internal")));
%!   assert (mpbits (), uint64 (512));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (333);
%!   original = mp ("0.1");
%!   assigned = original;
%!   copied = mp (original);
%!   assert (char (assigned), char (original));
%!   assert (char (copied), char (original));
%!   assert (m05_double_bits (double (assigned)), ...
%!           m05_double_bits (double (original)));
%!   assert (m05_double_bits (double (copied)), ...
%!           m05_double_bits (double (original)));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! a = mp ("1");
%! b = mp ("2");
%! operations = {@() mldivide (a, b), @() sin (a), ...
%!               @() exp (a), @() sqrt (a), @() ["value=", a]};
%! for i = 1:numel (operations)
%!   m05_expect_unsupported (operations{i});
%! endfor

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (8192);
%!   value = mp ("0.1");
%!   canonical = char (value);
%!   reconstructed = mp (canonical);
%!   assert (__mplapack_core__ (
%!     "scalar_test_equal", value, reconstructed));
%!   assert (double (value), 0.1);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
