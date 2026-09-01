// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_PRECISION_H
#define OCTAVE_MPLAPACK_MP_PRECISION_H

#include <cstdint>

#include <mpfr.h>

namespace octave_mplapack
{

using precision_count_t = std::uint64_t;

constexpr mpfr_prec_t initial_default_precision_bits = 512;

mpfr_prec_t default_precision_bits () noexcept;
void set_default_precision_bits (mpfr_prec_t precision_bits);

mpfr_prec_t bits_for_decimal_digits (precision_count_t decimal_digits);
precision_count_t decimal_digits_for_bits (mpfr_prec_t precision_bits);

} // namespace octave_mplapack

#endif
