% Write a canonical hash-bound NEIGT proof record.
function digest = net_neigt_json_write (record, filename)
  if (nargin != 2 || ! isstruct (record) || ! isscalar (record) ...
      || ! ischar (filename) || isempty (filename) || isfield (record, "sha256"))
    error ("mplapack:neigt:Serialize", "invalid proof-record write request");
  endif
  body = net_neigt_json_encode (record);
  digest = hash ("sha256", body);
  record.sha256 = digest;
  text = net_neigt_json_encode (record);
  handle = fopen (filename, "w");
  if (handle < 0)
    error ("mplapack:neigt:Serialize", "cannot open proof record");
  endif
  unwind_protect
    fwrite (handle, text);
    fwrite (handle, char (10));
  unwind_protect_cleanup
    fclose (handle);
  end_unwind_protect
endfunction
