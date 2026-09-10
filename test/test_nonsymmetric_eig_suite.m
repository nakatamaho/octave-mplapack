## Focused nonsymmetric eigensystem test entry point.
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
companion_smoke = mp_eig_suite ("smoke", struct ("family", "companion"));
assert (companion_smoke.ok && numel (companion_smoke.rows) == 6);
companion_demo = mp_eig_suite ("demo", struct ("family", "companion"));
assert (companion_demo.ok && numel (companion_demo.rows) == 8);
native_companion = companion_demo.rows(1);
assert (strcmp (native_companion.backend, "native")
        && native_companion.input_error > mp ("0"));
forsythe_smoke = mp_eig_suite ("smoke", struct ("family", "forsythe"));
assert (forsythe_smoke.ok && numel (forsythe_smoke.rows) == 12);
forsythe_demo = mp_eig_suite ("demo", struct ("family", "forsythe"));
assert (forsythe_demo.ok && numel (forsythe_demo.rows) == 16);
for k = 1:numel (forsythe_demo.rows)
  row = forsythe_demo.rows(k);
  if (! row.native)
    if (row.work_bits == 512 && strcmp (row.representation, "original"))
      assert (row.circle_error < mp ("2")^(-64));
    elseif (row.work_bits == 512)
      assert (row.circle_error < mp ("2")^(-200));
    endif
  endif
endfor
all_smoke = mp_eig_suite ("smoke");
assert (all_smoke.ok && numel (all_smoke.rows) == 30);
all_demo = mp_eig_suite ("demo");
assert (all_demo.ok && numel (all_demo.rows) == 40);
output_dir = tempname ();
written = mp_eig_suite ("smoke", struct ("output_dir", output_dir));
assert (written.ok && exist (written.output.summary, "file") ...
        && exist (written.output.eigenvalues, "file") ...
        && exist (written.output.environment, "file") ...
        && exist (written.output.report, "file"));
caught = false;
try
  nes_write (written, output_dir);
catch exception
  caught = strcmp (exception.identifier, "NEIG:WriteExists");
end_try_catch
assert (caught);
rmdir (output_dir, "s");
fprintf ("PASS: test_nonsymmetric_eig_suite (NEIG06)\n");
