// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_RANDOM_H
#define OCTAVE_MPLAPACK_MP_RANDOM_H

#include <cstddef>
#include <cstdint>

#include "mp_matrix_storage.h"
#include "mp_scalar_storage.h"

namespace octave_mplapack
{

struct MpRandomState
{
  std::uint64_t first = 0;
  std::uint64_t second = 0;
};

constexpr std::uint64_t mp_random_algorithm_version = 1;

MpRandomState mp_random_seed (std::uint64_t seed) noexcept;

MpfrMatrixStorage mp_random_uniform (std::size_t rows,
                                      std::size_t columns,
                                      mpfr_prec_t precision_bits,
                                      MpRandomState& state);

MpfrMatrixStorage mp_random_normal (std::size_t rows,
                                    std::size_t columns,
                                    mpfr_prec_t precision_bits,
                                    MpRandomState& state);

MpfrMatrixStorage mp_random_integer (std::size_t rows,
                                     std::size_t columns,
                                     mpfr_prec_t precision_bits,
                                     const MpfrScalarStorage& lower,
                                     const MpfrScalarStorage& upper,
                                     MpRandomState& state);

} // namespace octave_mplapack

#endif
