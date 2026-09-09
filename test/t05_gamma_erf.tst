## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   five = mp ('5');
%!   assert (isequal (gamma (five), mp ('24')));
%!   gl = gammaln (five);
%!   assert (double (abs (gl-log (gamma (five)))) < 1e-50);
%!   assert (double (abs (lgamma (five)-gl)) < 1e-50);
%!   assert (double (abs (erf (mp ('0')))) == 0);
%!   assert (double (abs (erf (mp ('1'))+erfc (mp ('1'))-mp ('1'))) < 1e-50);
%!   assert (erfc (mp ('100')) > 0);
%!   assert (isinf (gamma (mp ('0'))) && ! signbit (gamma (mp ('0'))));
%!   assert (isinf (gamma (mp ('-0'))) && signbit (gamma (mp ('-0'))));
%!   assert (isinf (gamma (mp ('-1'))));
%!   assert (isinf (gammaln (mp ('0'))));
%!   assert (isnan (gamma (mp ('NaN'))));
%!   V = gamma (mp ({'1','2';'3','4'}));
%!   assert (double (norm (V-mp ({'1','1';'2','6'}), "fro")) < 1e-50);
%!   try
%!     gamma (mp ('1','2'));
%!     error ("expected complex gamma rejection");
%!   catch err
%!     assert (strcmp (err.identifier, "mplapack:mp:ComplexUnsupported"));
%!   end_try_catch
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
%!     e = erf (tiny);
%!     c = erfc (tiny);
%!     assert (e > 0 && c < mp ('1'));
%!     assert (double (abs (e+c-mp ('1'))) < 1e-200);
%!     assert (isequal (gamma (mp ('5')), mp ('24')));
%!     assert (__mplapack_core__ ("scalar_test_info", e).precision_bits == uint64 (bits));
%!     assert (__mplapack_core__ ("scalar_test_info", gammaln (mp ('5'))).precision_bits == uint64 (bits));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
