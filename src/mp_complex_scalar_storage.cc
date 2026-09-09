// SPDX-License-Identifier: BSD-2-Clause

#include "mp_complex_scalar_storage.h"

#include <stdexcept>
#include <utility>

#include "mp_complex_precision.h"
#include "mp_scalar_storage.h"

namespace octave_mplapack
{

namespace
{

void
validate_precision (mpfr_prec_t precision_bits)
{
  if (precision_bits < MPFR_PREC_MIN || precision_bits > MPFR_PREC_MAX)
    throw std::invalid_argument ("complex scalar precision is outside MPFR limits");
}

std::string
component_text (const mpfrxx::mpc_class& value, bool imaginary)
{
  MpfrScalarStorage component (
    imaginary ? value.imag () : value.real ());
  return component.to_canonical_string ();
}

} // namespace

MpfrComplexScalarStorage::MpfrComplexScalarStorage (
  const std::string& text, mpfr_prec_t precision_bits)
  : m_value (NativeScalar::with_precision (precision_bits))
{
  validate_precision (precision_bits);
  MpfrMpcPrecisionScope scope (precision_bits);
  if (m_value.set_str (text, 10) != 0)
    throw std::invalid_argument ("invalid complex scalar text");
}

MpfrComplexScalarStorage::MpfrComplexScalarStorage (
  double real, double imag, mpfr_prec_t precision_bits)
  : m_value (NativeScalar::with_precision (precision_bits))
{
  validate_precision (precision_bits);
  MpfrMpcPrecisionScope scope (precision_bits);
  mpc_set_d_d (m_value.mpc_data (), real, imag,
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
}

MpfrComplexScalarStorage::MpfrComplexScalarStorage (
  const std::complex<double>& value, mpfr_prec_t precision_bits)
  : MpfrComplexScalarStorage (value.real (), value.imag (), precision_bits)
{
}

MpfrComplexScalarStorage::MpfrComplexScalarStorage (NativeScalar value)
  : m_value (std::move (value))
{
  validate_precision (m_value.precision ());
}

MpfrComplexScalarStorage&
MpfrComplexScalarStorage::operator= (MpfrComplexScalarStorage other) noexcept
{
  swap (other);
  return *this;
}

void
MpfrComplexScalarStorage::swap (MpfrComplexScalarStorage& other) noexcept
{
  using std::swap;
  swap (m_value, other.m_value);
}

mpfr_prec_t
MpfrComplexScalarStorage::precision_bits () const noexcept
{
  return m_value.precision ();
}

bool
MpfrComplexScalarStorage::exactly_equal (
  const MpfrComplexScalarStorage& other) const noexcept
{
  return mpfr_equal_p (mpc_realref (m_value.mpc_data ()),
                       mpc_realref (other.m_value.mpc_data ()))
           != 0
         && mpfr_equal_p (mpc_imagref (m_value.mpc_data ()),
                          mpc_imagref (other.m_value.mpc_data ()))
           != 0;
}

bool
MpfrComplexScalarStorage::is_nan () const noexcept
{
  return mpfr_nan_p (mpc_realref (m_value.mpc_data ())) != 0
         || mpfr_nan_p (mpc_imagref (m_value.mpc_data ())) != 0;
}

bool
MpfrComplexScalarStorage::is_infinite () const noexcept
{
  return mpfr_inf_p (mpc_realref (m_value.mpc_data ())) != 0
         || mpfr_inf_p (mpc_imagref (m_value.mpc_data ())) != 0;
}

bool
MpfrComplexScalarStorage::is_zero () const noexcept
{
  return mpfr_zero_p (mpc_realref (m_value.mpc_data ())) != 0
         && mpfr_zero_p (mpc_imagref (m_value.mpc_data ())) != 0;
}

bool
MpfrComplexScalarStorage::real_signbit () const noexcept
{
  return mpfr_signbit (mpc_realref (m_value.mpc_data ())) != 0;
}

bool
MpfrComplexScalarStorage::imag_signbit () const noexcept
{
  return mpfr_signbit (mpc_imagref (m_value.mpc_data ())) != 0;
}

std::string
MpfrComplexScalarStorage::to_canonical_string () const
{
  return "(" + component_text (m_value, false) + ","
         + component_text (m_value, true) + ")";
}

std::complex<double>
MpfrComplexScalarStorage::to_double () const
{
  return {m_value.real_to_double (), m_value.imag_to_double ()};
}

const MpfrComplexScalarStorage::NativeScalar&
MpfrComplexScalarStorage::native_value () const noexcept
{
  return m_value;
}

void
swap (MpfrComplexScalarStorage& lhs,
      MpfrComplexScalarStorage& rhs) noexcept
{
  lhs.swap (rhs);
}

} // namespace octave_mplapack
