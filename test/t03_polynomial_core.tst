## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   p = mp ({'1','-3','2'});
%!   x = mp ([0,1,2]);
%!   y = polyval (p, x);
%!   assert (double (norm (y-mp ([2,0,0]), "fro")) < 1e-50);
%!   A = mp ({'1','2';'0','3'});
%!   pm = polyvalm (p, A);
%!   assert (double (norm (pm-(A*A-mp ('3')*A+mp ('2')*eye (2, "like", A)), "fro")) < 1e-50);
%!   c = conv (p, mp ([1,4]));
%!   [q,r] = deconv (c, p);
%!   assert (double (norm (q-mp ([1,4]), "fro")) < 1e-50);
%!   assert (double (norm (r, "fro")) < 1e-50);
%!   assert (double (norm (polyder (p)-mp ([2,-3]), "fro")) < 1e-50);
%!   dprod = polyder (p, mp ([1,4]));
%!   assert (double (norm (dprod-polyder (c), "fro")) < 1e-50);
%!   [dq,dd] = polyder (mp ([1,0]), mp ([1,-1]));
%!   assert (double (norm (dq-mp ([0,-1]), "fro")) < 1e-50);
%!   assert (double (norm (dd-mp ([1,-2,1]), "fro")) < 1e-50);
%!   pint = polyint (polyder (p), mp ('7'));
%!   assert (double (norm (pint-mp ([1,-3,7]), "fro")) < 1e-50);
%!   C = compan (p);
%!   assert (size (C) == [2,2]);
%!   assert (double (norm (poly (C)-p, "fro")) < 1e-45);
%!   rr = roots (p);
%!   assert (double (norm (poly (rr)-p, "fro")) < 1e-45);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   pc = mp ([1,0,1]);
%!   rc = roots (pc);
%!   assert (numel (rc) == 2 && ! isreal (rc));
%!   assert (double (norm (poly (rc)-pc, "fro")) < 1e-45);
%!   rv = mp ([1,2,3,4,5]);
%!   pw = poly (rv);
%!   assert (double (norm (poly (roots (pw))-pw, "fro")) < 1e-35);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   tiny = mp ('1');
%!   for k = 1:700, tiny = tiny * mp ('0.5'); endfor
%!   rv = [mp('1'),mp('1')+tiny];
%!   p = poly (rv);
%!   rr = roots (p);
%!   assert (abs (rr(1)-rr(2)) > tiny*mp ('0.5'));
%!   assert (double (norm (poly (rr)-p, "fro")) < 1e-40);
%!   assert (__mplapack_core__ ("matrix_test_info", p).precision_bits == uint64 (1024));
%!   mpbits (2048);
%!   tiny = mp ('1');
%!   for k = 1:1500, tiny = tiny * mp ('0.5'); endfor
%!   p2048 = mp ({'1','-2','1'});
%!   p2048(1,2) = -mp ('2') - tiny;
%!   rr2048 = roots (p2048);
%!   assert (abs (rr2048(1)-rr2048(2)) > tiny*mp ('0.5'));
%!   assert (__mplapack_core__ ("matrix_test_info", rr2048).precision_bits == uint64 (2048));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
