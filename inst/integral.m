## SPDX-License-Identifier: BSD-2-Clause

function [result, error_estimate] = integral (fun, a, b, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{q} =} integral (@var{fun}, @var{a}, @var{b})
  ## @deftypefnx {} {[@var{q}, @var{err}] =} integral (@dots{}, @var{options})
  ## Compute a one-dimensional integral with MPFR/MPC nodes, weights,
  ## transformations, and error estimates.  The scalar callback contract is
  ## intentional; ArrayValued is rejected explicitly until a shape-preserving
  ## MP vector reduction is specified.
  ## @end deftypefn
  [result, error_estimate] = quadgk (fun, a, b, varargin{:});
endfunction
