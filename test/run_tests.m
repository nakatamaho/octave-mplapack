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
assert (test (fullfile (test_dir, "precision.tst"), "quiet", stdout));
fprintf ("PASS: M04 public precision tests\n");
assert (test (fullfile (test_dir, "conversion.tst"), "quiet", stdout));
fprintf ("PASS: M05 scalar conversion and display tests\n");
assert (test (fullfile (test_dir, "arithmetic.tst"), "quiet", stdout));
fprintf ("PASS: M06 scalar arithmetic tests\n");
assert (test (fullfile (test_dir, "matrix_storage.tst"), "quiet", stdout));
fprintf ("PASS: M07 native dense matrix storage tests\n");
