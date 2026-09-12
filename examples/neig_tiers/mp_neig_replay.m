## -*- texinfo -*-
## @deftypefn {} {@var{result} =} mp_neig_replay (@var{proof_file})
## Re-run a hash-bound NEIGT proof from serialized MP inputs.
##
## Replay does not call @code{eig} and does not reconstruct an ideal model.
## It decodes the stored @code{A}, @code{X}, @code{T}, and @code{R} values and
## re-evaluates the audited V-S1 certificate at its recorded precision and
## fixed usefulness target.  A tampered input, target, method, or bound is
## rejected by the content hash or by the certificate predicate.
## @end deftypefn
function result = mp_neig_replay (proof_file)
  if (nargin != 1 || ! ischar (proof_file) || isempty (proof_file))
    error ("mplapack:neigt:Replay", "proof_file must be a nonempty path");
  endif
  helper_root = fileparts (mfilename ("fullpath"));
  private_root = fullfile (helper_root, "private");
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), private_root)))
    addpath (private_root);
    added = true;
  endif
  saved_bits = mpbits ();
  unwind_protect
    record = net_neigt_json_read (proof_file);
    required = {"schema", "method_version", "profile", "job_id", ...
                "stored_precision", "payload"};
    for index = 1:numel (required)
      if (! isfield (record, required{index}))
        error ("mplapack:neigt:Replay", "proof record lacks %s", required{index});
      endif
    endfor
    if (! strcmp (record.schema, "neigt-proof-v1") ...
        || ! strcmp (record.method_version, "neigt-s1-replay-v1"))
      error ("mplapack:neigt:Replay", "unsupported proof record schema");
    endif
    q = record.stored_precision;
    if (! isscalar (q) || q != fix (q) || q < 64 || q > 4096)
      error ("mplapack:neigt:Replay", "invalid proof precision");
    endif
    payload = net_neigt_decode_value (record.payload, q);
    if (! strcmp (payload.profile, record.profile) ...
        || ! strcmp (payload.job_id, record.job_id) ...
        || payload.evaluation_bits != q)
      error ("mplapack:neigt:Replay", "proof metadata/payload mismatch");
    endif
    required_payload = {"A", "X", "T", "R", "input_hash", ...
                         "usefulness_exponent", "certificate", ...
                         "certificate_status", "certificate_method"};
    for index = 1:numel (required_payload)
      if (! isfield (payload, required_payload{index}))
        error ("mplapack:neigt:Replay", ...
               "proof payload lacks %s", required_payload{index});
      endif
    endfor
    A = payload.A;
    X = payload.X;
    T = payload.T;
    R = payload.R;
    if (! isa (A, "mp") || ! isa (X, "mp") || ! isa (T, "mp") ...
        || ! isa (R, "mp") || rows (A) != columns (A) ...
        || ! isequal (size (A), size (X)) || ! isequal (size (A), size (T)) ...
        || ! isequal (size (A), size (R)))
      error ("mplapack:neigt:Replay", "proof matrices have incompatible shapes");
    endif
    input_hash_match = strcmp (payload.input_hash, ...
      net_raw_hash (A, [payload.job_id, "_A_frozen"]));
    if (! input_hash_match)
      error ("mplapack:neigt:Replay", "serialized input hash mismatch");
    endif

    % This is deliberately the only numerical operation in the replay path.
    % In particular, there is no eig call and no model constructor here.
    mpbits (q);
    certificate = net_v_s1_gershgorin (A, X, T, R, q, ...
                                        payload.usefulness_exponent);
    proof_pass = strcmp (certificate.status, "CERTIFIED_ALL") ...
                 && certificate.all_roots ...
                 && certificate.counted_roots == rows (A) ...
                 && certificate.singleton_useful && certificate.useful;
    method_match = strcmp (certificate.method, payload.certificate_method);
    status_match = strcmp (certificate.status, payload.certificate_status);
    % Re-encode the stored and recomputed certificate so a changed bound or
    % field cannot be silently ignored even when the high-level status agrees.
    stored_encoded = record.payload.fields.certificate;
    recomputed_encoded = net_neigt_encode_value (certificate, q);
    certificate_encoding_match = strcmp (net_neigt_json_encode (stored_encoded), ...
                                         net_neigt_json_encode (recomputed_encoded));
    result = struct ("schema", record.schema, "profile", record.profile, ...
      "job_id", record.job_id, "status", "REPLAY_PASS", "ok", ...
      proof_pass && method_match && status_match && certificate_encoding_match, ...
      "proof_pass", proof_pass, "method_match", method_match, ...
      "status_match", status_match, "certificate_encoding_match", ...
      certificate_encoding_match, "input_hash_match", input_hash_match, ...
      "called_eig", false, "reconstructed_ideal_model", false, ...
      "replayed_certificate", certificate, "source", ...
      "NEIGT23_VS1_EXACT_REPLAY");
    if (! result.ok)
      result.status = "REPLAY_CERTIFICATE_MISMATCH";
    endif
    if (added)
      rmpath (private_root);
    endif
  unwind_protect_cleanup
    mpbits (saved_bits);
    if (added && any (strcmp (strsplit (path (), pathsep), private_root)))
      rmpath (private_root);
    endif
  end_unwind_protect
endfunction
