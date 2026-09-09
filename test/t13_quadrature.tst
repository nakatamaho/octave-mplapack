## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   options = struct ("AbsTol", mp ("1e-45"), "RelTol", mp ("1e-45"));
%!   [value, err] = integral (@(x) x * x, mp ("0"), mp ("1"), options);
%!   assert (abs (value - mp ("1") / mp ("3")) < mp ("1e-40"));
%!   assert (err < mp ("1e-40"));
%!   [split, unused] = quadgk (@(x) exp (-x), mp ("0"), mp ("1"), ...
%!                             "Waypoints", mp ("0.25"));
%!   assert (abs (split - (mp ("1") - exp (mp ("-1")))) < mp ("1e-35"));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   options = struct ("AbsTol", mp ("1e-35"), "RelTol", mp ("1e-35"));
%!   finite = integral (@(x) 1 / sqrt (x), mp ("0"), mp ("1"), options);
%!   assert (abs (finite - mp ("2")) < mp ("1e-28"));
%!   infinite = integral (@(x) exp (-x), mp ("0"), mp ("Inf"), options);
%!   assert (abs (infinite - mp ("1")) < mp ("1e-28"));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   options = struct ("AbsTol", mp ("1e-100"), "RelTol", mp ("1e-100"));
%!   real_part = integral (@(x) cos (x), mp ("0"), acos (mp ("-1")), options);
%!   complex_part = integral (@(x) exp (i * x), mp ("0"), ...
%!                            acos (mp ("-1")), options);
%!   assert (abs (real_part) < mp ("1e-90"));
%!   assert (abs (complex_part - mp ("0", "2")) < mp ("1e-90"));
%!   ## 512-bit arithmetic resolves this result well beyond binary64.
%!   tiny = mp ("1") / (mp ("10") ^ 80);
%!   high = integral (@(x) tiny * x, mp ("0"), mp ("2"), options);
%!   assert (abs (high - mp ("2") * tiny) < mp ("1e-90"));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect
