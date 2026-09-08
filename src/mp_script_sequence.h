// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_SCRIPT_SEQUENCE_H
#define OCTAVE_MPLAPACK_MP_SCRIPT_SEQUENCE_H

#include <cstddef>
#include <vector>

#include "mp_complex_matrix_storage.h"
#include "mp_matrix_storage.h"

namespace octave_mplapack
{

struct MpScriptSortRealResult
{
  MpfrMatrixStorage values;
  std::vector<std::size_t> indices;
};

struct MpScriptSortComplexResult
{
  MpfrComplexMatrixStorage values;
  std::vector<std::size_t> indices;
};

MpScriptSortRealResult mpfr_script_sort (const MpfrMatrixStorage& source,
                                         std::size_t dimension,
                                         bool descending);
MpScriptSortComplexResult mpc_script_sort (
  const MpfrComplexMatrixStorage& source, std::size_t dimension,
  bool descending);

MpfrMatrixStorage mpfr_script_diff (const MpfrMatrixStorage& source,
                                    std::size_t order,
                                    std::size_t dimension);
MpfrComplexMatrixStorage mpc_script_diff (
  const MpfrComplexMatrixStorage& source, std::size_t order,
  std::size_t dimension);

} // namespace octave_mplapack

#endif
