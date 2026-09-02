## SPDX-License-Identifier: BSD-2-Clause

function result = mrdivide (varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{C} =} mrdivide (@var{A}, @var{B})
  ## Right division is intentionally unsupported in v0.1.
  ## @end deftypefn
  error ("mplapack:NotImplemented", ...
         "mp right division is not implemented yet");
endfunction
