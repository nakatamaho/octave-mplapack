## SVT18 integration wall for self-contained Tier V verifiers.

test_root = fileparts (mfilename ("fullpath"));
repo_root = fileparts (test_root);
suite_dir = fullfile (repo_root, "examples", "svd_tiers");
private_dir = fullfile (suite_dir, "private");
addpath (suite_dir);
addpath (private_dir);

assert (svt_v0_selftest ().ok);
assert (svt_v1_values_selftest ().ok);
assert (svt_v1_projector_selftest ().ok);
assert (svt_v2_factor_selftest ().ok);
assert (svt_v3_inverse_selftest ().ok);
fprintf ("PASS: test_svd_verification (SVT18 V0/V1/V2/V3 integration)\n");

rmpath (private_dir);
rmpath (suite_dir);
