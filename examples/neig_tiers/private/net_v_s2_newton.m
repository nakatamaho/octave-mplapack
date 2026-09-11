% Candidate-only bounded Newton correction for the invariant graph equation.
% This routine never supplies a proof result.  net_v_s2_graph must recheck
% the transformed basis from scratch with outward arithmetic.
function result = net_v_s2_newton (C, k, Z0, bits)
  if (nargin != 4 || ! isa (C, "mp") || rows (C) != columns (C) ...
      || k != fix (k) || k < 1 || k >= rows (C) || ! isa (Z0, "mp") ...
      || ! isequal (size (Z0), [rows(C) - k, k]) || bits != fix (bits) ...
      || bits < 64)
    error ("mplapack:neigt:VS2", "invalid graph Newton arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    n = rows (C);
    h = n - k;
    Z = Z0;
    max_candidate_entry = net_pow2 (64, bits);
    initial_residual = mp (0);
    records = struct ([]);
    for step = 1:4
      C11 = C(1:k, 1:k);
      C12 = C(1:k, (k + 1):n);
      C21 = C((k + 1):n, 1:k);
      C22 = C((k + 1):n, (k + 1):n);
      F = C21 + C22 * Z - Z * C11 - Z * C12 * Z;
      before = norm (F, "fro");
      if (step == 1)
        initial_residual = before;
      endif
      Kz = kron (mp (eye (k)), C22 - Z * C12) ...
            - kron (transpose (C11 + C12 * Z), mp (eye (h)));
      record = struct ("step", step, "status", "NOT_RUN", ...
                       "residual_before", before, "residual_after", mp ("NaN"), ...
                       "solve_source", "public_point_solve", "bits", bits, ...
                       "error_identifier", "", "error_message", "");
      try
        correction = Kz \ (-reshape (F, h * k, 1));
        Z = Z + reshape (correction, h, k);
        if (! all (isfinite (Z(:))) || any (abs (Z(:)) > max_candidate_entry))
          record.status = "REJECTED_UNBOUNDED_STEP";
          record.error_identifier = "mplapack:neigt:CandidateBound";
          record.error_message = "candidate Newton step exceeded bounded preparation range";
          if (isempty (records))
            records = record;
          else
            records(end + 1) = record;
          endif
          break;
        endif
        F_after = C21 + C22 * Z - Z * C11 - Z * C12 * Z;
        record.status = "SUCCESS";
        record.residual_after = norm (F_after, "fro");
      catch exception
        record.status = "FAILED_SOLVE";
        record.error_identifier = exception.identifier;
        record.error_message = exception.message;
      end_try_catch
      if (isempty (records))
        records = record;
      else
        records(end + 1) = record;
      endif
      if (! strcmp (record.status, "SUCCESS"))
        break;
      endif
      if (record.residual_after == mp (0))
        break;
      endif
    endfor
    improved = ! isempty (records) && strcmp (records(end).status, "SUCCESS") ...
               && records(end).residual_after <= initial_residual;
    result = struct ("method", "neigt_candidate_graph_newton_v1", ...
      "paper_algorithm_reproduction", false, "candidate_only", true, ...
      "max_steps", 4, "steps", records, "steps_used", numel (records), ...
      "initial_Z", Z0, "final_Z", Z, "candidate_bits", bits, ...
      "initial_residual", initial_residual, "improved", improved, ...
      "success", improved && all (strcmp ({records.status}, "SUCCESS")));
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
