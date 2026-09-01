## SPDX-License-Identifier: BSD-2-Clause

%!function y = m03_pass_through (x)
%!  y = x;
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (128);
%!   assert (__mplapack_core__ ("scalar_default_precision"), int64 (128));
%!   text_value = mp ("0.1");
%!   double_value = mp (0.1);
%!   text_info = __mplapack_core__ ("scalar_test_info", text_value);
%!   double_info = __mplapack_core__ ("scalar_test_info", double_value);
%!   assert (text_info.precision_bits, int64 (128));
%!   assert (double_info.precision_bits, int64 (128));
%!   assert (! __mplapack_core__ (
%!     "scalar_test_equal", text_value, double_value));
%!   assert (__mplapack_core__ (
%!     "scalar_test_equal_string", text_value, "0.1"));
%!   assert (! __mplapack_core__ (
%!     "scalar_test_equal_double", text_value, 0.1));
%!   assert (__mplapack_core__ (
%!     "scalar_test_equal_double", double_value, 0.1));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! text_value = mp ("0.125");
%! double_value = mp (0.125);
%! single_quoted = mp ('0.125');
%! assert (__mplapack_core__ (
%!   "scalar_test_equal", text_value, double_value));
%! assert (__mplapack_core__ (
%!   "scalar_test_equal", text_value, single_quoted));
%! assert (__mplapack_core__ (
%!   "scalar_test_equal_string", text_value, "0.125"));
%! assert (__mplapack_core__ (
%!   "scalar_test_equal_double", double_value, 0.125));

%!test
%! texts = {"0", "1", "-1", "0.125", "0.1", ...
%!          "1.2345678901234567890123456789", "1e100", "1e-100"};
%! for i = 1:numel (texts)
%!   value = mp (texts{i});
%!   assert (__mplapack_core__ (
%!     "scalar_test_equal_string", value, texts{i}));
%! endfor

%!test
%! smallest_subnormal = realmin * eps;
%! for value = [realmin, realmax, 1 + eps, smallest_subnormal]
%!   converted = mp (value);
%!   assert (__mplapack_core__ (
%!     "scalar_test_equal_double", converted, value));
%! endfor

%!test
%! positive = mp (0.0);
%! negative = mp (-0.0);
%! positive_info = __mplapack_core__ ("scalar_test_info", positive);
%! negative_info = __mplapack_core__ ("scalar_test_info", negative);
%! assert (positive_info.is_zero && ! positive_info.signbit);
%! assert (negative_info.is_zero && negative_info.signbit);

%!test
%! positive_inf = __mplapack_core__ ("scalar_test_info", mp (Inf));
%! negative_inf = __mplapack_core__ ("scalar_test_info", mp (-Inf));
%! nan_info = __mplapack_core__ ("scalar_test_info", mp (NaN));
%! assert (positive_inf.is_infinite && ! positive_inf.signbit);
%! assert (negative_inf.is_infinite && negative_inf.signbit);
%! assert (nan_info.is_nan);
%! text_inf = __mplapack_core__ ("scalar_test_info", mp ("Inf"));
%! text_negative_inf = __mplapack_core__ (
%!   "scalar_test_info", mp ("-Inf"));
%! text_nan = __mplapack_core__ ("scalar_test_info", mp ("NaN"));
%! assert (text_inf.is_infinite && ! text_inf.signbit);
%! assert (text_negative_inf.is_infinite && text_negative_inf.signbit);
%! assert (text_nan.is_nan);

%!test
%! value = mp ("1");
%! assert (strcmp (class (value), "mp"));
%! assert (size (value), [1, 1]);
%! assert (rows (value), 1);
%! assert (columns (value), 1);
%! assert (numel (value), 1);
%! assert (isempty (properties (value)));
%! assert (strcmp (strtrim (evalc ("disp (value)")), char (value)));
%! try
%!   value.payload_;
%!   error ("M03 private payload unexpectedly accessible");
%! catch exception
%!   assert (! isempty (strfind (exception.message, "private access")));
%! end_try_catch

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (128);
%!   original = mp ("1.25");
%!   assigned = original;
%!   copied = mp (original);
%!   collection = {original, assigned};
%!   record.value = original;
%!   passed = m03_pass_through (original);
%!   clear original;
%!   for value = {assigned, copied, collection{1}, collection{2}, ...
%!                record.value, passed}
%!     info = __mplapack_core__ ("scalar_test_info", value{1});
%!     assert (info.precision_bits, int64 (128));
%!     assert (__mplapack_core__ (
%!       "scalar_test_equal_string", value{1}, "1.25"));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! value = mp ("1");
%! try
%!   [value, value];
%!   error ("M03 horizontal concatenation unexpectedly succeeded");
%! catch exception
%!   assert (! isempty (strfind (exception.message, "horzcat method failed")));
%! end_try_catch
%! try
%!   [value; value];
%!   error ("M03 vertical concatenation unexpectedly succeeded");
%! catch exception
%!   assert (! isempty (strfind (exception.message, "vertcat method failed")));
%! end_try_catch

%!test
%! a = mp ("1");
%! b = mp ("2");
%! operations = {@() a + b, @() a - b, @() a .* b, @() a ./ b, ...
%!               @() a * b, @() mldivide (a, b)};
%! for i = 1:numel (operations)
%!   try
%!     operations{i} ();
%!     error ("M03 arithmetic unexpectedly succeeded");
%!   catch exception
%!     assert (strcmp (exception.identifier, "mplapack:NotImplemented"));
%!   end_try_catch
%! endfor

%!error <expects exactly one scalar input> mp ()
%!error <expects exactly one scalar input> mp (1, 2)
%!error <complex mp values are not supported> mp (1 + 2i)
%!error <complex mp values are not supported> mp (complex (1, 0))
%!error <dense mp matrices are not implemented before M07> mp ([1, 2])
%!error <dense mp matrices are not implemented before M07> mp ([1; 2])
%!error <dense mp matrices are not implemented before M07> mp ([1, 2; 3, 4])
%!error <cell-based mp matrices are not implemented before M07> mp ({"1", "2"})
%!error <cell-based mp matrices are not implemented before M07> mp ({"1"; "2"})
%!error <text arrays are not implemented before M07> mp (["1"; "2"])
%!error <scalar text must not be empty> mp ("")
%!error <dense mp matrices are not implemented before M07> mp ([])
%!error <invalid scalar text> mp ("abc")
%!error <invalid scalar text> mp ("1.2.3")
%!error <invalid scalar text> mp ("1,5")
%!error <input must be scalar decimal text> mp (single (1))
%!error <input must be scalar decimal text> mp (struct ())
