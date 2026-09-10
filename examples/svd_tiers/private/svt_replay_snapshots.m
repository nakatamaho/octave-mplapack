## SPDX-License-Identifier: BSD-2-Clause

function report = svt_replay_snapshots (path_name)
  ## Decode every exact input/factor snapshot and verify its canonical hash.
  data = jsondecode (fileread (path_name));
  if (! isfield (data, "records")), error ("mplapack:svt:Replay", "records missing"); endif
  checked = 0;
  for index = 1:numel (data.records)
    record = data.records(index);
    names = {"input", "U", "S", "V"};
    for name_index = 1:numel (names)
      snapshot = record.(names{name_index});
      value = decode_snapshot (snapshot);
      reencoded = svt_serialize_mp_array (value, snapshot.storage_bits);
      if (! strcmp (reencoded.canonical_byte_hash, snapshot.canonical_byte_hash))
        error ("mplapack:svt:ReplayHash", ...
               "canonical snapshot hash mismatch at record %d (%s)", index, names{name_index});
      endif
      checked = checked + 1;
    endfor
  endfor
  report = struct ("status", "PASS", "records", numel (data.records), ...
                   "snapshots", checked, "path", path_name);
endfunction

function value = decode_snapshot (snapshot)
  if (! isstruct (snapshot) || ! isfield (snapshot, "kind") ...
      || ! isfield (snapshot, "shape") || ! isfield (snapshot, "values") ...
      || ! isfield (snapshot, "storage_bits"))
    error ("mplapack:svt:Replay", "malformed exact snapshot");
  endif
  shape = snapshot.shape;
  q = snapshot.storage_bits;
  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (q);
  if (strcmp (snapshot.kind, "complex"))
    value = mp (complex (zeros (shape), zeros (shape)));
  else
    value = mp (zeros (shape));
  endif
  entries = snapshot.values;
  for index = 1:numel (entries)
    if (strcmp (snapshot.kind, "complex"))
      element = svt_dyadic_complex_decode (entries(index), q);
    else
      element = svt_dyadic_decode (entries(index), q);
    endif
    value(index) = element;
  endfor
  clear cleanup;
endfunction
