## SPDX-License-Identifier: BSD-2-Clause

function result = tril (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} tril (@var{value})
  ## @deftypefnx {} {@var{result} =} tril (@var{value}, @var{k})
  ## Return the lower triangular part of a dense @code{mp} matrix.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidArguments", ...
           "tril expects an mp value and an optional offset");
  endif
  if (nargin == 1)
    payload = __mplapack_core__ ("script_structure", value, "tril");
  else
    payload = __mplapack_core__ ("script_structure", value, "tril", ...
                                 varargin{1});
  endif
  result = value;
  result.payload_ = payload;
endfunction
