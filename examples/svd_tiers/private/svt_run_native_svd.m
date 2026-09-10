## SPDX-License-Identifier: BSD-2-Clause

function row = svt_run_native_svd (input, mode)
  ## Run an explicitly requested native binary64 comparison row.  This path is
  ## never selected by the MP runner and its conversion is recorded in-row.
  if (! isa (input, "mp") || ! any (strcmp (mode, {"values", "econ"})))
    error ("mplapack:svt:InvalidNativeSvdRequest", ...
           "native SVD requires an mp input and values/econ mode");
  endif
  native_input = double (input);
  before = native_input;
  row = struct ();
  row.schema = "svt-row-v1";
  row.mode = mode;
  row.native = true;
  row.input_shape = size (native_input);
  row.input_precision_bits = 53;
  row.evaluation_bits = 53;
  row.api = "explicit double(A) -> builtin binary64 svd";
  row.input_conversion = "explicit requested native comparison; not an MP fallback";
  timer = tic ();
  if (strcmp (mode, "values"))
    row.values = svd (native_input);
    row.has_factors = false;
  else
    [row.U, row.S, row.V] = svd (native_input, "econ");
    row.values = diag (row.S);
    row.has_factors = true;
  endif
  row.svd_seconds = toc (timer);
  row.input_unchanged = isequal (native_input, before);
  if (! row.input_unchanged)
    error ("mplapack:svt:NativeInputMutation", ...
           "native SVD changed its converted input");
  endif
  k = min (size (native_input));
  if (! isreal (row.values) || any (! isfinite (row.values)) ...
      || any (row.values < 0) ...
      || (numel (row.values) > 1 && any (row.values(1:end-1) < row.values(2:end))))
    error ("mplapack:svt:NativeSvdContract", ...
           "native SVD returned invalid singular values");
  endif
  if (numel (row.values) != k)
    error ("mplapack:svt:NativeSvdContract", ...
           "native SVD returned an invalid value count");
  endif
  row.status = "PASS";
endfunction
