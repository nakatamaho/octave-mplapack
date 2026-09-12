## SPDX-License-Identifier: BSD-2-Clause

function reference = svt_reference (input, reference_bits)
  ## Compute a non-timed frozen-input reference.  Agreement is provisional
  ## until SVT13 supplies an independent enclosure.
  if (! isa (input, "mp") || ! isscalar (reference_bits) ...
      || reference_bits != fix (reference_bits))
    error ("mplapack:svt:InvalidReference", "invalid reference request");
  endif
  frozen = svt_widen (input, reference_bits);
  reference = struct ();
  reference.schema = "svt-reference-v1";
  reference.input = frozen;
  reference.input_precision_bits = reference_bits;
  reference.values = svd (frozen);
  reference.status = "consistent_reference";
  reference.api = "mp.svd one-output reference";
endfunction
