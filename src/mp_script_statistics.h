// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_SCRIPT_STATISTICS_H
#define OCTAVE_MPLAPACK_MP_SCRIPT_STATISTICS_H

#include <cstddef>

#include "mp_complex_matrix_storage.h"
#include "mp_matrix_storage.h"

namespace octave_mplapack
{

struct MpScriptStatisticsOptions
{
  std::size_t dimension = 1;
  bool all = false;
  bool omit_nan = false;
  unsigned int correction = 0;
};

struct MpScriptBoundsRealResult
{
  MpfrMatrixStorage lower;
  MpfrMatrixStorage upper;
};

struct MpScriptBoundsComplexResult
{
  MpfrComplexMatrixStorage lower;
  MpfrComplexMatrixStorage upper;
};

struct MpScriptVarianceRealResult
{
  MpfrMatrixStorage values;
  MpfrMatrixStorage means;
};

struct MpScriptVarianceComplexResult
{
  MpfrMatrixStorage values;
  MpfrComplexMatrixStorage means;
};

MpfrMatrixStorage mpfr_script_mean (
  const MpfrMatrixStorage& source, const MpScriptStatisticsOptions& options);
MpfrComplexMatrixStorage mpc_script_mean (
  const MpfrComplexMatrixStorage& source,
  const MpScriptStatisticsOptions& options);

MpfrMatrixStorage mpfr_script_median (
  const MpfrMatrixStorage& source, const MpScriptStatisticsOptions& options);
MpfrComplexMatrixStorage mpc_script_median (
  const MpfrComplexMatrixStorage& source,
  const MpScriptStatisticsOptions& options);

MpScriptVarianceRealResult mpfr_script_variance (
  const MpfrMatrixStorage& source, const MpScriptStatisticsOptions& options,
  bool standard_deviation);
MpScriptVarianceComplexResult mpc_script_variance (
  const MpfrComplexMatrixStorage& source,
  const MpScriptStatisticsOptions& options, bool standard_deviation);

MpfrMatrixStorage mpfr_script_range (
  const MpfrMatrixStorage& source, const MpScriptStatisticsOptions& options);
MpfrComplexMatrixStorage mpc_script_range (
  const MpfrComplexMatrixStorage& source,
  const MpScriptStatisticsOptions& options);

MpScriptBoundsRealResult mpfr_script_bounds (
  const MpfrMatrixStorage& source, const MpScriptStatisticsOptions& options);
MpScriptBoundsComplexResult mpc_script_bounds (
  const MpfrComplexMatrixStorage& source,
  const MpScriptStatisticsOptions& options);

} // namespace octave_mplapack

#endif
