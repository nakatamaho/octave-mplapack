// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_MATRIX_INSPECTION_H
#define OCTAVE_MPLAPACK_MP_MATRIX_INSPECTION_H

#include <cstddef>
#include <string>
#include <vector>

#include "mp_matrix_storage.h"

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

} // namespace octave_mplapack

#endif
