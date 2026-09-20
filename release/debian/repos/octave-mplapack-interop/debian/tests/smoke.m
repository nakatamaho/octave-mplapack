% P04 draft autopkgtest for the installed mplapack-interop package.
% This is package-level evidence only; P04 remains incomplete until the
% Debian binary package and testbed lifecycle are available.
pkg ("load", "mplapack-interop");

assert (mpbits () == 512);
mpbits (128);

% Real arithmetic, square solve, and dense factorization APIs.
A = mp ({"1", "2"; "3", "4"});
B = A * A;
assert (strcmp (class (B), "mp"));
assert (rows (B) == 2 && columns (B) == 2);

b = mp ({"1"; "2"});
x = A \ b;
assert (double (x (1)) == 0);
assert (double (x (2)) == 0.5);

S = mp ({"4", "2"; "2", "10"});
Rchol = chol (S);
assert (double (Rchol (1, 1)) == 2);
assert (double (Rchol (1, 2)) == 1);
assert (double (Rchol (2, 2)) == 3);

[Q, Rqr] = qr (A);
assert (double (norm (Q * Rqr - A, "fro")) < 1e-30);

Ap = mp ([1, 0, 0; 0, 4, 0; 0, 0, 2]);
[Qp, Rp, P] = qr (Ap);
assert (double (norm (Qp * Rp - Ap * P, "fro")) < 1e-30);

[L, U, PLU] = lu (A);
assert (double (norm (PLU * A - L * U, "fro")) < 1e-30);

% Complex construction/mixed arithmetic and native eig/SVD entry points.
z = mp ("1.25", "-0.5");
z2 = z * mp ("1", "0");
assert (double (real (z2)) == 1.25);
assert (double (imag (z2)) == -0.5);

G = mp (gallery ("grcar", 4));
[V, D] = eig (G, "nobalance");
assert (strcmp (class (V), "mp"));
assert (strcmp (class (D), "mp"));
assert (rows (V) == 4 && columns (D) == 4);

H = mp ({"1", "0.5"; "0.333333333333333333333333333333", "0.25"});
[Us, Ss, Vs] = svd (H);
assert (strcmp (class (Us), "mp"));
assert (strcmp (class (Ss), "mp"));
assert (strcmp (class (Vs), "mp"));
assert (double (norm (H - Us * Ss * Vs', "fro")) < 1e-30);

% Deterministic RNG and binary serialization use the installed package only.
saved_bits = mpbits ();
saved_state = mprng ("state");
save_path = fullfile (getenv ("MPLAPACK_TEST_TMPDIR"), ...
                      "mplapack-interop-autopkgtest.mat");
unwind_protect
  mprng ("seed", uint64 (7));
  first = mprand (2, 1);
  mprng ("seed", uint64 (7));
  assert (isequal (first, mprand (2, 1)));

  saved = mp ({"1.234567890123456789", "-0"; "Inf", "NaN"});
  save ("-binary", save_path, "saved");
  clear saved;
  load (save_path, "saved");
  assert (strcmp (class (saved), "mp"));
  assert (char (saved (1, 1)) == char (mp ("1.234567890123456789")));
unwind_protect_cleanup
  mprng ("state", saved_state);
  mpbits (saved_bits);
  if (exist (save_path, "file"))
    unlink (save_path);
  endif
end_unwind_protect

fprintf ("mplapack-interop installed smoke PASS\n");
