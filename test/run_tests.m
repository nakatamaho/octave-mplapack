test_dir = fileparts (mfilename ("fullpath"));
repo_root = fileparts (test_dir);

addpath (fullfile (repo_root, "inst"));
addpath (fullfile (repo_root, "src"));

assert (test (fullfile (test_dir, "build_probe.tst"), "quiet", stdout));
fprintf ("PASS: M01 build probe tests\n");
assert (test (fullfile (test_dir, "native_value.tst"), "quiet", stdout));
fprintf ("PASS: M02 native-value tests\n");
assert (test (fullfile (test_dir, "constructor.tst"), "quiet", stdout));
fprintf ("PASS: M03 public scalar constructor tests\n");
