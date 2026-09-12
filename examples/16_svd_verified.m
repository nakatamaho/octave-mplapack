% Small reproducible Tier V verification example.
%
% The certificate consumes the actual MPFR SVD factors; it does not call a
% second SVD internally and it never converts numerical evidence to double.
% The complete V wall is available with:
%   mp_svd_tiers ("demo", struct ("tier", "V", "plot", false))
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

A = mp ({"3", "0"; "0", "1"});
[U, S, V] = svd (A, "econ");
values_certificate = svt_certify_values (A, U, S, V, 256);
assert (strcmp (values_certificate.status, "CERTIFIED"));
assert (values_certificate.epsilon.hi < mp ("1e-60"));

X = A \ mp (eye (2));
inverse_certificate = svt_certify_inverse (A, X, 256);
assert (strcmp (inverse_certificate.status, "CERTIFIED"));
assert (inverse_certificate.sigma_min_lower > mp (0));

fprintf ("Tier V SVD/inverse certificates PASS: mpbits=%d\n", mpbits ());
fprintf ("  V1 method: %s\n", values_certificate.method);
fprintf ("  V3 method: %s\n", inverse_certificate.method);
fprintf ("  certified sigma_min lower bound = %s\n", ...
         char (inverse_certificate.sigma_min_lower));

clear cleanup_precision;
clear cleanup_path;
