// SPDX-License-Identifier: BSD-2-Clause

#include "mp_scalar_storage.h"

#include <algorithm>

namespace octave_mplapack
{

MpfrScalarStorage
MpfrScalarStorage::add (const MpfrScalarStorage& rhs) const
{
  const mpfr_prec_t result_precision
    = std::max (precision_bits (), rhs.precision_bits ());
  MpfrScalarStorage result (result_precision, UninitializedTag {});
  mpfr_add (result.m_value.mpfr_data (), m_value.mpfr_data (),
            rhs.m_value.mpfr_data (), MPFR_RNDN);
  return result;
}

MpfrScalarStorage
MpfrScalarStorage::subtract (const MpfrScalarStorage& rhs) const
{
  const mpfr_prec_t result_precision
    = std::max (precision_bits (), rhs.precision_bits ());
  MpfrScalarStorage result (result_precision, UninitializedTag {});
  mpfr_sub (result.m_value.mpfr_data (), m_value.mpfr_data (),
            rhs.m_value.mpfr_data (), MPFR_RNDN);
  return result;
}

MpfrScalarStorage
MpfrScalarStorage::multiply (const MpfrScalarStorage& rhs) const
{
  const mpfr_prec_t result_precision
    = std::max (precision_bits (), rhs.precision_bits ());
  MpfrScalarStorage result (result_precision, UninitializedTag {});
  mpfr_mul (result.m_value.mpfr_data (), m_value.mpfr_data (),
            rhs.m_value.mpfr_data (), MPFR_RNDN);
  return result;
}

MpfrScalarStorage
MpfrScalarStorage::divide (const MpfrScalarStorage& rhs) const
{
  const mpfr_prec_t result_precision
    = std::max (precision_bits (), rhs.precision_bits ());
  MpfrScalarStorage result (result_precision, UninitializedTag {});
  mpfr_div (result.m_value.mpfr_data (), m_value.mpfr_data (),
            rhs.m_value.mpfr_data (), MPFR_RNDN);
  return result;
}

MpfrScalarStorage
MpfrScalarStorage::negate () const
{
  MpfrScalarStorage result (precision_bits (), UninitializedTag {});
  mpfr_neg (result.m_value.mpfr_data (), m_value.mpfr_data (), MPFR_RNDN);
  return result;
}

} // namespace octave_mplapack
