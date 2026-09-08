## SPDX-License-Identifier: BSD-2-Clause

function [residual, jacobian] = t12_linear_system_callback (value)
  target = mp ("1.375");
  residual = [value(1) - target; value(2) - 2 * target];
  jacobian = mp ([1, 0; 0, 1]);
endfunction
