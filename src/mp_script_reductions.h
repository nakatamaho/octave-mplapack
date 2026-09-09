// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_SCRIPT_REDUCTIONS_H
#define OCTAVE_MPLAPACK_MP_SCRIPT_REDUCTIONS_H

#include <cstddef>
#include <string>
#include <vector>

#include "mp_complex_matrix_storage.h"
#include "mp_matrix_storage.h"

namespace octave_mplapack
{

enum class MpScriptReductionOperation
{
  sum,
  prod,
  sumsq,
  cumsum,
  cumprod
};

enum class MpScriptExtremumOperation
{
  minimum,
  maximum
};

enum class MpScriptComparisonMethod
{
  automatic,
  real,
  absolute
};

struct MpScriptReductionOptions
{
  std::size_t dimension = 1;
  bool all = false;
  bool omit_nan = false;
  bool reverse = false;
  bool output_double = false;
};

struct MpScriptExtremumOptions : MpScriptReductionOptions
{
  MpScriptComparisonMethod comparison = MpScriptComparisonMethod::automatic;
};

struct MpScriptExtremumResultReal
{
  MpfrMatrixStorage values;
  std::vector<std::size_t> indices;
};

struct MpScriptExtremumResultComplex
{
  MpfrComplexMatrixStorage values;
  std::vector<std::size_t> indices;
};

MpfrMatrixStorage mpfr_script_reduce (
  const MpfrMatrixStorage& source,
  MpScriptReductionOperation operation,
  const MpScriptReductionOptions& options);

MpfrComplexMatrixStorage mpc_script_reduce (
  const MpfrComplexMatrixStorage& source,
  MpScriptReductionOperation operation,
  const MpScriptReductionOptions& options);

MpfrMatrixStorage mpc_script_sumsq (
  const MpfrComplexMatrixStorage& source,
  const MpScriptReductionOptions& options);

MpScriptExtremumResultReal mpfr_script_extremum (
  const MpfrMatrixStorage& source,
  MpScriptExtremumOperation operation,
  const MpScriptExtremumOptions& options);

MpScriptExtremumResultComplex mpc_script_extremum (
  const MpfrComplexMatrixStorage& source,
  MpScriptExtremumOperation operation,
  const MpScriptExtremumOptions& options);

MpScriptExtremumResultReal mpfr_script_extremum_pair (
  const MpfrMatrixStorage& lhs,
  const MpfrMatrixStorage& rhs,
  MpScriptExtremumOperation operation,
  const MpScriptExtremumOptions& options);

MpScriptExtremumResultComplex mpc_script_extremum_pair (
  const MpfrComplexMatrixStorage& lhs,
  const MpfrComplexMatrixStorage& rhs,
  MpScriptExtremumOperation operation,
  const MpScriptExtremumOptions& options);

} // namespace octave_mplapack

#endif
