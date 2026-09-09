// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_NATIVE_SERIALIZATION_H
#define OCTAVE_MPLAPACK_MP_NATIVE_SERIALIZATION_H

#include <iosfwd>

#include "mp_complex_matrix_storage.h"
#include "mp_complex_scalar_storage.h"
#include "mp_matrix_storage.h"
#include "mp_scalar_storage.h"

namespace octave_mplapack
{

bool save_native_mpfr_scalar (std::ostream& stream,
                              const MpfrScalarStorage& storage) noexcept;
bool load_native_mpfr_scalar (std::istream& stream,
                              MpfrScalarStorage& storage) noexcept;
bool save_native_mpc_scalar (std::ostream& stream,
                             const MpfrComplexScalarStorage& storage) noexcept;
bool load_native_mpc_scalar (std::istream& stream,
                             MpfrComplexScalarStorage& storage) noexcept;
bool save_native_mpfr_matrix (std::ostream& stream,
                              const MpfrMatrixStorage& storage) noexcept;
bool load_native_mpfr_matrix (std::istream& stream,
                              MpfrMatrixStorage& storage) noexcept;
bool save_native_mpc_matrix (std::ostream& stream,
                             const MpfrComplexMatrixStorage& storage) noexcept;
bool load_native_mpc_matrix (std::istream& stream,
                             MpfrComplexMatrixStorage& storage) noexcept;

} // namespace octave_mplapack

#endif
