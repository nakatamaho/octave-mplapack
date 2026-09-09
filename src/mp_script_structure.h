// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_SCRIPT_STRUCTURE_H
#define OCTAVE_MPLAPACK_MP_SCRIPT_STRUCTURE_H

#include <cstddef>
#include <cstdint>

#include "mp_matrix_storage.h"
#include "mp_complex_matrix_storage.h"

namespace octave_mplapack
{

MpfrMatrixStorage mpfr_script_diag (const MpfrMatrixStorage& source,
                                    bool vector_input, std::int64_t diagonal);
MpfrComplexMatrixStorage mpc_script_diag (
  const MpfrComplexMatrixStorage& source, bool vector_input,
  std::int64_t diagonal);

MpfrMatrixStorage mpfr_script_triangular (const MpfrMatrixStorage& source,
                                           std::int64_t diagonal,
                                           bool upper);
MpfrComplexMatrixStorage mpc_script_triangular (
  const MpfrComplexMatrixStorage& source, std::int64_t diagonal,
  bool upper);

MpfrMatrixStorage mpfr_script_repmat (const MpfrMatrixStorage& source,
                                      std::size_t row_repetitions,
                                      std::size_t column_repetitions);
MpfrComplexMatrixStorage mpc_script_repmat (
  const MpfrComplexMatrixStorage& source, std::size_t row_repetitions,
  std::size_t column_repetitions);

MpfrMatrixStorage mpfr_script_flip (const MpfrMatrixStorage& source,
                                    int dimension);
MpfrComplexMatrixStorage mpc_script_flip (
  const MpfrComplexMatrixStorage& source, int dimension);

MpfrMatrixStorage mpfr_script_rot90 (const MpfrMatrixStorage& source,
                                     int turns);
MpfrComplexMatrixStorage mpc_script_rot90 (
  const MpfrComplexMatrixStorage& source, int turns);

} // namespace octave_mplapack

#endif
