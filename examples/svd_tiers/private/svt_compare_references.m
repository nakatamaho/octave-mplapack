## SPDX-License-Identifier: BSD-2-Clause

function comparison = svt_compare_references (low, high)
  ## Compare two frozen-input reference solves observationally.  This routine
  ## never labels agreement as a certificate.
  if (! isstruct (low) || ! isstruct (high) ...
      || ! isfield (low, "values") || ! isfield (high, "values"))
    error ("mplapack:svt:InvalidReference", "reference records are incomplete");
  endif
  q = max ([low.input_precision_bits, high.input_precision_bits]);
  low_values = svt_widen (low.values, q);
  high_values = svt_widen (high.values, q);
  a = svt_widen (low.input, q);
  norm_a = norm (a, "fro");
  threshold = norm_a * svt_pow2 (-floor (low.input_precision_bits / 2));
  k = numel (low_values);
  resolved = false (k, 1);
  relative = mp (zeros (k, 1));
  absolute = mp (zeros (k, 1));
  for index = 1:k
    absolute(index) = abs (low_values(index) - high_values(index));
    resolved(index) = low_values(index) > threshold ...
                      && high_values(index) > threshold;
    low_abs = abs (low_values(index));
    high_abs = abs (high_values(index));
    denominator = max ([low_abs, high_abs]);
    if (denominator == mp (0))
      relative(index) = mp (0);
    else
      relative(index) = absolute(index) / denominator;
    endif
  endfor
  comparison = struct ("status", "consistent_reference", ...
                       "reference_bits", [low.input_precision_bits, high.input_precision_bits], ...
                       "resolution_floor", threshold, "resolved", resolved, ...
                       "absolute_error", absolute, "relative_error", relative);
endfunction
