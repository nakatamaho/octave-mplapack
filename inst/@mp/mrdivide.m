## SPDX-License-Identifier: BSD-2-Clause

function result = mrdivide (varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{C} =} mrdivide (@var{A}, @var{B})
  ## Solve the dense right-division problem @code{A / B} using the
  ## conjugate-transpose identity @code{(B' \ A')'}.  Scalar denominators
  ## use the native element-wise division path.  Square singular systems use
  ## the rank-revealing minimum-norm path, matching Octave's right division.
  ## @end deftypefn
  if (nargin != 2)
    error ("mplapack:mp:InvalidOperands", ...
           "mp right division expects exactly two operands");
  endif

  if (isscalar (varargin{2}))
    result = rdivide (varargin{1}, varargin{2});
    return;
  endif

  lhs_transposed = ctranspose (varargin{2});
  rhs_transposed = ctranspose (varargin{1});
  try
    result = ctranspose (mldivide (lhs_transposed, rhs_transposed));
  catch exception
    if (! strcmp (exception.identifier, "mplapack:mp:SingularMatrix"))
      rethrow (exception);
    endif
    payload = __mplapack_core__ ("mldivide_rank", lhs_transposed, ...
                                 rhs_transposed);
    result = mp (0);
    result.payload_ = payload;
    result = ctranspose (result);
  end_try_catch
endfunction
