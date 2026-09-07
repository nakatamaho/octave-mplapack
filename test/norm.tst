## SPDX-License-Identifier: BSD-2-Clause

%!function assert_fails (thunk, label)
%!  did_fail = false;
%!  try
%!    thunk ();
%!  catch
%!    did_fail = true;
%!  end_try_catch
%!  assert (did_fail, label);
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   v = mp ([3; 4]);
%!   assert (double (norm (v)), 5, 1e-12);
%!   assert (double (norm (v, 1)), 7, 1e-12);
%!   assert (double (norm (v, 2)), 5, 1e-12);
%!   assert (double (norm (v, Inf)), 4, 1e-12);
%!   assert (double (norm (v, -Inf)), 3, 1e-12);
%!   assert (double (norm (v, "fro")), 5, 1e-12);
%!   assert (double (norm (v, 0)), 2, 1e-12);
%!   assert (double (norm (mp ([1; 2]), 3)), 9^(1 / 3), 1e-12);
%!   scalar = mp ("-3.5");
%!   assert (double (norm (scalar)), 3.5, 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ([3, 0; 0, 4]);
%!   before = double (A);
%!   assert (double (norm (A)), 4, 1e-12);
%!   assert (double (norm (A, 1)), 4, 1e-12);
%!   assert (double (norm (A, 2)), 4, 1e-12);
%!   assert (double (norm (A, Inf)), 4, 1e-12);
%!   assert (double (norm (A, "fro")), 5, 1e-12);
%!   assert (double (A), before);
%!   empty = mp (zeros (0, 3));
%!   assert (double (norm (empty)), 0, 1e-12);
%!   assert (double (norm (empty, 1)), 0, 1e-12);
%!   assert (double (norm (empty, Inf)), 0, 1e-12);
%!   assert (double (norm (empty, "fro")), 0, 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   z = mp ([3 + 4i; 0]);
%!   assert (! isreal (z));
%!   assert (double (norm (z)), 5, 1e-12);
%!   assert (double (norm (z, 1)), 5, 1e-12);
%!   assert (double (norm (z, 2)), 5, 1e-12);
%!   assert (double (norm (z, Inf)), 5, 1e-12);
%!   assert (double (norm (z, -Inf)), 0, 1e-12);
%!   Z = mp ([3 + 0i, 0 + 0i; 0 + 0i, 4 + 0i]);
%!   assert (double (norm (Z)), 4, 1e-12);
%!   assert (double (norm (Z, 1)), 4, 1e-12);
%!   assert (double (norm (Z, Inf)), 4, 1e-12);
%!   assert (double (norm (Z, "fro")), 5, 1e-12);
%!   assert (double (norm (Z, 2)), 4, 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for setting = {[1024, 700], [2048, 1500]}
%!     bits = setting{1}(1);
%!     exponent = setting{1}(2);
%!     mpbits (bits);
%!     value = mp ("1");
%!     for k = 1:exponent
%!       value = value ./ mp ("2");
%!     endfor
%!     mpbits (128);
%!     result = norm (value);
%!     info = __mplapack_core__ ("scalar_test_info", result);
%!     assert (info.precision_bits == bits);
%!     assert (__mplapack_core__ ("scalar_test_equal", result, value));
%!     assert (mpbits () == uint64 (128));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   assert (isinf (double (norm (mp ("Inf")))));
%!   assert (isnan (double (norm (mp ("NaN")))));
%!   A = mp ([1, 2; 3, 4]);
%!   assert_fails (@() norm (A, 0), "matrix zero norm must fail");
%!   assert_fails (@() norm (A, 3), "matrix finite p norm must fail");
%!   assert_fails (@() norm (A, -1), "negative finite p norm must fail");
%!   assert_fails (@() norm (A, "rows"), "row norm option must fail");
%!   assert_fails (@() norm (A, NaN), "NaN norm option must fail");
%!   assert_fails (@() norm (A, "cols"), "column norm option must fail");
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
