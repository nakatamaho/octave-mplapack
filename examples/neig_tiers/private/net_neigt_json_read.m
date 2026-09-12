% Read a canonical NEIGT proof record and verify its content hash.
function result = net_neigt_json_read (filename)
  if (nargin != 1 || ! ischar (filename) || isempty (filename))
    error ("mplapack:neigt:Deserialize", "invalid proof-record path");
  endif
  text = fileread (filename);
  result = jsondecode (text);
  if (! isstruct (result) || ! isscalar (result) ...
      || ! isfield (result, "sha256") || ! ischar (result.sha256))
    error ("mplapack:neigt:Deserialize", "proof record hash is missing");
  endif
  supplied = result.sha256;
  result = rmfield (result, "sha256");
  expected = hash ("sha256", net_neigt_json_encode (result));
  if (! strcmp (supplied, expected))
    error ("mplapack:neigt:Deserialize", "proof record content hash mismatch");
  endif
  result.sha256 = supplied;
endfunction
