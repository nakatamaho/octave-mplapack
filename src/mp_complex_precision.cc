// SPDX-License-Identifier: BSD-2-Clause

#include "mp_complex_precision.h"

#include <stdexcept>

namespace octave_mplapack
{

MpfrMpcPrecisionScope::MpfrMpcPrecisionScope (mpfr_prec_t precision_bits)
  : m_mpfr_precision (mpfrxx::default_precision_bits ()),
    m_mpfr_rounding (mpfrxx::default_rounding_mode ()),
    m_mpc_precision (mpfrxx::mpc_precision_override_storage ()),
    m_mpc_rounding (mpfrxx::mpc_rounding_override_storage ())
{
  if (precision_bits < MPFR_PREC_MIN || precision_bits > MPFR_PREC_MAX)
    throw std::invalid_argument ("complex operation precision is outside MPFR limits");

  mpfrxx::set_default_precision_bits (precision_bits);
  mpfrxx::set_default_rounding_mode (MPFR_RNDN);
  mpfrxx::set_default_mpc_precision_bits (precision_bits, precision_bits);
  mpfrxx::set_default_mpc_rounding_mode (MPFR_RNDN, MPFR_RNDN);
}

MpfrMpcPrecisionScope::~MpfrMpcPrecisionScope () noexcept
{
  mpfrxx::set_default_precision_bits (m_mpfr_precision);
  mpfrxx::set_default_rounding_mode (m_mpfr_rounding);

  if (m_mpc_precision.active)
    mpfrxx::set_default_mpc_precision_bits (
      m_mpc_precision.real_precision_bits,
      m_mpc_precision.imag_precision_bits);
  else
    mpfrxx::clear_mpc_precision_override ();

  if (m_mpc_rounding.active)
    mpfrxx::set_default_mpc_rounding_mode (
      m_mpc_rounding.real_rounding_mode,
      m_mpc_rounding.imag_rounding_mode);
  else
    mpfrxx::clear_mpc_rounding_override ();
}

} // namespace octave_mplapack
