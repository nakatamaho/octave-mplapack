% Focused NEIGT01 skeleton test.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "neig_tiers"));
report = mp_neig_tiers_selftest ();
assert (report.ok && ! report.implemented);
fprintf ("PASS: test_neigt01 (manifest/profile skeleton)\n");
