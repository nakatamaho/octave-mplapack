## SPDX-License-Identifier: BSD-2-Clause

function results = mp_svd_tiers (profile, options)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{results} =} mp_svd_tiers (@var{profile})
  ## @deftypefnx {} {@var{results} =} mp_svd_tiers (@var{profile}, @var{options})
  ## Run the Tier S/A/V SVD example suite for a named profile.
  ##
  ## This facade owns option validation, manifest accounting, precision cleanup,
  ## and result-directory safety. Numerical constructors and verifiers are
  ## private example helpers; the public package API is not changed by this
  ## example suite.
  ## @end deftypefn

  if (nargin < 1 || nargin > 2)
    error ("mplapack:svt:InvalidArguments", ...
           "mp_svd_tiers expects a profile and optional options struct");
  endif
  if ((! ischar (profile) && ! isstring (profile)) ...
      || (ischar (profile) && rows (profile) != 1) ...
      || (isstring (profile) && numel (profile) != 1))
    error ("mplapack:svt:InvalidProfile", ...
           "profile must be \"smoke\", \"demo\", or \"stress\"");
  endif
  profile = char (profile);
  if (! any (strcmp (profile, {"smoke", "demo", "stress"})))
    error ("mplapack:svt:InvalidProfile", ...
           "unknown SVD tier profile: %s", profile);
  endif

  if (nargin == 1)
    options = struct ();
  endif
  if (! isstruct (options) || numel (options) != 1)
    error ("mplapack:svt:InvalidOptions", ...
           "options must be a scalar struct");
  endif

  fields = fieldnames (options);
  allowed = {"tier", "output_dir", "plot"};
  for index = 1:numel (fields)
    if (! any (strcmp (fields{index}, allowed)))
      error ("mplapack:svt:InvalidOptions", ...
             "unknown mp_svd_tiers option: %s", fields{index});
    endif
  endfor

  tier = "all";
  if (isfield (options, "tier"))
    tier = options.tier;
    if ((! ischar (tier) && ! isstring (tier)) ...
        || (ischar (tier) && rows (tier) != 1) ...
        || (isstring (tier) && numel (tier) != 1))
      error ("mplapack:svt:InvalidTier", ...
             "tier must be \"all\", \"S\", \"A\", or \"V\"");
    endif
    tier = char (tier);
  endif
  if (! any (strcmp (tier, {"all", "S", "A", "V"})))
    error ("mplapack:svt:InvalidTier", ...
           "tier must be \"all\", \"S\", \"A\", or \"V\"");
  endif

  output_dir = "";
  if (isfield (options, "output_dir"))
    output_dir = options.output_dir;
    if ((! ischar (output_dir) && ! isstring (output_dir)) ...
        || (ischar (output_dir) && rows (output_dir) != 1) ...
        || (isstring (output_dir) && numel (output_dir) != 1))
      error ("mplapack:svt:InvalidOutputDirectory", ...
             "output_dir must be a character vector or string scalar");
    endif
    output_dir = char (output_dir);
    if (! isempty (output_dir) && (exist (output_dir, "file") || exist (output_dir, "dir")))
      error ("mplapack:svt:OutputDirectoryExists", ...
             "refusing to overwrite existing output directory: %s", output_dir);
    endif
    if (! isempty (output_dir) && ! mkdir (output_dir))
      error ("mplapack:svt:OutputDirectoryCreate", ...
             "could not create output directory: %s", output_dir);
    endif
  endif

  plot_enabled = false;
  if (isfield (options, "plot"))
    plot_enabled = options.plot;
    if (! islogical (plot_enabled) || ! isscalar (plot_enabled))
      error ("mplapack:svt:InvalidPlotOption", "plot must be a logical scalar");
    endif
  endif

  manifest = svt_load_manifest ();
  profile_data = svt_manifest_profile (manifest, profile);
  if (strcmp (tier, "all"))
    selected_cases = profile_data.cases;
  else
    selected_cases = profile_data.cases(strcmp ({profile_data.cases.tier}, tier));
  endif

  saved_bits = mpbits ();
  cleanup_precision = onCleanup (@() mpbits (saved_bits));
  results = svt_run_profile (profile_data, profile, tier, plot_enabled);
  results.output_dir = output_dir;
  results.manifest_schema = manifest.schema;
  results.case_count = numel (selected_cases);
  results.manifest_case_count = numel (profile_data.cases);
  results.cases = selected_cases;
  results.v_jobs = struct ("count", results.v_job_count, ...
                           "status", ternary_status (results.v_job_count > 0));
  results.environment.mpbits_at_entry = saved_bits;
  if (! isempty (output_dir))
    results.artifacts = svt_write_profile_artifacts (results, profile_data, output_dir);
  else
    results.artifacts = {};
  endif
  clear cleanup_precision;
endfunction

function value = ternary_status (condition)
  if (condition), value = "EXECUTED"; else, value = "NOT_RUN"; endif
endfunction
