## SPDX-License-Identifier: BSD-2-Clause

function manifest = svt_load_manifest ()
  helper_dir = fileparts (mfilename ("fullpath"));
  suite_dir = fileparts (helper_dir);
  repo_root = fileparts (fileparts (suite_dir));
  manifest_path = fullfile (repo_root, "docs", "codex", "svt", "cases.json");
  if (! exist (manifest_path, "file"))
    error ("mplapack:svt:ManifestMissing", ...
           "normative SVT manifest is missing: %s", manifest_path);
  endif
  try
    manifest = jsondecode (fileread (manifest_path));
  catch exception
    error ("mplapack:svt:ManifestInvalid", ...
           "could not decode normative SVT manifest: %s", exception.message);
  end_try_catch
  if (! isfield (manifest, "schema") || ...
      ! strcmp (manifest.schema, "svt-case-manifest-v1") || ...
      ! isfield (manifest, "profiles"))
    error ("mplapack:svt:ManifestInvalid", ...
           "normative SVT manifest has an invalid schema");
  endif
endfunction
