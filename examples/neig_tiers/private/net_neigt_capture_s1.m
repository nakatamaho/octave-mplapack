% Capture one measured V-S1 job with exact replay inputs.
% Capture may call eig; the separate replay path must not.
function result = net_neigt_capture_s1 (profile, job_id)
  bundle = net_manifest ();
  case_profile = bundle.cases.profiles.(profile);
  profile_data = bundle.jobs.profiles.(profile);
  jobs = bundle.jobs.profiles.(profile).jobs;
  job = [];
  for index = 1:numel (jobs)
    if (strcmp (jobs{index}.id, job_id))
      job = jobs{index};
      break;
    endif
  endfor
  if (isempty (job) || ! strncmp (job_id, "VS1-", 4))
    error ("mplapack:neigt:Capture", "only a V-S1 job can be captured");
  endif
  case_entry = [];
  for index = 1:numel (case_profile.cases)
    if (strcmp (case_profile.cases(index).id, job.core_case))
      case_entry = case_profile.cases(index);
      break;
    endif
  endfor
  if (isempty (case_entry))
    error ("mplapack:neigt:Capture", "capture case is absent from manifest");
  endif

  source_bits = profile_data.source_bits;
  q = profile_data.evaluation_bits;
  saved_bits = mpbits ();
  unwind_protect
    mpbits (source_bits);
    model = net_case_model (case_entry, source_bits);
    [V, D, unused_W] = eig (model.A_frozen, "nobalance"); %#ok<ASGLU>
    mpbits (q);
    A = net_widen (model.A_frozen, q, source_bits);
    X = net_widen (V, q, source_bits);
    T = net_widen (D, q, source_bits);
    R = X \ mp (eye (rows (X)));
    useful_exponent = -40;
    if (strcmp (profile, "demo"))
      useful_exponent = -64;
    endif
    certificate = net_v_s1_gershgorin (A, X, T, R, q, useful_exponent);
    if (! strcmp (certificate.status, "CERTIFIED_ALL") ...
        || ! certificate.all_roots || certificate.counted_roots != rows (A) ...
        || ! certificate.singleton_useful || ! certificate.useful)
      error ("mplapack:neigt:Capture", "capture job did not pass its fixed gate");
    endif
    payload = struct ();
    payload.profile = profile;
    payload.job_id = job_id;
    payload.source_bits = source_bits;
    payload.evaluation_bits = q;
    payload.usefulness_exponent = useful_exponent;
    payload.input_hash = net_raw_hash (model.A_frozen, [job_id, "_A_frozen"]);
    payload.A = A;
    payload.X = X;
    payload.T = T;
    payload.R = R;
    payload.certificate = certificate;
    payload.certificate_status = certificate.status;
    payload.certificate_method = certificate.method;
    payload.raw_V_hash = net_raw_hash (V, [job_id, "_raw_V"]);
    payload.raw_D_hash = net_raw_hash (D, [job_id, "_raw_D"]);
    encoded_payload = net_neigt_encode_value (payload, q);
    result = struct ("schema", "neigt-proof-v1", ...
                     "method_version", "neigt-s1-replay-v1", ...
                     "profile", profile, "job_id", job_id, ...
                     "stored_precision", q, "payload", encoded_payload);
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
