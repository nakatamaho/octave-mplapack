% Exact persistence and deterministic arbitrary-precision random values.
if (exist ("mpbits", "file") != 2)
  pkg load mplapack-interop
endif

saved_bits = mpbits ();
saved_state = mprng ("state");
path = "/tmp/mplapack-interop-example.mat";
unwind_protect
  mpbits (512);
  mprng ("seed", uint64 (7));
  A = mp ({"1.234567890123456789", "-0"; "Inf", "NaN"});
  first = mprand (2, 1);
  checkpoint = mprng ("state");
  save ("-binary", path, "A");

  clear A;
  load (path, "A");
  assert (strcmp (class (A), "mp"));
  assert (char (A(1, 1)) == char (mp ("1.234567890123456789")));

  mprng ("state", checkpoint);
  repeat = mprand (2, 1);
  assert (isequal (first, repeat) == false);
  mprng ("seed", uint64 (7));
  assert (isequal (first, mprand (2, 1)));
  fprintf ("serialization/RNG PASS: exact state and value round trip\n");
unwind_protect_cleanup
  mprng ("state", saved_state);
  mpbits (saved_bits);
  if (exist (path, "file")), unlink (path); endif
end_unwind_protect
