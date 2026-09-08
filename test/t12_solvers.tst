## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   tiny = mp ("1");
%!   for k = 1:700, tiny = tiny * mp ("0.5"); endfor
%!   target = mp ("1") + tiny;
%!   [root, fval, info, output] = fzero (@(value) value - target, ...
%!                                      mp ({"0", "2"}));
%!   assert (info == 1);
%!   assert (root == target);
%!   assert (fval == mp ("0"));
%!   assert (output.iterations >= 0 && output.funcCount >= 2);
%!   assert (double (target) == 1);
%!   [expanded, unused, expanded_info] = fzero (@(value) value - mp ("1"), mp ("0"));
%!   assert (expanded == mp ("1") && expanded_info == 1);
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   target = mp ("1.25");
%!   options = struct ("TolX", mp ("1e-100"), "MaxIter", 600);
%!   [root, fval, info] = fzero (@(value) value * value - target * target, ...
%!                               mp ({"0", "2"}), options);
%!   assert (info == 1);
%!   assert (abs (root - target) < mp ("1e-100"));
%!   assert (abs (fval) < mp ("1e-100"));
%!   rejected = false;
%!   try
%!     fzero (@(value) double (value), mp ({"-1", "1"}));
%!   catch
%!     rejected = true;
%!   end_try_catch
%!   assert (rejected, "double-valued fzero callbacks must be rejected");
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   initial = mp ([0.8, 1.2]);
%!   target_a = mp ("1.125");
%!   target_b = mp ("0.75");
%!   [solution, residual, info, output] = fsolve ( ...
%!     @(value) [value(1) - target_a; value(2) + target_b], initial);
%!   assert (info == 1);
%!   assert (abs (solution(1) - target_a) < mp ("1e-60"));
%!   assert (abs (solution(2) + target_b) < mp ("1e-60"));
%!   assert (norm (residual) < mp ("1e-60"));
%!   assert (output.iterations >= 1 && output.funcCount >= 3);
%!   jacobian_options = struct ("Jacobian", "on");
%!   [with_jacobian, jacobian_residual, jacobian_info] = fsolve ( ...
%!     @t12_linear_system_callback, mp (zeros (2, 1)), jacobian_options);
%!   assert (jacobian_info == 1);
%!   assert (with_jacobian(1) == mp ("1.375"));
%!   assert (with_jacobian(2) == mp ("2.75"));
%!   assert (norm (jacobian_residual) == mp ("0"));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   tiny = mp ("1");
%!   for k = 1:700, tiny = tiny * mp ("0.5"); endfor
%!   target = mp ("1") + tiny;
%!   [solution, residual] = fsolve (@(value) value - target, mp ("0"));
%!   assert (abs (solution - target) < mp ("1e-150"));
%!   assert (abs (residual) < mp ("1e-150"));
%!   rejected = false;
%!   try
%!     fsolve (@(value) double (value), mp ("0"));
%!   catch
%!     rejected = true;
%!   end_try_catch
%!   assert (rejected, "double-valued fsolve callbacks must be rejected");
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect
