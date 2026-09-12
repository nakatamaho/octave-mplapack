% Run one V-S3 verified pseudospectrum point or positive-area cell job.
function result = net_v_s3_job (job, profile_data, profile)
  result = status_template ();
  if (nargin != 3 || ! isstruct (job) || ! isfield (job, "id") ...
      || ! isfield (job, "kind") || ! isfield (job, "fixture") ...
      || ! isfield (profile_data, "source_bits") ...
      || ! isfield (profile_data, "evaluation_bits") ...
      || ! any (strcmp (profile, {"smoke", "demo"})))
    error ("mplapack:neigt:VS3", "invalid V-S3 job arguments");
  endif
  result.id = job.id;
  result.tier = job.tier;
  result.kind = job.kind;
  result.candidate_source = job.candidate_source;
  result.candidate_bits = profile_data.source_bits;
  result.evaluation_bits = profile_data.evaluation_bits;
  source_bits = profile_data.source_bits;
  q = profile_data.evaluation_bits;
  saved_bits = mpbits ();
  unwind_protect
    try
      mpbits (source_bits);
      entry = make_case_entry (job.fixture);
      model = net_case_model (entry, source_bits);
      z = net_mp_complex (parse_scalar (job.center.real, source_bits), ...
                           parse_scalar (job.center.imag, source_bits));
      epsilon = parse_scalar (job.epsilon, source_bits);
      cell_box = [];
      if (strcmp (job.kind, "pseudospectrum_cell"))
        cell_box = struct ("real_halfwidth", ...
                           parse_scalar (job.halfwidths.real, source_bits), ...
                           "imag_halfwidth", ...
                           parse_scalar (job.halfwidths.imag, source_bits));
      endif
      certificate = net_v_s3_svd (model.A_frozen, z, epsilon, cell_box, ...
                                  source_bits, q);
      result.certificate = certificate;
      result.details = certificate;
      result.status = certificate.status;
      result.claim_status = certificate.status;
      result.claim_quality = "resolved";
      result.pass = strcmp (certificate.status, job.expected);
      result.milestone_pass = result.pass;
      result.raw_B_hash = certificate.raw.B_hash;
      result.raw_U_hash = certificate.raw.U_hash;
      result.raw_s_hash = certificate.raw.s_hash;
      result.raw_V_hash = certificate.raw.V_hash;
      result.input_hash = net_raw_hash (model.A_frozen, [job.id, "_A_frozen"]);
      result.source = model.source;
      result.input_status = model.input_status;
      result.target = job.target;
      if (result.pass)
        result.status = "PASS";
      endif
    catch exception
      result.status = "FAILED_VERIFIER";
      result.claim_status = "ERROR";
      result.claim_quality = "not_identified";
      result.error_identifier = exception.identifier;
      result.error_message = exception.message;
    end_try_catch
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function entry = make_case_entry (fixture)
  family = char (fixture.family);
  if (strcmp (family, "exact_similarity"))
    regime = char (fixture.regime);
    if (strcmp (regime, "jordan"))
      case_id = "SIM_JORDAN";
    elseif (strcmp (regime, "semisimple"))
      case_id = "SIM_SEMISIMPLE";
    elseif (strcmp (regime, "simple"))
      case_id = "SIM_SIMPLE";
    else
      error ("mplapack:neigt:VS3", "unsupported exact-similarity regime %s", regime);
    endif
    entry = struct ("id", case_id, ...
                    "tier", "V", "parameters", struct ("n", fixture.n, ...
                    "regime", regime, "gap_exponent", 0));
  elseif (strcmp (family, "grcar"))
    entry = struct ("id", "GRCAR", "tier", "V", ...
                    "parameters", struct ("n", fixture.n, ...
                    "upper_bandwidth", fixture.upper_bandwidth));
  else
    error ("mplapack:neigt:VS3", "unsupported V-S3 fixture family %s", family);
  endif
endfunction

function value = parse_scalar (token, bits)
  token = char (token);
  if (! isempty (regexp (token, "^[+-]?[0-9]+$", "once")))
    value = mp (str2num (token)); %#ok<ST2NM>
    return;
  endif
  match = regexp (token, "^2\\^(-[0-9]+)$", "tokens", "once");
  if (! isempty (match))
    value = net_pow2 (str2num (match{1}), bits); %#ok<ST2NM>
    return;
  endif
  pieces = strsplit (token, "/");
  if (numel (pieces) == 2 ...
      && ! isempty (regexp (pieces{1}, "^[0-9]+$", "once")) ...
      && ! isempty (regexp (pieces{2}, "^[0-9]+$", "once")))
    value = net_dyadic_parameter (token, bits);
    return;
  endif
  error ("mplapack:neigt:VS3", "unsupported exact scalar token %s", token);
endfunction

function result = status_template ()
  result = struct ("id", "", "tier", "", "kind", "", "status", ...
    "NOT_IMPLEMENTED", "pass", false, "milestone_pass", false, ...
    "claim_status", "", "claim_quality", "", "details", [], ...
    "candidate_source", "", "candidate_bits", NaN, "evaluation_bits", NaN, ...
    "raw_V_hash", "", "raw_D_hash", "", "raw_W_hash", "", ...
    "raw_B_hash", "", "raw_U_hash", "", "raw_s_hash", "", ...
    "raw_lambda_hash", "", ...
    "certificate", [], "input_hash", "", "source", "", ...
    "input_status", "", "target", "", "error_identifier", "", ...
    "raw_V", [], "raw_D", [], "raw_W", [], "error_message", "");
endfunction
