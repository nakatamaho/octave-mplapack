## SPDX-License-Identifier: BSD-2-Clause

function result = mp_column (value)
  ## Reshape through the native core; this also handles scalar mp values,
  ## for which the old-style class colon indexer is intentionally limited.
  result = mp (0);
  result.payload_ = __mplapack_core__ ("matrix_reshape", value, numel (value), 1);
endfunction
