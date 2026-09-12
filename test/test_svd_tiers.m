## SVT18 integration wall for Tier S/A construction and measured SVD helpers.

test_root = fileparts (mfilename ("fullpath"));
repo_root = fileparts (test_root);
suite_dir = fullfile (repo_root, "examples", "svd_tiers");
private_dir = fullfile (suite_dir, "private");
addpath (suite_dir);
addpath (private_dir);

assert (mp_svd_tiers_selftest ().ok);
assert (svt_construction_selftest ().ok);
assert (svt_svd_contract_selftest ().ok);
fprintf ("PASS: test_svd_tiers (SVT18 Tier S/A and SVD integration)\n");

rmpath (private_dir);
rmpath (suite_dir);
