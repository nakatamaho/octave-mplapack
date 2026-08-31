// SPDX-License-Identifier: BSD-2-Clause

#include "mp_scalar_storage.h"

#include <stdexcept>

namespace octave_mplapack
{

MpfrScalarStorage::MpfrScalarStorage (const std::string& text,
                                      mpfr_prec_t precision_bits)
  : m_value (NativeScalar::with_precision (precision_bits))
{
  if (mpfr_set_str (m_value.mpfr_data (), text.c_str (), 10, MPFR_RNDN) != 0)
    throw std::invalid_argument ("invalid scalar text");
}

MpfrScalarStorage::MpfrScalarStorage (double value,
                                      mpfr_prec_t precision_bits)
  : m_value (NativeScalar::with_precision (precision_bits))
{
  mpfr_set_d (m_value.mpfr_data (), value, MPFR_RNDN);
}

MpfrScalarStorage&
MpfrScalarStorage::operator= (MpfrScalarStorage other) noexcept
{
  swap (other);
  return *this;
}

void
MpfrScalarStorage::swap (MpfrScalarStorage& other) noexcept
{
  m_value.swap (other.m_value);
}

mpfr_prec_t
MpfrScalarStorage::precision_bits () const noexcept
{
  return m_value.precision ();
}

bool
MpfrScalarStorage::exactly_equal (const MpfrScalarStorage& other) const noexcept
{
  return mpfr_equal_p (m_value.mpfr_data (),
                       other.m_value.mpfr_data ()) != 0;
}

bool
MpfrScalarStorage::exactly_equal_string (const std::string& text) const
{
  const MpfrScalarStorage expected (text, precision_bits ());
  return exactly_equal (expected);
}

bool
MpfrScalarStorage::exactly_equal_double (double value) const noexcept
{
  return mpfr_cmp_d (m_value.mpfr_data (), value) == 0;
}

bool
MpfrScalarStorage::is_nan () const noexcept
{
  return mpfr_nan_p (m_value.mpfr_data ()) != 0;
}

bool
MpfrScalarStorage::is_infinite () const noexcept
{
  return mpfr_inf_p (m_value.mpfr_data ()) != 0;
}

bool
MpfrScalarStorage::is_zero () const noexcept
{
  return mpfr_zero_p (m_value.mpfr_data ()) != 0;
}

bool
MpfrScalarStorage::signbit () const noexcept
{
  return mpfr_signbit (m_value.mpfr_data ()) != 0;
}

const MpfrScalarStorage::NativeScalar&
MpfrScalarStorage::native_value () const noexcept
{
  return m_value;
}

void
swap (MpfrScalarStorage& lhs, MpfrScalarStorage& rhs) noexcept
{
  lhs.swap (rhs);
}

} // namespace octave_mplapack
