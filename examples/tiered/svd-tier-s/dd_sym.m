% Symmetric diagonally dominant path.
%
% Question: A nearly singular symmetric tridiagonal path.
% Steps:
% 1. Select this exact case from the frozen manifest.
% 2. Run the public svd path at the profile's MP precisions.
% 3. Inspect the residuals and precision roles reported by the case runner.
% Matching documentation: docs/examples/tiered/svd-tier-s/dd_sym.md
if (exist ("mpbits", "file") != 2)
  pkg load mplapack-interop
endif

example_root = fileparts (fileparts (fileparts (mfilename ("fullpath"))));
suite_root = fullfile (example_root, "svd_tiers");
addpath (suite_root);
cleanup_path = onCleanup (@() rmpath (suite_root));

result = mp_svd_tiers ("smoke", struct ("tier", "S", ...
                                           "case_id", "S4-DD-SYM", ...
                                           "plot", false));
assert (result.scope_ok && strcmp (result.status, "PASS") ...
        && result.case_count == 1);
fprintf ("S4-DD-SYM: PASS; selected cases=%d; measured rows=%d\n", ...
         result.case_count, result.measured_svd_rows);
fprintf ("See docs/examples/tiered/svd-tier-s/dd_sym.md for interpretation.\n");

clear cleanup_path;
