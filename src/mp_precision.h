// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_PRECISION_H
#define OCTAVE_MPLAPACK_MP_PRECISION_H

#include <mpfr.h>

namespace octave_mplapack
{

constexpr mpfr_prec_t initial_default_precision_bits = 128;

mpfr_prec_t default_precision_bits () noexcept;

} // namespace octave_mplapack

#endif
