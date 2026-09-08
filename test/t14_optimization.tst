## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   target = mp ("1.25");
%!   options = struct ("TolX", mp ("1e-45"), "TolFun", mp ("1e-45"), ...
%!                     "MaxIter", 500);
%!   [argument, value, info, output] = fminbnd ( ...
%!     @(x) (x - target) * (x - target), mp ("0"), mp ("2"), options);
%!   assert (info == 1);
%!   assert (abs (argument - target) < mp ("1e-35"));
%!   assert (value < mp ("1e-65"));
%!   assert (output.funcCount >= 2);
%!   rejected = false;
%!   try
%!     fminbnd (@(x) double (x), mp ("0"), mp ("1"));
%!   catch
%!     rejected = true;
%!   end_try_catch
%!   assert (rejected, "double-valued objectives must be rejected");
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   options = struct ("TolX", mp ("1e-22"), "TolFun", mp ("1e-30"), ...
%!                     "MaxIter", 2000, "MaxFunEvals", 10000);
%!   [argument, value, info] = fminsearch ( ...
%!     @(x) mp ("100") * (x(2) - x(1) * x(1)) ^ 2 ...
%!           + (mp ("1") - x(1)) ^ 2, mp ({"-1.2"; "1"}), options);
%!   assert (info == 1);
%!   assert (abs (argument(1) - mp ("1")) < mp ("1e-12"));
%!   assert (abs (argument(2) - mp ("1")) < mp ("1e-12"));
%!   assert (value < mp ("1e-25"));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   target = mp ({"1.25"; "-0.75"});
%!   options = struct ("TolX", mp ("1e-28"), "TolFun", mp ("1e-35"), ...
%!                     "MaxIter", 800, "MaxFunEvals", 4000);
%!   [argument, value, info] = fminsearch ( ...
%!     @(x) (x(1) - target(1)) ^ 2 + (x(2) - target(2)) ^ 2, ...
%!     mp ({"0"; "0"}), options);
%!   assert (info == 1);
%!   assert (abs (argument(1) - target(1)) < mp ("1e-20"));
%!   assert (abs (argument(2) - target(2)) < mp ("1e-20"));
%!   assert (value < mp ("1e-35"));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   options = struct ("TolX", mp ("1e-70"), "TolFun", mp ("1e-100"), ...
%!                     "MaxIter", 1200);
%!   tiny = mp ("1");
%!   for k = 1:700, tiny = tiny * mp ("0.5"); endfor
%!   target = mp ("1") + tiny;
%!   [argument, value, info] = fminbnd ( ...
%!     @(x) (x - target) * (x - target), mp ("0"), mp ("2"), options);
%!   assert (info == 1);
%!   assert (abs (argument - target) < mp ("1e-60"));
%!   assert (double (target) == 1);
%!   assert (value < mp ("1e-115"));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   options = struct ("TolX", mp ("1e-18"), "TolFun", mp ("1e-25"), ...
%!                     "MaxIter", 1200, "MaxFunEvals", 6000);
%!   [argument, value, info] = fminsearch ( ...
%!     @(x) (mp ("1000000") * x(1) - mp ("3")) ^ 2 ...
%!           + (x(2) - mp ("0.000002")) ^ 2, ...
%!     mp ({"0"; "0"}), options);
%!   assert (info == 1);
%!   assert (abs (mp ("1000000") * argument(1) - mp ("3")) < mp ("1e-10"));
%!   assert (abs (argument(2) - mp ("0.000002")) < mp ("1e-12"));
%!   assert (value < mp ("1e-20"));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect
