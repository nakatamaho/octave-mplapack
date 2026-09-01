## SPDX-License-Identifier: BSD-2-Clause

%!function info = m04_precision_info (value)
%!  info = __mplapack_core__ ("scalar_test_info", value);
%!endfunction

%!function m04_expect_precision_error (operation, expected_identifier)
%!  before = mpbits ();
%!  try
%!    operation ();
%!    error ("M04 invalid precision unexpectedly succeeded");
%!  catch exception
%!    assert (strcmp (exception.identifier, expected_identifier));
%!  end_try_catch
%!  assert (mpbits (), before);
%!endfunction

%!test
%! assert (mpbits (), uint64 (512));
%! assert (mpdigits (), uint64 (154));
%! assert (isa (mpbits (), "uint64"));
%! assert (isa (mpdigits (), "uint64"));
%! assert (__mplapack_core__ ("module_test_locked"));

%!test
%! saved = mpbits ();
%! mpfr_default = __mplapack_core__ (
%!   "precision_test_mpfr_global_bits");
%! unwind_protect
%!   mpbits (256);
%!   mpdigits (100);
%!   value = mp ("0.1");
%!   assert (m04_precision_info (value).precision_bits, int64 (333));
%!   assert (__mplapack_core__ (
%!     "precision_test_mpfr_global_bits"), mpfr_default);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   assert (mpbits (128), uint64 (128));
%!   assert (mpbits (), uint64 (128));
%!   assert (mpdigits (), uint64 (38));
%!   assert (mpbits (256), uint64 (256));
%!   assert (mpbits (), uint64 (256));
%!   assert (mpbits (512), uint64 (512));
%!   assert (mpdigits (), uint64 (154));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   requests = uint64 ([1, 10, 38, 100, 1000]);
%!   expected_bits = uint64 ([4, 34, 127, 333, 3322]);
%!   for i = 1:numel (requests)
%!     assert (mpdigits (requests(i)), requests(i));
%!     assert (mpbits (), expected_bits(i));
%!     assert (mpdigits (), requests(i));
%!   endfor
%!   mpbits (332);
%!   assert (mpdigits (), uint64 (99));
%!   mpbits (333);
%!   assert (mpdigits (), uint64 (100));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (128);
%!   value_128 = mp ("0.1");
%!   mpbits (256);
%!   value_256 = mp ("0.1");
%!   mpbits (512);
%!   value_512 = mp ("0.1");
%!   assigned = value_128;
%!   copied = mp (value_128);
%!   assert (m04_precision_info (value_128).precision_bits, int64 (128));
%!   assert (m04_precision_info (value_256).precision_bits, int64 (256));
%!   assert (m04_precision_info (value_512).precision_bits, int64 (512));
%!   assert (m04_precision_info (assigned).precision_bits, int64 (128));
%!   assert (m04_precision_info (copied).precision_bits, int64 (128));
%!   assert (__mplapack_core__ (
%!     "scalar_test_equal_string", value_128, "0.1"));
%!   assert (__mplapack_core__ (
%!     "scalar_test_equal", value_128, assigned));
%!   assert (__mplapack_core__ (
%!     "scalar_test_equal", value_128, copied));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   assert (mpdigits (100), uint64 (100));
%!   assert (mpbits (), uint64 (333));
%!   value = mp ("1");
%!   assert (m04_precision_info (value).precision_bits, int64 (333));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for bits = [128, 256, 512]
%!     mpbits (bits);
%!     decimal = mp ("0.1");
%!     binary64 = mp (0.1);
%!     assert (! __mplapack_core__ (
%!       "scalar_test_equal", decimal, binary64));
%!     dyadic_text = mp ("0.125");
%!     dyadic_double = mp (0.125);
%!     assert (__mplapack_core__ (
%!       "scalar_test_equal", dyadic_text, dyadic_double));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   assert (mpbits (uint8 (64)), uint64 (64));
%!   assert (mpbits (uint32 (256)), uint64 (256));
%!   assert (mpbits (int64 (512)), uint64 (512));
%!   assert (mpbits (single (1024)), uint64 (1024));
%!   assert (mpdigits (uint64 (100)), uint64 (100));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   maximum_bits = uint64 (intmax ("int64")) - uint64 (256);
%!   assert (mpbits (uint64 (1)), uint64 (1));
%!   assert (mpbits (maximum_bits), maximum_bits);
%!   maximum_digits = mpdigits ();
%!   assert (mpdigits (maximum_digits), maximum_digits);
%!   assert (mpbits () <= maximum_bits);
%!   m04_expect_precision_error (
%!     @() mpdigits (maximum_digits + uint64 (1)),
%!     "mplapack:mpdigits:PrecisionOverflow");
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   invalid_id = "mplapack:mpbits:InvalidPrecision";
%!   m04_expect_precision_error (@() mpbits (0), invalid_id);
%!   m04_expect_precision_error (@() mpbits (-1), invalid_id);
%!   m04_expect_precision_error (@() mpbits (128.5), invalid_id);
%!   m04_expect_precision_error (@() mpbits (NaN), invalid_id);
%!   m04_expect_precision_error (@() mpbits (Inf), invalid_id);
%!   m04_expect_precision_error (@() mpbits (1 + 2i), invalid_id);
%!   m04_expect_precision_error (@() mpbits ([128, 256]), invalid_id);
%!   m04_expect_precision_error (@() mpbits (ones (2)), invalid_id);
%!   m04_expect_precision_error (@() mpbits ("128"), invalid_id);
%!   m04_expect_precision_error (@() mpbits ({128}), invalid_id);
%!   m04_expect_precision_error (@() mpbits (struct ()), invalid_id);
%!   m04_expect_precision_error (@() mpbits (2^53 + 2), invalid_id);
%!   m04_expect_precision_error (
%!     @() mpbits (intmax ("int64")),
%!     "mplapack:mpbits:PrecisionOverflow");
%!   assert (mpbits (), uint64 (256));
%!
%!   digits_id = "mplapack:mpdigits:InvalidPrecision";
%!   m04_expect_precision_error (@() mpdigits (0), digits_id);
%!   m04_expect_precision_error (@() mpdigits (-1), digits_id);
%!   m04_expect_precision_error (@() mpdigits (10.5), digits_id);
%!   m04_expect_precision_error (@() mpdigits (NaN), digits_id);
%!   m04_expect_precision_error (@() mpdigits (Inf), digits_id);
%!   m04_expect_precision_error (@() mpdigits (1 + 2i), digits_id);
%!   m04_expect_precision_error (@() mpdigits ([10, 20]), digits_id);
%!   m04_expect_precision_error (
%!     @() mpdigits (intmax ("int64")),
%!     "mplapack:mpdigits:PrecisionOverflow");
%!   assert (mpbits (), uint64 (256));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!error <zero or one precision argument> mpbits (1, 2)
%!error <zero or one precision argument> mpdigits (1, 2)
