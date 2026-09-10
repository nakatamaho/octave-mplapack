## SPDX-License-Identifier: BSD-2-Clause

function profile_data = svt_manifest_profile (manifest, name)
  if (! isfield (manifest.profiles, name))
    error ("mplapack:svt:ManifestInvalid", ...
           "normative SVT manifest has no profile: %s", name);
  endif
  profile_data = manifest.profiles.(name);
  required = {"work_bits", "native", "modes", "cases", ...
              "expected_svd_rows", "reference_bits", "evaluation_bits"};
  for index = 1:numel (required)
    if (! isfield (profile_data, required{index}))
      error ("mplapack:svt:ManifestInvalid", ...
             "profile %s lacks field %s", name, required{index});
    endif
  endfor
  if (numel (unique ({profile_data.cases.id})) != numel (profile_data.cases))
    error ("mplapack:svt:ManifestInvalid", ...
           "profile %s contains duplicate case IDs", name);
  endif
  expected = numel (profile_data.cases) * ...
             (numel (profile_data.work_bits) + double (profile_data.native)) * ...
             numel (profile_data.modes);
  if (expected != profile_data.expected_svd_rows)
    error ("mplapack:svt:ManifestInvalid", ...
           "profile %s has inconsistent measured-row count", name);
  endif
endfunction
