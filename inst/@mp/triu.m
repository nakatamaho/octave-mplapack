## SPDX-License-Identifier: BSD-2-Clause

function result = triu (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{result} =} triu (@var{value})
  ## @deftypefnx {} {@var{result} =} triu (@var{value}, @var{k})
  ## Return the upper triangular part of a dense @code{mp} matrix.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidArguments", ...
           "triu expects an mp value and an optional offset");
  endif
  if (nargin == 1)
    payload = __mplapack_core__ ("script_structure", value, "triu");
  else
    payload = __mplapack_core__ ("script_structure", value, "triu", ...
                                 varargin{1});
  endif
  result = value;
  result.payload_ = payload;
endfunction
