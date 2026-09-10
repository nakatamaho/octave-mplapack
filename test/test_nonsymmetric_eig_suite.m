## Focused NEIG01 test entry point.
test_root = fileparts (fileparts (mfilename ("fullpath")));
addpath (fullfile (test_root, "examples", "nonsymmetric_eig"));
mp_eig_suite_selftest ();
smoke = mp_eig_suite ("smoke", struct ("family", "hadamard"));
assert (smoke.ok && numel (smoke.rows) == 6);
demo = mp_eig_suite ("demo", struct ("family", "hadamard"));
assert (demo.ok && numel (demo.rows) == 8);
frank_smoke = mp_eig_suite ("smoke", struct ("family", "frank"));
assert (frank_smoke.ok && numel (frank_smoke.rows) == 6);
frank_demo = mp_eig_suite ("demo", struct ("family", "frank"));
assert (frank_demo.ok && numel (frank_demo.rows) == 8);
fprintf ("PASS: test_nonsymmetric_eig_suite (NEIG01)\n");
