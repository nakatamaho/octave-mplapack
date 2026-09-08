## SPDX-License-Identifier: BSD-2-Clause

%!function assert_rejected (thunk, label)
%!  rejected = false;
%!  try
%!    thunk ();
%!  catch
%!    rejected = true;
%!  end_try_catch
%!  assert (rejected, label);
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   x = mp ('0.5');
%!
%!   ## These APIs are deliberately not mapped to @mp yet.  The calls must
%!   ## fail at the package boundary instead of converting x to binary64.
%!   assert_rejected (@() gammainc (x, x), ...
%!                    "gammainc must remain behind the semantic audit");
%!   assert_rejected (@() betainc (x, x, x), ...
%!                    "betainc must remain behind the backend audit");
%!   assert_rejected (@() erfinv (x), ...
%!                    "erfinv must remain behind the arbitrary-precision audit");
%!   assert_rejected (@() erfcinv (x), ...
%!                    "erfcinv must remain behind the arbitrary-precision audit");
%!   assert_rejected (@() erfcx (x), ...
%!                    "erfcx must remain behind the arbitrary-precision audit");
%!   assert_rejected (@() expint (x), ...
%!                    "expint must remain behind the semantic audit");
%!   assert_rejected (@() besselj (0, x), ...
%!                    "besselj must remain behind the order audit");
%!   assert_rejected (@() bessely (0, x), ...
%!                    "bessely must remain behind the order audit");
%!   assert_rejected (@() besseli (0, x), ...
%!                    "besseli must remain behind the backend audit");
%!   assert_rejected (@() besselk (0, x), ...
%!                    "besselk must remain behind the backend audit");
%!   assert_rejected (@() airy (0, x), ...
%!                    "airy must remain behind the multi-output audit");
%!   assert_rejected (@() psi (x), ...
%!                    "psi must remain behind the signature audit");
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   tiny = mp ('1');
%!   for k = 1:700, tiny = tiny * mp ('0.5'); endfor
%!   ## The implemented T05 family remains the only special-function path
%!   ## exercised by this milestone and still preserves the operation p-bit.
%!   value = erfc (tiny);
%!   assert (__mplapack_core__ ("scalar_test_info", value).precision_bits == uint64 (1024));
%!   assert (value > mp ('0.9'));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
