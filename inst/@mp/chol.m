## SPDX-License-Identifier: BSD-2-Clause

function varargout = chol (value, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{R} =} chol (@var{A})
  ## @deftypefnx {} {@var{R} =} chol (@var{A}, @var{uplo})
  ## @deftypefnx {} {[@var{R}, @var{p}] =} chol (@var{A}, @var{uplo})
  ## Factor a dense real or complex @code{mp} matrix through MPLAPACK MPFR
  ## @code{Rpotrf} or @code{Cpotrf}.  The default and @code{"upper"} use the
  ## upper triangle; @code{"lower"} uses the lower triangle.  For complex
  ## input the selected triangle defines a Hermitian matrix. Structural copies
  ## preserve the source precision and public values remain immutable.
  ## @end deftypefn
  if (nargin < 1 || nargin > 2 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "chol expects one mp value and an optional upper/lower flag");
  endif
  if (nargout > 2)
    error ("mplapack:mp:OutputCount", ...
           "dense mp chol returns at most a factor and status");
  endif

  option = 'upper';
  if (nargin == 2)
    option = varargin{1};
    if (! ischar (option) && ! isstring (option))
      error ("mplapack:mp:InvalidOption", ...
             "chol option must be \"upper\" or \"lower\"");
    endif
    option = char (option);
    if (! strcmp (option, "upper") && ! strcmp (option, "lower"))
      error ("mplapack:mp:InvalidOption", ...
             "chol option must be \"upper\" or \"lower\"");
    endif
  endif

  [payload, status] = __mplapack_core__ ("chol", value, option);
  if (nargout <= 1 && status != 0)
    error ("mplapack:mp:NotPositiveDefinite", ...
           "chol: input matrix is not positive definite");
  endif

  result = value;
  result.payload_ = payload;
  varargout{1} = result;
  if (nargout == 2)
    varargout{2} = status;
  endif
endfunction
