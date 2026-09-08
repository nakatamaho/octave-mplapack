## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved_bits = mpbits ();
%! saved_rng = mprng ("state");
%! unwind_protect
%!   mpbits (128);
%!   mprng ("seed", uint64 (7));
%!   value = mprand ();
%!   encoded = __mplapack_core__ ("serialize", value);
%!   assert (strcmp (encoded.elements{1}, ...
%!                  "6.0142955925964410792087642635995321571e-1"));
%!   mprng ("seed", uint64 (7));
%!   repeat = mprand ();
%!   assert (isequal (__mplapack_core__ ("serialize", value), ...
%!                   __mplapack_core__ ("serialize", repeat)));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%!   mprng ("state", saved_rng);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! saved_rng = mprng ("state");
%! path = "/tmp/mplapack-t09-rng-state.mat";
%! unwind_protect
%!   mpbits (512);
%!   mprng ("seed", uint64 (123456789));
%!   mprand (4, 1);
%!   checkpoint = mprng ("state");
%!   expected = mprandn (3, 1);
%!   mprng ("state", checkpoint);
%!   restored = mprandn (3, 1);
%!   assert (isequal (__mplapack_core__ ("serialize", expected), ...
%!                   __mplapack_core__ ("serialize", restored)));
%!   saved_state = checkpoint;
%!   save ("-binary", path, "saved_state");
%!   clear saved_state;
%!   load (path, "saved_state");
%!   assert (isequal (saved_state, checkpoint));
%!   mprng ("state", saved_state);
%!   restored_again = mprand (2, 2);
%!   mprng ("state", checkpoint);
%!   expected_again = mprand (2, 2);
%!   assert (isequal (__mplapack_core__ ("serialize", restored_again), ...
%!                   __mplapack_core__ ("serialize", expected_again)));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%!   mprng ("state", saved_rng);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! saved_rng = mprng ("state");
%! unwind_protect
%!   for bits = [128, 512, 1024, 2048]
%!     mpbits (bits);
%!     mprng ("seed", uint64 (bits + 17));
%!     value = mprand (2, 1);
%!     encoded = __mplapack_core__ ("serialize", value);
%!     assert (encoded.precision_bits == uint64 (bits));
%!     assert (all (value >= mp ("0")) && all (value < mp ("1")));
%!     if (bits >= 1024)
%!       assert (value(1) != mp (double (value(1))), ...
%!               "random p-bit value was reduced to binary64");
%!     endif
%!   endfor
%!   mpbits (128);
%!   mprng ("seed", uint64 (9));
%!   low = mprand ();
%!   mpbits (512);
%!   high = mprand ();
%!   assert (__mplapack_core__ ("serialize", low).precision_bits == uint64 (128));
%!   assert (__mplapack_core__ ("serialize", high).precision_bits == uint64 (512));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%!   mprng ("state", saved_rng);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! saved_rng = mprng ("state");
%! unwind_protect
%!   mpbits (256);
%!   mprng ("seed", uint64 (20260908));
%!   uniform = mprand (256, 1);
%!   normal = mprandn (256, 1);
%!   assert (all (uniform >= mp ("0")) && all (uniform < mp ("1")));
%!   uniform_mean = double (mean (uniform));
%!   uniform_second = double (mean (uniform .* uniform));
%!   normal_mean = double (mean (normal));
%!   normal_second = double (mean (normal .* normal));
%!   assert (uniform_mean > 0.35 && uniform_mean < 0.65);
%!   assert (uniform_second > 0.15 && uniform_second < 0.50);
%!   assert (normal_mean > -0.35 && normal_mean < 0.35);
%!   assert (normal_second > 0.50 && normal_second < 1.50);
%!   integers = mprandi (0, 2, [6000, 1]);
%!   integer_values = double (integers);
%!   counts = [0, 0, 0];
%!   for index = 1:numel (integer_values)
%!     counts (integer_values(index) + 1) += 1;
%!   endfor
%!   assert (all (counts > 1700 & counts < 2300));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%!   mprng ("state", saved_rng);
%! end_unwind_protect
