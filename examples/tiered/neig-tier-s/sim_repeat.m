% Semisimple repeated similarity.
%
% Question: A repeated eigenvalue with a two-dimensional eigenspace.
% Steps:
% 1. Select this exact case from the frozen manifest.
% 2. Run the public eig path at the profile's MP precisions.
% 3. Inspect the residuals and precision roles reported by the case runner.
% Matching documentation: docs/examples/tiered/neig-tier-s/sim_repeat.md
if (exist ("mpbits", "file") != 2)
  pkg load mplapack-interop
endif

example_root = fileparts (fileparts (fileparts (mfilename ("fullpath"))));
suite_root = fullfile (example_root, "neig_tiers");
addpath (suite_root);
cleanup_path = onCleanup (@() rmpath (suite_root));

result = mp_neig_tiers ("smoke", struct ("tier", "S", ...
                                           "case_id", "SIM_REPEAT", ...
                                           "plot", false));
assert (result.ok && result.coverage.case_count == 1);
fprintf ("SIM_REPEAT: PASS; selected cases=%d; measured rows=%d\n", ...
         result.coverage.case_count, result.coverage.measured_eig_rows);
fprintf ("See docs/examples/tiered/neig-tier-s/sim_repeat.md for interpretation.\n");

clear cleanup_path;
