test_dir = fileparts (mfilename ("fullpath"));
repo_root = fileparts (test_dir);

addpath (fullfile (repo_root, "inst"));
addpath (fullfile (repo_root, "src"));

assert (test (fullfile (test_dir, "build_probe.tst")));
fprintf ("PASS: M01 build probe tests\n");
fprintf ("SKIP: M02+ numerical tests are not active during M01\n");
