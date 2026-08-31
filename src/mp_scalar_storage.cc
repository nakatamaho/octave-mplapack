// SPDX-License-Identifier: BSD-2-Clause

#include "mp_scalar_storage.h"

namespace octave_mplapack
{

MpfrScalarStorage::MpfrScalarStorage (const std::string& text,
                                      mpfr_prec_t precision_bits)
  : m_value (text, precision_bits, 10)
{
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
