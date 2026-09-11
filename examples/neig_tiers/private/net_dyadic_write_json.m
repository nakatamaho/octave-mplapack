% Write one canonical, hash-bound dyadic witness.
function result = net_dyadic_write_json (record, filename)
  if (nargin != 2 || ! ischar (filename) || isempty (filename))
    error ("mplapack:neigt:Serialize", "invalid witness path");
  endif
  body = net_dyadic_canonical (record, false);
  record.sha256 = hash ("sha256", body);
  result = net_dyadic_canonical (record, true);
  handle = fopen (filename, "w");
  if (handle < 0)
    error ("mplapack:neigt:Serialize", "cannot open witness path");
  endif
  unwind_protect
    fwrite (handle, result);
    fwrite (handle, char (10));
  unwind_protect_cleanup
    fclose (handle);
  end_unwind_protect
endfunction
