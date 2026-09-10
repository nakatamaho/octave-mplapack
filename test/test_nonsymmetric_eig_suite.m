## Focused NEIG01 test entry point.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "nonsymmetric_eig"));
mp_eig_suite_selftest ();
fprintf ("PASS: test_nonsymmetric_eig_suite (NEIG01)\n");
