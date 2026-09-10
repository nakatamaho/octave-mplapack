% Small reproducible Tier A SVD example.
%
% This dyadic-node Vandermonde matrix is exact at the selected precision and
% rectangular, so the economy shapes are visible.  The full Tier A profile is
% available with: mp_svd_tiers ("demo", struct ("tier", "A", ...)).
if (exist ("mpbits", "file") != 2)
  pkg load mplapack-interop
endif

saved_bits = mpbits ();
cleanup_precision = onCleanup (@() mpbits (saved_bits));
mpbits (256);

% Rows are [1, x, x^2, x^3] for dyadic nodes x=1/2, 1, 2.
A = mp ({"1", "0.5", "0.25", "0.125"; ...
         "1", "1",   "1",    "1"; ...
         "1", "2",   "4",    "8"});
[U, S, V] = svd (A, "econ");
residual = norm (A - U * S * V', "fro") / norm (A, "fro");

assert (size (U) == [3, 3]);
assert (size (S) == [3, 3]);
assert (size (V) == [4, 3]);
assert (residual < mp ("1e-60"));
fprintf ("Tier A Vandermonde SVD PASS: shape=%dx%d, mpbits=%d\n", ...
         rows (A), columns (A), mpbits ());
fprintf ("  reconstruction residual = %s\n", char (residual));
disp (diag (S));

clear cleanup_precision;
