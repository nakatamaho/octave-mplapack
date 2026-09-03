// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_MATRIX_INSPECTION_H
#define OCTAVE_MPLAPACK_MP_MATRIX_INSPECTION_H

#include <cstddef>
#include <string>
#include <vector>

#include "mp_matrix_storage.h"
#include "mp_complex_matrix_storage.h"

namespace octave_mplapack
{

MpfrMatrixStorage
select_matrix (const MpfrMatrixStorage& source,
               const std::vector<std::size_t>& row_indices,
               const std::vector<std::size_t>& column_indices);

MpfrMatrixStorage
select_linear (const MpfrMatrixStorage& source,
               const std::vector<std::size_t>& indices);

std::string
format_matrix (const MpfrMatrixStorage& source);

MpfrComplexMatrixStorage
select_complex_matrix (const MpfrComplexMatrixStorage& source,
                       const std::vector<std::size_t>& row_indices,
                       const std::vector<std::size_t>& column_indices);

MpfrComplexMatrixStorage
select_complex_linear (const MpfrComplexMatrixStorage& source,
                       const std::vector<std::size_t>& indices);

std::string
format_complex_matrix (const MpfrComplexMatrixStorage& source);

} // namespace octave_mplapack

#endif
