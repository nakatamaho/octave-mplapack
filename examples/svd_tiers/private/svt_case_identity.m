## SPDX-License-Identifier: BSD-2-Clause

function identity = svt_case_identity (case_id, family, model, represented, ...
                                       construction_bits, exactness, notes)
  if (! isa (model, "mp") || ! isa (represented, "mp"))
    error ("mplapack:svt:InvalidIdentity", "identity inputs must be mp values");
  endif
  model_info = __mplapack_core__ ("value_shape_info", model);
  represented_info = __mplapack_core__ ("value_shape_info", represented);
  identity = struct ();
  identity.schema = "svt-input-v1";
  identity.case_id = case_id;
  identity.family = family;
  identity.model_shape = [model_info.rows, model_info.columns];
  identity.represented_shape = [represented_info.rows, represented_info.columns];
  identity.model_precision_bits = model_info.precision_bits;
  identity.represented_precision_bits = represented_info.precision_bits;
  identity.construction_precision_bits = construction_bits;
  identity.exactness = exactness;
  identity.notes = notes;
  identity.model_is_real = isreal (model);
  identity.represented_is_real = isreal (represented);
endfunction
