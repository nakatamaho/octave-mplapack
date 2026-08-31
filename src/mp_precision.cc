// SPDX-License-Identifier: BSD-2-Clause

#include "mp_precision.h"

namespace octave_mplapack
{

mpfr_prec_t
default_precision_bits () noexcept
{
  return initial_default_precision_bits;
}

} // namespace octave_mplapack
