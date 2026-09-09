## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   Z = mp ({'0','0';'0','0'});
%!   assert (double (norm (expm (Z)-eye (2, "like", Z), "fro")) < 1e-50);
%!   D = mp ({'1','0';'0','2'});
%!   ED = expm (D);
%!   assert (double (ED(1,1)-exp (mp ('1'))) < 1e-50);
%!   assert (double (ED(2,2)-exp (mp ('2'))) < 1e-50);
%!   SD = sqrtm (D);
%!   assert (double (norm (SD*SD-D, "fro")) < 1e-50);
%!   [SD, sqrt_error] = sqrtm (D);
%!   assert (double (sqrt_error) < 1e-50);
%!   LD = logm (D);
%!   assert (double (norm (expm (LD)-D, "fro")) < 1e-45);
%!   A = mp ({'0','1';'-2','-3'});
%!   EA = expm (A);
%!   assert (double (norm (EA*expm (-A)-eye (2, "like", EA), "fro")) < 1e-45);
%!   C1 = mp ({'1','0';'0','2'});
%!   C2 = mp ({'3','0';'0','4'});
%!   assert (double (norm (expm (C1+C2)-expm (C1)*expm (C2), "fro")) < 1e-45);
%!   N = mp ({'1','10';'0','1'});
%!   EN = expm (N);
%!   assert (double (EN(1,1)-exp (mp ('1'))) < 1e-45);
%!   assert (double (EN(1,2)-mp ('10')*exp (mp ('1'))) < 1e-45);
%!   MN = mp ({'-1','0';'0','4'});
%!   SMN = sqrtm (MN);
%!   assert (double (norm (SMN*SMN-MN, "fro")) < 1e-45);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for bits = [1024, 2048]
%!     mpbits (bits);
%!     limit = 1500;
%!     if (bits == 1024), limit = 700; endif
%!     tiny = mp ('1');
%!     for k = 1:limit, tiny = tiny * mp ('0.5'); endfor
%!     A = mp ({'0','0';'0','0'});
%!     A(1,1) = tiny;
%!     A(2,2) = -tiny;
%!     E = expm (A);
%!     assert (double (norm (E*expm (-A)-eye (2, "like", E), "fro")) < 1e-12);
%!     assert (__mplapack_core__ ("matrix_test_info", E).precision_bits == uint64 (bits));
%!     L = logm (mp ({'1','0';'0','2'}));
%!     assert (__mplapack_core__ ("matrix_test_info", L).precision_bits == uint64 (bits));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
