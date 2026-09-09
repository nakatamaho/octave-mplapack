// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_COMPLEX_PRECISION_H
#define OCTAVE_MPLAPACK_MP_COMPLEX_PRECISION_H

#include <mpfr.h>

#include <mplapack_gmpfrxx_mkII_config.h>
#include <mpcxx_mkII.h>

namespace octave_mplapack
{

// A complex numerical operation has two native defaults to control.  Keeping
// this composition in one scope prevents an MPC temporary from observing a
// stale component precision when the operation enters MPLAPACK.
class MpfrMpcPrecisionScope
{
public:
  explicit MpfrMpcPrecisionScope (mpfr_prec_t precision_bits);
  ~MpfrMpcPrecisionScope () noexcept;

  MpfrMpcPrecisionScope (const MpfrMpcPrecisionScope&) = delete;
  MpfrMpcPrecisionScope& operator= (const MpfrMpcPrecisionScope&) = delete;

private:
  mpfr_prec_t m_mpfr_precision;
  mpfr_rnd_t m_mpfr_rounding;
  mpfrxx::mpc_precision_override_state m_mpc_precision;
  mpfrxx::mpc_rounding_override_state m_mpc_rounding;
};

} // namespace octave_mplapack

#endif
