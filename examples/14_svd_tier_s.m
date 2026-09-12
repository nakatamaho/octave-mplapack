% Small reproducible Tier S SVD example.
%
% The NRO two-level block is dense, integer-valued, and deliberately more
% informative than a diagonal example.  The full 23-case measurement is
% available with: mp_svd_tiers ("demo", struct ("tier", "S", ...)).
if (exist ("mpbits", "file") != 2)
  pkg load mplapack-interop
endif

example_root = fileparts (mfilename ("fullpath"));
private_root = fullfile (example_root, "svd_tiers", "private");
addpath (private_root);
cleanup_path = onCleanup (@() rmpath (private_root));

saved_bits = mpbits ();
cleanup_precision = onCleanup (@() mpbits (saved_bits));
mpbits (256);

identity = mp (eye (2));
block = mp ({"1", "2"; "3", "4"});
zero = mp (zeros (2, 2));
A = [identity, block; zero, identity];
[U, S, V] = svd (A, "econ");
residual = norm (A - U * S * V', "fro") / norm (A, "fro");

assert (residual < mp ("1e-60"));
assert (all (diag (S) >= mp (0)));
fprintf ("Tier S NRO SVD PASS: size=%dx%d, mpbits=%d\n", ...
         rows (A), columns (A), mpbits ());
fprintf ("  reconstruction residual = %s\n", char (residual));
disp (diag (S));

clear cleanup_precision;
clear cleanup_path;
