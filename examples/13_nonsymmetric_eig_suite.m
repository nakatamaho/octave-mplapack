% Reproducible smoke example for difficult dense nonsymmetric eigensystems.
%
% The suite uses the existing public mp/eig API. It runs all five exact or
% independently referenced representations in both balance modes, with
% native and MP controls, and reports residual/conditioning diagnostics.
if (exist ("mpbits", "file") != 2)
  pkg load mplapack-interop
endif

example_root = fileparts (mfilename ("fullpath"));
addpath (fullfile (example_root, "nonsymmetric_eig"));

saved_bits = mpbits ();
unwind_protect
  results = mp_eig_suite ("smoke");
  assert (results.ok && numel (results.rows) == 30);
  fprintf ("Nonsymmetric eigensystem smoke PASS: %d rows, evaluation=%d bits\n", ...
           numel (results.rows), results.evaluation_bits);
  disp ("See docs/nonsymmetric-eig-suite.md for constructions and metrics.");
unwind_protect_cleanup
  mpbits (saved_bits);
end_unwind_protect
